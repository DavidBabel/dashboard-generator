@echo off
REM Script d'installation du hook pre-commit pour le versioning automatique des blueprints
REM Compatible avec toutes les configurations Windows

echo.
echo ========================================
echo Installation du systeme de versioning
echo ========================================
echo.

REM Verifier qu'on est a la racine du projet
if not exist ".git" (
    echo [ERREUR] Ce script doit etre execute depuis la racine du repository git
    pause
    exit /b 1
)

echo [1/3] Configuration de Git hooks...
git config core.hooksPath .githooks

if %errorlevel% equ 0 (
    echo [OK] Git configure pour utiliser .githooks
) else (
    echo [ERREUR] Echec de la configuration Git
    pause
    exit /b 1
)

echo.
echo [2/3] Verification de Python...
where python >nul 2>&1
if %errorlevel% equ 0 (
    for /f "tokens=*" %%i in ('python --version') do set PYTHON_VERSION=%%i
    echo [OK] Python trouve : !PYTHON_VERSION!
) else (
    where python3 >nul 2>&1
    if %errorlevel% equ 0 (
        for /f "tokens=*" %%i in ('python3 --version') do set PYTHON_VERSION=%%i
        echo [OK] Python3 trouve : !PYTHON_VERSION!
    ) else (
        echo [ATTENTION] Python non trouve. Assurez-vous que Python 3 est installe.
    )
)

echo.
echo [3/3] Verification du hook...
if exist ".githooks\pre-commit" (
    echo [OK] Hook pre-commit trouve
) else (
    echo [ERREUR] Hook pre-commit introuvable
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
