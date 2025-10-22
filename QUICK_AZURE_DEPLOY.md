# 🚀 Azure Web App - Gyors Deployment

## ⚡ Egy kattintásos Azure Web App létrehozás

### **1. Előfeltételek**
- Azure CLI telepítve
- Azure-ba bejelentkezve (`az login`)

### **2. Gyors deployment (PowerShell)**
```powershell
# PowerShell-ben futtasd le:
.\deploy-azure.ps1
```

### **3. Gyors deployment (Bash)**
```bash
# Bash-ben futtasd le:
chmod +x deploy-azure.sh
./deploy-azure.sh
```

### **4. Manuális deployment**
```bash
# Resource Group létrehozása
az group create --name "bori-birthday-rg" --location "West Europe"

# App Service Plan létrehozása
az appservice plan create --name "bori-birthday-plan" --resource-group "bori-birthday-rg" --sku FREE --location "West Europe"

# Web App létrehozása
az webapp create --resource-group "bori-birthday-rg" --plan "bori-birthday-plan" --name "bori-szuletesnap-app" --runtime "PYTHON|3.9"

# Kód deployment
az webapp deployment source config-zip --resource-group "bori-birthday-rg" --name "bori-szuletesnap-app" --src "azure-deployment.zip"
```

## 🎉 Eredmény
- **Weboldal URL**: `https://bori-szuletesnap-app.azurewebsites.net`
- **Admin felület**: `https://bori-szuletesnap-app.azurewebsites.net/admin`
- **Automatikus HTTPS**
- **Mobilbarát design**
- **PWA funkciók**

## 📱 Következő lépések
1. ✅ Nyisd meg a weboldalt
2. ✅ Teszteld az RSVP funkciót
3. ✅ Ellenőrizd az admin felületet
4. ⚙️ Email beállítások (opcionális)

---
**Professzionális Azure Web App 5 perc alatt!** ☁️🎉
