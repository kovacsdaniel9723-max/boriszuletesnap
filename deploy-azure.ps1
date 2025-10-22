# Azure Web App Deployment Script for Bori Birthday (PowerShell)

param(
    [string]$ResourceGroup = "bori-birthday-rg",
    [string]$AppServicePlan = "bori-birthday-plan",
    [string]$WebAppName = "bori-szuletesnap-app",
    [string]$Location = "West Europe",
    [string]$Runtime = "PYTHON|3.9"
)

Write-Host "🎉 Azure Web App létrehozása Bori születésnapjához..." -ForegroundColor Green

# Színek
$Red = "Red"
$Green = "Green"
$Yellow = "Yellow"
$Blue = "Blue"
$Cyan = "Cyan"

Write-Host "📋 Konfiguráció:" -ForegroundColor $Blue
Write-Host "Resource Group: $ResourceGroup"
Write-Host "App Service Plan: $AppServicePlan"
Write-Host "Web App Name: $WebAppName"
Write-Host "Location: $Location"
Write-Host "Runtime: $Runtime"
Write-Host ""

# 1. Azure bejelentkezés ellenőrzése
Write-Host "🔐 Azure bejelentkezés ellenőrzése..." -ForegroundColor $Yellow
try {
    $account = az account show 2>$null
    if ($LASTEXITCODE -ne 0) {
        throw "Nincs bejelentkezve"
    }
    Write-Host "✅ Sikeresen bejelentkezve az Azure-ba" -ForegroundColor $Green
} catch {
    Write-Host "❌ Nincs bejelentkezve az Azure-ba!" -ForegroundColor $Red
    Write-Host "Futtasd le: az login" -ForegroundColor $Yellow
    exit 1
}

# 2. Resource Group létrehozása
Write-Host "📦 Resource Group létrehozása..." -ForegroundColor $Yellow
try {
    $rg = az group show --name $ResourceGroup 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Resource Group már létezik: $ResourceGroup" -ForegroundColor $Green
    } else {
        throw "Resource Group nem létezik"
    }
} catch {
    az group create --name $ResourceGroup --location $Location
    Write-Host "✅ Resource Group létrehozva: $ResourceGroup" -ForegroundColor $Green
}

# 3. App Service Plan létrehozása
Write-Host "📋 App Service Plan létrehozása..." -ForegroundColor $Yellow
try {
    $plan = az appservice plan show --name $AppServicePlan --resource-group $ResourceGroup 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ App Service Plan már létezik: $AppServicePlan" -ForegroundColor $Green
    } else {
        throw "App Service Plan nem létezik"
    }
} catch {
    az appservice plan create --name $AppServicePlan --resource-group $ResourceGroup --sku FREE --location $Location
    Write-Host "✅ App Service Plan létrehozva: $AppServicePlan" -ForegroundColor $Green
}

# 4. Web App létrehozása
Write-Host "🌐 Web App létrehozása..." -ForegroundColor $Yellow
try {
    $webapp = az webapp show --name $WebAppName --resource-group $ResourceGroup 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Web App már létezik: $WebAppName" -ForegroundColor $Green
    } else {
        throw "Web App nem létezik"
    }
} catch {
    az webapp create --resource-group $ResourceGroup --plan $AppServicePlan --name $WebAppName --runtime $Runtime
    Write-Host "✅ Web App létrehozva: $WebAppName" -ForegroundColor $Green
}

# 5. Environment Variables beállítása
Write-Host "⚙️ Environment Variables beállítása..." -ForegroundColor $Yellow

# Flask beállítások
az webapp config appsettings set --resource-group $ResourceGroup --name $WebAppName --settings FLASK_APP="app.py"
az webapp config appsettings set --resource-group $ResourceGroup --name $WebAppName --settings FLASK_ENV="production"

# Secret key generálása
$SecretKey = [System.Web.Security.Membership]::GeneratePassword(32, 0)
az webapp config appsettings set --resource-group $ResourceGroup --name $WebAppName --settings SECRET_KEY="$SecretKey"

Write-Host "✅ Environment Variables beállítva" -ForegroundColor $Green

# 6. Deployment ZIP létrehozása
Write-Host "📦 Deployment ZIP létrehozása..." -ForegroundColor $Yellow

# Szükséges fájlok listája
$Files = @(
    "Bori_szuletesnap.html",
    "app.py",
    "requirements.txt",
    "bori_birthday.jpg",
    "manifest.json",
    "sw.js",
    "templates"
)

# ZIP fájl létrehozása
$ZipFile = "azure-deployment.zip"
if (Test-Path $ZipFile) {
    Remove-Item $ZipFile
}

# Fájlok hozzáadása a ZIP-hez
foreach ($file in $Files) {
    if (Test-Path $file) {
        if ((Get-Item $file) -is [System.IO.DirectoryInfo]) {
            Compress-Archive -Path $file -DestinationPath $ZipFile -Update
        } else {
            Compress-Archive -Path $file -DestinationPath $ZipFile -Update
        }
        Write-Host "✅ Hozzáadva: $file" -ForegroundColor $Green
    } else {
        Write-Host "⚠️ Fájl nem található: $file" -ForegroundColor $Yellow
    }
}

Write-Host "✅ Deployment ZIP létrehozva: $ZipFile" -ForegroundColor $Green

# 7. Kód deployment
Write-Host "🚀 Kód deployment..." -ForegroundColor $Yellow
az webapp deployment source config-zip --resource-group $ResourceGroup --name $WebAppName --src $ZipFile
Write-Host "✅ Kód sikeresen deploy-olva" -ForegroundColor $Green

# 8. Web App URL lekérése
$WebAppUrl = az webapp show --name $WebAppName --resource-group $ResourceGroup --query "defaultHostName" --output tsv
$FullUrl = "https://$WebAppUrl"

Write-Host ""
Write-Host "🎉 SIKERES! Azure Web App létrehozva!" -ForegroundColor $Green
Write-Host ""
Write-Host "📋 Összefoglaló:" -ForegroundColor $Blue
Write-Host "Resource Group: $ResourceGroup"
Write-Host "App Service Plan: $AppServicePlan"
Write-Host "Web App Name: $WebAppName"
Write-Host "Web App URL: $FullUrl"
Write-Host ""
Write-Host "🔗 Weboldal elérhető itt:" -ForegroundColor $Yellow
Write-Host $FullUrl -ForegroundColor $Green
Write-Host ""
Write-Host "📱 Következő lépések:" -ForegroundColor $Blue
Write-Host "1. Nyisd meg a weboldalt: $FullUrl"
Write-Host "2. Teszteld az RSVP funkciót"
Write-Host "3. Admin felület: $FullUrl/admin"
Write-Host "4. Email beállítások konfigurálása (opcionális)"
Write-Host ""
Write-Host "⚙️ Email beállítások (opcionális):" -ForegroundColor $Yellow
Write-Host "az webapp config appsettings set --resource-group $ResourceGroup --name $WebAppName --settings MAIL_USERNAME='your-email@gmail.com'"
Write-Host "az webapp config appsettings set --resource-group $ResourceGroup --name $WebAppName --settings MAIL_PASSWORD='your-app-password'"
Write-Host ""
Write-Host "🎂 Sok boldog születésnapot Borinak!" -ForegroundColor $Green
