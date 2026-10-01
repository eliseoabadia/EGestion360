@echo off
cd /d "%~dp0"
set ASPNETCORE_ENVIRONMENT=Production
set DOTNET_ENVIRONMENT=Production
dotnet EG.ApiCoreBS.dll
