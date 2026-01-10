#!/bin/bash
# Génère les liens GitHub raw pour tous les blueprints

OUTPUT_FILE="links.md"
BASE_URL="https://raw.githubusercontent.com/DavidBabel/ha/master/blueprints/automation/DavidBabel/"
BLUEPRINTS_DIR="automation/DavidBabel"

echo "Génération des liens GitHub pour les blueprints..."

# Vider le fichier de sortie
> "$OUTPUT_FILE"

# Parcourir tous les fichiers .yaml
for file in "$BLUEPRINTS_DIR"/*.yaml; do
    if [ -f "$file" ]; then
        filename=$(basename "$file")
        echo "${BASE_URL}${filename}" >> "$OUTPUT_FILE"
    fi
done

echo "✓ Liens générés dans $OUTPUT_FILE"
echo ""
cat "$OUTPUT_FILE"
