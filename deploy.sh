#!/bin/bash
# Azure App Service deployment script

echo "🚀 Azure App Service deployment indítása..."

# Függőségek telepítése
echo "📦 Függőségek telepítése..."
pip install -r requirements.txt

# Adatbázis inicializálása
echo "🗄️ Adatbázis inicializálása..."
python -c "from app import app, db; app.app_context().push(); db.create_all()"

# Statikus fájlok másolása
echo "📁 Statikus fájlok előkészítése..."
mkdir -p static/css static/js

# Flask alkalmazás indítása
echo "🎉 Flask alkalmazás indítása..."
gunicorn --bind 0.0.0.0:$PORT app:app
