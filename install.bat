@echo off
chcp 65001 >nul
title Install Infinite Generation Four Plugin
echo.
echo ======================================================
echo    DeepSeek cybersecurity red-team toolkit
echo    "Infinite Generation Four" install wizard
echo ======================================================
echo.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0install.ps1"
echo.
echo Press any key to exit...
pause >nul
