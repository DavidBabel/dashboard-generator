@echo off
REM Wrapper pour lancer get_links depuis n'importe où
cd /d "%~dp0.githooks"
call get_links.bat
cd /d "%~dp0"
