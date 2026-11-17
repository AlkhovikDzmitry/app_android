@echo off
chcp 65001 >nul
title БЕЛТЕХОСМОТР - Web версия
cd /d "%~dp0"
echo.
echo  ============================================
echo   БЕЛТЕХОСМОТР - Web версия
echo   Открывается в браузере: http://localhost:8080/web/index.html
echo   Для остановки нажмите Ctrl+C
echo  ============================================
echo.
start http://localhost:8080/web/index.html
python -m http.server 8080
pause