@echo off
title Comparador de nombres de archivo
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0Comparar-Nombres.ps1"
echo.
if errorlevel 1 echo Ocurrio un error. Revisa el mensaje mostrado arriba.
pause

