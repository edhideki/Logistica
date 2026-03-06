# Deploy do site Empresa Logística para Azure Storage (site estático)
# Pré-requisitos: Azure CLI instalado e "az login" já executado

param(
    [string]$ResourceGroupName = "rg-empresa-logistica",
    [string]$Location = "brazilsouth",
    [string]$StorageAccountName = "empresalogistica"   # Altere se o nome já existir (único no mundo, 3-24 chars, só minúsculas e números)
)

$ErrorActionPreference = "Stop"
$HtmlFile = "Empresa-Logistica.html"
$IndexFile = "index.html"

if (-not (Test-Path $HtmlFile)) {
    Write-Error "Arquivo não encontrado: $HtmlFile. Execute o script na pasta do projeto."
    exit 1
}

Write-Host "=== Publicando no Azure ===" -ForegroundColor Cyan
Write-Host "Grupo de recursos: $ResourceGroupName"
Write-Host "Região: $Location"
Write-Host "Conta de armazenamento: $StorageAccountName"
Write-Host ""

# Cópia do HTML como index.html para ser a página inicial do site estático
Copy-Item $HtmlFile -Destination $IndexFile -Force
Write-Host "[OK] Arquivo preparado: $IndexFile" -ForegroundColor Green

# Criar grupo de recursos (ignora se já existir)
Write-Host "Criando grupo de recursos..." -ForegroundColor Yellow
az group create --name $ResourceGroupName --location $Location --output none 2>$null
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
Write-Host "[OK] Grupo de recursos: $ResourceGroupName" -ForegroundColor Green

# Criar conta de armazenamento
Write-Host "Criando conta de armazenamento..." -ForegroundColor Yellow
az storage account create `
    --resource-group $ResourceGroupName `
    --name $StorageAccountName `
    --location $Location `
    --sku Standard_LRS `
    --kind StorageV2 `
    --output none
if ($LASTEXITCODE -ne 0) {
    Write-Host "Erro: Nome da conta '$StorageAccountName' pode já estar em uso. Escolha outro e rode de novo (ex: empresalogistica02)." -ForegroundColor Red
    exit 1
}
Write-Host "[OK] Conta de armazenamento criada." -ForegroundColor Green

# Habilitar site estático
Write-Host "Habilitando site estático..." -ForegroundColor Yellow
az storage blob service-properties update `
    --account-name $StorageAccountName `
    --static-website `
    --index-document $IndexFile `
    --404-document $IndexFile `
    --output none
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
Write-Host "[OK] Site estático habilitado." -ForegroundColor Green

# Obter chave da conta para upload
$keys = az storage account keys list --resource-group $ResourceGroupName --account-name $StorageAccountName --query "[0].value" -o tsv
if (-not $keys) { Write-Error "Não foi possível obter a chave da conta."; exit 1 }

# Fazer upload do index.html no container $web
Write-Host "Enviando arquivo para o Azure..." -ForegroundColor Yellow
az storage blob upload `
    --account-name $StorageAccountName `
    --account-key $keys `
    --container-name '$web' `
    --name $IndexFile `
    --file $IndexFile `
    --content-type "text/html; charset=utf-8" `
    --overwrite `
    --output none
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
Write-Host "[OK] Arquivo publicado." -ForegroundColor Green

# URL do site estático
$primaryEndpoint = az storage account show --name $StorageAccountName --resource-group $ResourceGroupName --query "primaryEndpoints.web" -o tsv
$siteUrl = $primaryEndpoint -replace "/$",""

Write-Host ""
Write-Host "=== Publicação concluída ===" -ForegroundColor Cyan
Write-Host "Seu site está no ar em:" -ForegroundColor White
Write-Host "  $siteUrl" -ForegroundColor Green
Write-Host ""
Write-Host "Abra o link acima no navegador para ver o projeto." -ForegroundColor Gray

# Opcional: abrir no navegador
$open = Read-Host "Abrir no navegador agora? (S/n)"
if ($open -ne "n" -and $open -ne "N") {
    Start-Process $siteUrl
}
