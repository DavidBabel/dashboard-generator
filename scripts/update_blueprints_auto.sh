#!/bin/bash
# -------------------------------
# Script Auto-Update Blueprints HA
# -------------------------------

# --- CONFIG ---
LOCAL_BASE="/config/blueprints/automation/DavidBabel"

GITHUB_USER="DavidBabel"
GITHUB_REPO="ha"
GITHUB_BRANCH="master"   # ou "main"
LOG_FILE="/config/blueprints/update_log.txt"
# --- FIN CONFIG ---

mkdir -p "$LOCAL_BASE"
mkdir -p "$(dirname "$LOG_FILE")"

# Redirection globale de toutes les sorties vers le fichier de log
exec >> "$LOG_FILE" 2>&1

source /config/scripts/token.sh

echo "----- $(date) -----"
echo "Début de la mise à jour des blueprints"

# Fonction pour mettre à jour un dossier de blueprints
update_blueprints() {
    local DIR="$1"
    for FILE in "$DIR"/*.yaml; do
        [ -e "$FILE" ] || continue
        FILE_NAME=$(basename "$FILE")
        RELATIVE_PATH=${FILE#$LOCAL_BASE/}
        RAW_URL="https://raw.githubusercontent.com/$GITHUB_USER/$GITHUB_REPO/$GITHUB_BRANCH/blueprints/automation/DavidBabel/$RELATIVE_PATH"
        echo "🔄 Mise à jour de $FILE_NAME depuis $RAW_URL"
        curl -sSL "$RAW_URL" -o "$FILE"
        if [ $? -eq 0 ]; then
            echo "✅ $FILE_NAME mis à jour avec succès"
        else
            echo "❌ Erreur lors de la mise à jour de $FILE_NAME (Code: $?)"
        fi
    done
}

# Parcours tous les sous-dossiers
find "$LOCAL_BASE" -type d | while read SUBDIR; do
    update_blueprints "$SUBDIR"
done

echo "✅ Tous les blueprints ont été mis à jour."

# Adresse de Home Assistant
HA_URL="http://localhost:8123"  # ou https://<ip>:8123 si externe

# Rechargement des blueprints d'automation
echo "🔄 Rechargement des blueprints via l'API HA (Romains)..."
curl -s -X POST -H "Authorization: Bearer $HA_TOKEN_ROMAINS" \
     -H "Content-Type: application/json" \
     "http://192.168.1.56:8123/api/services/homeassistant/reload_all"
if [ $? -eq 0 ]; then
    echo "✅ Blueprints rechargés avec succès (Romains)"
else
    echo "❌ Erreur lors du rechargement des blueprints (Romains, Code: $?)"
fi

echo "🔄 Rechargement des blueprints via l'API HA (Engel)..."
curl -s -X POST -H "Authorization: Bearer $HA_TOKEN_ENGEL" \
     -H "Content-Type: application/json" \
     "http://192.168.1.57:8123/api/services/homeassistant/reload_all"
if [ $? -eq 0 ]; then
    echo "✅ Blueprints rechargés avec succès (Engel)"
else
    echo "❌ Erreur lors du rechargement des blueprints (Engel, Code: $?)"
fi

echo "----- Fin de la mise à jour des blueprints -----"