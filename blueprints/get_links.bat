@echo off
REM Genere les liens GitHub raw pour tous les blueprints

setlocal enabledelayedexpansion

set "OUTPUT_FILE=links.md"
set "BASE_URL=https://raw.githubusercontent.com/DavidBabel/ha/master/blueprints/automation/DavidBabel/"
set "BLUEPRINTS_DIR=automation\DavidBabel"

echo Generation des liens GitHub pour les blueprints...

REM Vider le fichier de sortie
type nul > "%OUTPUT_FILE%"

REM Parcourir tous les fichiers .yaml
for %%f in ("%BLUEPRINTS_DIR%\*.yaml") do (
    echo %BASE_URL%%%~nxf>> "%OUTPUT_FILE%"
)

echo.
echo [OK] Liens generes dans %OUTPUT_FILE%
echo.
type "%OUTPUT_FILE%"
echo.
pause
