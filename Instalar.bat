@echo off
color 0b
echo ==========================================
echo    Preparando instalacion de Office...
echo ==========================================
powershell -ExecutionPolicy Bypass -File "%~dp0InstalarOffice.ps1"