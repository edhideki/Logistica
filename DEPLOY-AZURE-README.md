# Publicar site estático no Azure

Você pode publicar o projeto de duas formas no Azure:

---

## Opção 1: Azure Static Web Apps (recomendado)

**Static Web Apps** é o produto da Microsoft para sites estáticos: plano gratuito, CDN global e URL tipo `https://nome.azurestaticapps.net`.

### Pré-requisitos

1. **Conta Azure** – [Criar conta gratuita](https://azure.microsoft.com/free/)
2. **Azure CLI** – [Instalar Azure CLI (Windows)](https://docs.microsoft.com/cli/azure/install-azure-cli-windows)
3. **Node.js** – [Instalar Node.js](https://nodejs.org/) (para a ferramenta de deploy)

### Publicar com o script

1. Faça login no Azure (uma vez):

```powershell
az login
```

2. Na pasta do projeto, execute:

```powershell
cd "c:\Projeto\Empresa Logistica"
.\deploy-staticwebapp.ps1
```

O script vai criar o **Static Web App** no Azure, enviar o `Empresa-Logistica.html` como `index.html` e mostrar a **URL do site**. Se o nome `empresa-logistica` já existir, edite no script a variável `$StaticWebAppName` (ex.: `empresa-logistica-esvhn`).

### Publicar pelo Portal Azure (sem script)

1. Acesse [portal.azure.com](https://portal.azure.com) → **Criar um recurso** → procure **Static Web App**.
2. Preencha:
   - **Assinatura** e **Grupo de recursos** (ou crie um novo, ex.: `rg-empresa-logistica`).
   - **Nome**: ex. `empresa-logistica`.
   - **Região**: Brasil Sul (Brazil South).
   - **Plano**: Free.
   - Em **Implantar detalhes do código**: escolha **Outro** (não vincule GitHub agora).
3. Clique em **Revisar + criar** e depois **Criar**.
4. Quando o recurso estiver pronto, abra-o → **Gerenciar token de implantação** → **Copiar**.
5. Na pasta do projeto, renomeie `Empresa-Logistica.html` para `index.html` (ou copie o conteúdo para um arquivo `index.html`).
6. No PowerShell, na pasta que contém o `index.html`:

```powershell
npx --yes @azure/static-web-apps-cli deploy . --deployment-token COLE_O_TOKEN_AQUI --env default
```

7. A URL do site aparece em **Visão geral** do Static Web App (ex.: `https://empresa-logistica.azurestaticapps.net`).

### Custo

O plano **Free** do Static Web Apps é gratuito para uso típico de um site estático. Limites em [Preços do Azure Static Web Apps](https://azure.microsoft.com/pricing/details/app-service/static/).

---

## Opção 2: Azure Storage (site estático)

Alternativa mais simples: usa apenas uma **conta de armazenamento** com site estático (sem Node.js).

### Pré-requisitos

- Conta Azure e Azure CLI instalado (como acima).

### Publicar com o script

```powershell
az login
cd "c:\Projeto\Empresa Logistica"
.\deploy-azure.ps1
```

O script cria a conta de armazenamento, ativa o site estático e envia o HTML. A URL fica no formato `https://nomeconta.z22.web.core.windows.net`. Se o nome da conta já existir, edite `$StorageAccountName` no script.

### Publicar manualmente (Portal)

1. Crie uma **Conta de armazenamento** no [Portal Azure](https://portal.azure.com).
2. Em **Configurações** → **Site estático**: ative e defina **Documento de índice** como `index.html`.
3. Em **Contêineres**, abra o contêiner **$web** e faça **Carregar** do arquivo `Empresa-Logistica.html` renomeado como **index.html**.
4. A URL do site aparece em **Site estático** → **Primário**.

---

**Resumo:** Para **Azure Static Web Apps**, use `deploy-staticwebapp.ps1` (com Node.js) ou os passos do Portal acima. Para **Storage**, use `deploy-azure.ps1`.

**Projeto:** Empresa de Logística E-Commerce · Edgar Hideki Shiraishi & Vitor Hugo do Nascimento
