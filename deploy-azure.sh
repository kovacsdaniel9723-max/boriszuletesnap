#!/bin/bash
# Azure Web App Deployment Script for Bori Birthday

set -e

echo "🎉 Azure Web App létrehozása Bori születésnapjához..."

# Színek a kimenethez
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Konfiguráció
RESOURCE_GROUP="bori-birthday-rg"
APP_SERVICE_PLAN="bori-birthday-plan"
WEB_APP_NAME="bori-szuletesnap-app"
LOCATION="West Europe"
RUNTIME="PYTHON|3.9"

echo -e "${BLUE}📋 Konfiguráció:${NC}"
echo "Resource Group: $RESOURCE_GROUP"
echo "App Service Plan: $APP_SERVICE_PLAN"
echo "Web App Name: $WEB_APP_NAME"
echo "Location: $LOCATION"
echo "Runtime: $RUNTIME"
echo ""

# 1. Azure bejelentkezés ellenőrzése
echo -e "${YELLOW}🔐 Azure bejelentkezés ellenőrzése...${NC}"
if ! az account show &> /dev/null; then
    echo -e "${RED}❌ Nincs bejelentkezve az Azure-ba!${NC}"
    echo "Futtasd le: az login"
    exit 1
fi
echo -e "${GREEN}✅ Sikeresen bejelentkezve az Azure-ba${NC}"

# 2. Resource Group létrehozása
echo -e "${YELLOW}📦 Resource Group létrehozása...${NC}"
if az group show --name "$RESOURCE_GROUP" &> /dev/null; then
    echo -e "${GREEN}✅ Resource Group már létezik: $RESOURCE_GROUP${NC}"
else
    az group create --name "$RESOURCE_GROUP" --location "$LOCATION"
    echo -e "${GREEN}✅ Resource Group létrehozva: $RESOURCE_GROUP${NC}"
fi

# 3. App Service Plan létrehozása
echo -e "${YELLOW}📋 App Service Plan létrehozása...${NC}"
if az appservice plan show --name "$APP_SERVICE_PLAN" --resource-group "$RESOURCE_GROUP" &> /dev/null; then
    echo -e "${GREEN}✅ App Service Plan már létezik: $APP_SERVICE_PLAN${NC}"
else
    az appservice plan create --name "$APP_SERVICE_PLAN" --resource-group "$RESOURCE_GROUP" --sku FREE --location "$LOCATION"
    echo -e "${GREEN}✅ App Service Plan létrehozva: $APP_SERVICE_PLAN${NC}"
fi

# 4. Web App létrehozása
echo -e "${YELLOW}🌐 Web App létrehozása...${NC}"
if az webapp show --name "$WEB_APP_NAME" --resource-group "$RESOURCE_GROUP" &> /dev/null; then
    echo -e "${GREEN}✅ Web App már létezik: $WEB_APP_NAME${NC}"
else
    az webapp create --resource-group "$RESOURCE_GROUP" --plan "$APP_SERVICE_PLAN" --name "$WEB_APP_NAME" --runtime "$RUNTIME"
    echo -e "${GREEN}✅ Web App létrehozva: $WEB_APP_NAME${NC}"
fi

# 5. Environment Variables beállítása
echo -e "${YELLOW}⚙️ Environment Variables beállítása...${NC}"

# Flask beállítások
az webapp config appsettings set --resource-group "$RESOURCE_GROUP" --name "$WEB_APP_NAME" --settings FLASK_APP="app.py"
az webapp config appsettings set --resource-group "$RESOURCE_GROUP" --name "$WEB_APP_NAME" --settings FLASK_ENV="production"

# Secret key generálása
SECRET_KEY=$(openssl rand -base64 32)
az webapp config appsettings set --resource-group "$RESOURCE_GROUP" --name "$WEB_APP_NAME" --settings SECRET_KEY="$SECRET_KEY"

echo -e "${GREEN}✅ Environment Variables beállítva${NC}"

# 6. Deployment ZIP létrehozása
echo -e "${YELLOW}📦 Deployment ZIP létrehozása...${NC}"

# Szükséges fájlok listája
FILES=(
    "Bori_szuletesnap.html"
    "app.py"
    "requirements.txt"
    "bori_birthday.jpg"
    "manifest.json"
    "sw.js"
    "templates"
)

# ZIP fájl létrehozása
ZIP_FILE="azure-deployment.zip"
if [ -f "$ZIP_FILE" ]; then
    rm "$ZIP_FILE"
fi

# Fájlok hozzáadása a ZIP-hez
for file in "${FILES[@]}"; do
    if [ -e "$file" ]; then
        if [ -d "$file" ]; then
            zip -r "$ZIP_FILE" "$file"
        else
            zip "$ZIP_FILE" "$file"
        fi
        echo -e "${GREEN}✅ Hozzáadva: $file${NC}"
    else
        echo -e "${RED}⚠️ Fájl nem található: $file${NC}"
    fi
done

echo -e "${GREEN}✅ Deployment ZIP létrehozva: $ZIP_FILE${NC}"

# 7. Kód deployment
echo -e "${YELLOW}🚀 Kód deployment...${NC}"
az webapp deployment source config-zip --resource-group "$RESOURCE_GROUP" --name "$WEB_APP_NAME" --src "$ZIP_FILE"
echo -e "${GREEN}✅ Kód sikeresen deploy-olva${NC}"

# 8. Web App URL lekérése
WEB_APP_URL=$(az webapp show --name "$WEB_APP_NAME" --resource-group "$RESOURCE_GROUP" --query "defaultHostName" --output tsv)
FULL_URL="https://$WEB_APP_URL"

echo ""
echo -e "${GREEN}🎉 SIKERES! Azure Web App létrehozva!${NC}"
echo ""
echo -e "${BLUE}📋 Összefoglaló:${NC}"
echo "Resource Group: $RESOURCE_GROUP"
echo "App Service Plan: $APP_SERVICE_PLAN"
echo "Web App Name: $WEB_APP_NAME"
echo "Web App URL: $FULL_URL"
echo ""
echo -e "${YELLOW}🔗 Weboldal elérhető itt:${NC}"
echo -e "${GREEN}$FULL_URL${NC}"
echo ""
echo -e "${BLUE}📱 Következő lépések:${NC}"
echo "1. Nyisd meg a weboldalt: $FULL_URL"
echo "2. Teszteld az RSVP funkciót"
echo "3. Admin felület: $FULL_URL/admin"
echo "4. Email beállítások konfigurálása (opcionális)"
echo ""
echo -e "${YELLOW}⚙️ Email beállítások (opcionális):${NC}"
echo "az webapp config appsettings set --resource-group $RESOURCE_GROUP --name $WEB_APP_NAME --settings MAIL_USERNAME='your-email@gmail.com'"
echo "az webapp config appsettings set --resource-group $RESOURCE_GROUP --name $WEB_APP_NAME --settings MAIL_PASSWORD='your-app-password'"
echo ""
echo -e "${GREEN}🎂 Sok boldog születésnapot Borinak!${NC}"
