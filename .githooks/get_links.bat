@echo off
REM Genere les liens GitHub raw pour tous les blueprints, organises par categorie

setlocal enabledelayedexpansion

set "OUTPUT_FILE=..\blueprints\links.md"
set "BASE_URL=https://raw.githubusercontent.com/DavidBabel/ha/master/blueprints/automation/DavidBabel/"
set "BLUEPRINTS_DIR=..\blueprints\automation\DavidBabel"
set "TEMP_DIR=%TEMP%\blueprints_links"

echo Generation des liens GitHub pour les blueprints...

REM Creer un repertoire temporaire
if not exist "%TEMP_DIR%" mkdir "%TEMP_DIR%"
del /Q "%TEMP_DIR%\*" 2>nul

REM Parcourir tous les fichiers .yaml et les grouper par categorie
for %%f in ("%BLUEPRINTS_DIR%\*.yaml") do (
    set "filename=%%~nxf"

    REM Lire la troisieme ligne du fichier
    set "linenum=0"
    for /f "usebackq delims=" %%l in ("%%f") do (
        set /a linenum+=1
        if !linenum! equ 3 (
            set "line=%%l"
            REM Extraire la categorie
            echo !line! | findstr /C:"# Appartement:" >nul
            if !errorlevel! equ 0 (
                for /f "tokens=3*" %%a in ("!line!") do set "category=%%a"
            ) else (
                set "category=Autre"
            )
        )
    )

    REM Ajouter le lien au fichier temporaire de la categorie
    if not defined category set "category=Autre"
    echo %BASE_URL%!filename!>> "%TEMP_DIR%\!category!.txt"
)

REM Vider le fichier de sortie
type nul > "%OUTPUT_FILE%"

REM Lire tous les fichiers temporaires (tries alphabetiquement)
for /f "delims=" %%c in ('dir /b /on "%TEMP_DIR%\*.txt"') do (
    set "category=%%~nc"
    echo # Appartement: !category!>> "%OUTPUT_FILE%"
    type "%TEMP_DIR%\%%c" >> "%OUTPUT_FILE%"
    echo.>> "%OUTPUT_FILE%"
)

REM Nettoyer
rd /s /q "%TEMP_DIR%"

echo.
echo [OK] Liens generes dans %OUTPUT_FILE%
echo.
type "%OUTPUT_FILE%"
echo.
