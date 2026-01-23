#!/bin/bash
# Installateur des Git Hooks pour Linux/Mac
# Configure Git pour utiliser le repertoire .githooks

echo ""
echo "========================================"
echo "Installation des Git Hooks"
echo "========================================"
echo ""

# Verifier qu'on est a la racine du projet
if [ ! -d ".git" ]; then
    echo "[ERREUR] Ce script doit etre execute depuis la racine du repository git"
    exit 1
fi

# Rendre le hook executable
chmod +x .githooks/pre-commit

# Configurer Git pour utiliser .githooks comme repertoire de hooks
git config core.hooksPath .githooks

if [ $? -eq 0 ]; then
    echo "[OK] Hooks installes avec succes"
    echo ""
    echo "Le hook pre-commit va maintenant incrementer automatiquement"
    echo "la version des blueprints a chaque commit."
    echo ""
    echo "Testez en modifiant un blueprint et en faisant un commit."
else
    echo "[ERREUR] Echec de la configuration"
    exit 1
fi

echo ""
