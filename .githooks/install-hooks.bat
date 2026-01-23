@echo off
REM Installateur des Git Hooks pour Windows
REM Configure Git pour utiliser le repertoire .githooks

echo.
echo ========================================
echo Installation des Git Hooks
echo ========================================
echo.

REM Verifier qu'on est a la racine du projet
if not exist ".git" (
    echo [ERREUR] Ce script doit etre execute depuis la racine du repository git
    pause
    exit /b 1
)

echo Configuration de Git hooks...
git config core.hooksPath .githooks

if %errorlevel% equ 0 (
    echo [OK] Hooks installes avec succes
    echo.
    echo Le hook pre-commit va maintenant incrementer automatiquement
    echo la version des blueprints a chaque commit.
    echo.
    echo Utilisez Git Bash pour faire vos commits.
    echo Testez en modifiant un blueprint et en faisant un commit.
) else (
    echo [ERREUR] Echec de la configuration
)

echo.
pause
    pause
    exit /b 1
)

echo.
echo ========================================
echo Installation terminee avec succes !
echo ========================================
echo.
echo Prochaines etapes :
echo   1. Modifiez un blueprint dans blueprints/automation/
echo   2. Faites un commit normalement
echo   3. Le hook incrementera automatiquement la version
echo.
echo Documentation complete : .githooks\README.md
echo.
echo Vous n'avez plus rien a gerer, tout est automatique !
echo.
pause
