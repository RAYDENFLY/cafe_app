@echo off
echo ================================
echo      CAFE APP QUICK RUN
echo ================================
echo.

echo Checking Flutter installation...
flutter --version
if %errorlevel% neq 0 (
    echo ERROR: Flutter not found! Run install.bat first.
    pause
    exit /b 1
)

echo.
echo Starting Cafe App...
flutter run

pause
