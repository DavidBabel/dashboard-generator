#!/bin/bash
# Génère les liens GitHub raw pour tous les blueprints, organisés par catégorie

# Se placer dans le répertoire racine du projet
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/.." || exit 1

OUTPUT_FILE="blueprints/links.md"
BASE_URL="https://raw.githubusercontent.com/DavidBabel/ha/master/blueprints/automation/DavidBabel/"
BLUEPRINTS_DIR="blueprints/automation/DavidBabel"

echo "Génération des liens GitHub pour les blueprints..."

# Vider le fichier de sortie
> "$OUTPUT_FILE"

# Tableau associatif pour stocker les liens par catégorie
declare -A categories

# Parcourir tous les fichiers .yaml
for file in "$BLUEPRINTS_DIR"/*.yaml; do
    if [ -f "$file" ]; then
        filename=$(basename "$file")

        # Lire la troisième ligne pour extraire la catégorie
        category=$(sed -n '3p' "$file" | grep -o "# Appartement:.*" | sed 's/# Appartement: *//')

        # Si pas de catégorie trouvée, mettre "Autre"
        if [ -z "$category" ]; then
            category="Autre"
        fi

        # Ajouter le lien à la catégorie
        if [ -z "${categories[$category]}" ]; then
            categories[$category]="${BASE_URL}${filename}"
        else
            categories[$category]="${categories[$category]}"$'\n'"${BASE_URL}${filename}"
        fi
    fi
done

# Trier les catégories et écrire dans le fichier
for category in $(echo "${!categories[@]}" | tr ' ' '\n' | sort); do
    echo "# Appartement: $category" >> "$OUTPUT_FILE"
    echo "${categories[$category]}" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
done

echo "✓ Liens générés dans $OUTPUT_FILE"
echo ""
cat "$OUTPUT_FILE"
