# Deploy do site Empresa Logística para Azure Static Web Apps
# Pré-requisitos: Azure CLI instalado, "az login" e Node.js (para SWA CLI)
# Se não tiver Node.js, crie o Static Web App pelo script e faça o deploy pelo Portal (veja README).

param(
    [string]$ResourceGroupName = "rg-empresa-logistica",
    [string]$Location = "brazilsouth",
    [string]$StaticWebAppName = "empresa-logistica"   # Nome do app (pode ter hífen)
)

$ErrorActionPreference = "Stop"
$HtmlFile = "Empresa-Logistica.html"
$IndexFile = "index.html"

if (-not (Test-Path $HtmlFile)) {
    Write-Error "Arquivo não encontrado: $HtmlFile. Execute o script na pasta do projeto."
    exit 1
}

Write-Host "=== Publicando no Azure Static Web Apps ===" -ForegroundColor Cyan
Write-Host "Grupo de recursos: $ResourceGroupName"
Write-Host "Região: $Location"
Write-Host "Static Web App: $StaticWebAppName"
Write-Host ""

# Preparar index.html
Copy-Item $HtmlFile -Destination $IndexFile -Force
Write-Host "[OK] Arquivo preparado: $IndexFile" -ForegroundColor Green

# Grupo de recursos
Write-Host "Criando grupo de recursos..." -ForegroundColor Yellow
az group create --name $ResourceGroupName --location $Location --output none 2>$null
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
Write-Host "[OK] Grupo de recursos: $ResourceGroupName" -ForegroundColor Green

# Criar Azure Static Web App (sem repositório – deploy via CLI)
Write-Host "Criando Azure Static Web App..." -ForegroundColor Yellow
az staticwebapp create `
    --name $StaticWebAppName `
    --resource-group $ResourceGroupName `
    --location $Location `
    --sku Free `
    --output none 2>$null

if ($LASTEXITCODE -ne 0) {
    Write-Host "Static Web App já existe ou outro erro. Continuando para obter token..." -ForegroundColor Yellow
}

# Obter token de deploy e URL (funciona para app novo ou existente)
$token = az staticwebapp secrets list --name $StaticWebAppName --resource-group $ResourceGroupName --query "properties.apiKey" -o tsv 2>$null
$defaultHostname = az staticwebapp show --name $StaticWebAppName --resource-group $ResourceGroupName --query "defaultHostname" -o tsv 2>$null

if (-not $token) {
    Write-Host "Não foi possível obter o token de deploy. Obtenha no Portal: Static Web App > Gerenciar token de implantação." -ForegroundColor Red
    exit 1
}

# Deploy com SWA CLI (npx para não exigir instalação global)
Write-Host "Enviando arquivos para o Azure (SWA CLI)..." -ForegroundColor Yellow
$deployResult = npx --yes @azure/static-web-apps-cli deploy . --deployment-token $token --env default 2>&1

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "Se aparecer erro de 'npx' ou 'node', instale o Node.js em https://nodejs.org e execute o script de novo." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Ou faça o deploy manual:" -ForegroundColor Cyan
    Write-Host "  1. No Portal Azure, abra o Static Web App '$StaticWebAppName'." -ForegroundColor Gray
    Write-Host "  2. Em 'Visão geral', use a URL: https://$defaultHostname" -ForegroundColor Gray
    Write-Host "  3. Para publicar de novo: Gerenciar token de implantação > Copiar, depois no PowerShell:" -ForegroundColor Gray
    Write-Host "     npx --yes @azure/static-web-apps-cli deploy . --deployment-token SEU_TOKEN --env default" -ForegroundColor Gray
    Write-Host ""
    exit 1
}

$siteUrl = "https://$defaultHostname"
Write-Host ""
Write-Host "=== Publicação concluída ===" -ForegroundColor Cyan
Write-Host "Seu site está no ar em:" -ForegroundColor White
Write-Host "  $siteUrl" -ForegroundColor Green
Write-Host ""
Write-Host "Abra o link acima no navegador." -ForegroundColor Gray

$open = Read-Host "Abrir no navegador agora? (S/n)"
if ($open -ne "n" -and $open -ne "N") {
    Start-Process $siteUrl
}
