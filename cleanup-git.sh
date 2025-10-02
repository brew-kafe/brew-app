#!/bin/bash
# cleanup.sh
# 🚀 Script para limpiar archivos no deseados en tu rama local antes de mergear con main

echo "🔎 Limpiando archivos no deseados del cache de Git..."

# Remover del index (cache) pero no del disco
git rm --cached -r *.xcuserstate 2>/dev/null
git rm --cached -r */xcuserdata 2>/dev/null
git rm --cached -r DerivedData 2>/dev/null
git rm --cached -r ModuleCache.noindex 2>/dev/null
git rm --cached .DS_Store 2>/dev/null

echo "✅ Archivos eliminados del cache (si existían)."

echo "📌 Ahora haz commit de la limpieza:"
echo "    git commit -m 'Cleanup ignored files from branch'"
echo ""
echo "👉 Después, actualiza tu rama con main:"
echo "    git checkout main && git pull origin main"
echo "    git checkout <tu-rama> && git merge main"