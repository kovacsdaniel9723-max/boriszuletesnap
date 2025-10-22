# Azure Web App Deployment Guide

## 🚀 Azure Web App létrehozása Bori születésnapjához

### 1. lépés: Azure CLI telepítése és bejelentkezés
```bash
# Azure CLI telepítése (Windows)
winget install Microsoft.AzureCLI

# Bejelentkezés
az login

# Subscription kiválasztása
az account list --output table
az account set --subscription "Your-Subscription-Name"
```

### 2. lépés: Resource Group létrehozása
```bash
# Resource Group létrehozása
az group create --name "bori-birthday-rg" --location "West Europe"
```

### 3. lépés: App Service Plan létrehozása
```bash
# App Service Plan létrehozása (Free tier)
az appservice plan create --name "bori-birthday-plan" --resource-group "bori-birthday-rg" --sku FREE --location "West Europe"
```

### 4. lépés: Web App létrehozása
```bash
# Web App létrehozása Python 3.9 runtime-nel
az webapp create --resource-group "bori-birthday-rg" --plan "bori-birthday-plan" --name "bori-szuletesnap-app" --runtime "PYTHON|3.9"
```

### 5. lépés: Environment Variables beállítása
```bash
# Email beállítások
az webapp config appsettings set --resource-group "bori-birthday-rg" --name "bori-szuletesnap-app" --settings MAIL_USERNAME="your-email@gmail.com"
az webapp config appsettings set --resource-group "bori-birthday-rg" --name "bori-szuletesnap-app" --settings MAIL_PASSWORD="your-app-password"

# Secret key
az webapp config appsettings set --resource-group "bori-birthday-rg" --name "bori-szuletesnap-app" --settings SECRET_KEY="your-secret-key-here"

# Flask beállítások
az webapp config appsettings set --resource-group "bori-birthday-rg" --name "bori-szuletesnap-app" --settings FLASK_APP="app.py"
az webapp config appsettings set --resource-group "bori-birthday-rg" --name "bori-szuletesnap-app" --settings FLASK_ENV="production"
```

### 6. lépés: Kód deployment
```bash
# ZIP fájl létrehozása
# Windows PowerShell-ben:
Compress-Archive -Path "Bori_szuletesnap.html", "app.py", "requirements.txt", "bori_birthday.jpg", "manifest.json", "sw.js", "templates" -DestinationPath "deployment.zip"

# Deployment
az webapp deployment source config-zip --resource-group "bori-birthday-rg" --name "bori-szuletesnap-app" --src "deployment.zip"
```

### 7. lépés: Custom Domain (opcionális)
```bash
# Custom domain hozzáadása
az webapp config hostname add --resource-group "bori-birthday-rg" --webapp-name "bori-szuletesnap-app" --hostname "bori-szuletesnap.com"
```

## 🎉 Eredmény
- 🌐 **Weboldal URL**: `https://bori-szuletesnap-app.azurewebsites.net`
- 🔒 **Automatikus HTTPS**
- 📱 **Mobilbarát**
- ⚡ **Gyors betöltés**
- 🔄 **Automatikus skálázás**

## 📊 Monitoring és Analytics
```bash
# Application Insights engedélyezése
az monitor app-insights component create --app "bori-szuletesnap-app" --location "West Europe" --resource-group "bori-birthday-rg"
```

## 🔧 További konfigurációk

### SSL Certificate
```bash
# Let's Encrypt SSL certificate
az webapp config ssl upload --resource-group "bori-birthday-rg" --name "bori-szuletesnap-app" --certificate-file "certificate.pfx" --certificate-password "password"
```

### Backup beállítása
```bash
# Backup konfiguráció
az webapp config backup create --resource-group "bori-birthday-rg" --webapp-name "bori-szuletesnap-app" --backup-name "daily-backup" --container-url "https://yourstorageaccount.blob.core.windows.net/backups"
```

## 💰 Költségek
- **Free Tier**: 0 Ft/hó (korlátozott erőforrásokkal)
- **Basic Tier**: ~2,000 Ft/hó (professzionális használathoz)
- **Standard Tier**: ~8,000 Ft/hó (skálázhatósághoz)

## 🚀 Gyors deployment script
```bash
# Egy parancsban minden
az group create --name "bori-birthday-rg" --location "West Europe" && \
az appservice plan create --name "bori-birthday-plan" --resource-group "bori-birthday-rg" --sku FREE --location "West Europe" && \
az webapp create --resource-group "bori-birthday-rg" --plan "bori-birthday-plan" --name "bori-szuletesnap-app" --runtime "PYTHON|3.9" && \
echo "Azure Web App sikeresen létrehozva: https://bori-szuletesnap-app.azurewebsites.net"
```

---
**Professzionális weboldal Azure-ban!** ☁️🎉
