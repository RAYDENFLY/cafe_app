@echo off
echo ================================
echo    CAFE APP FLUTTER INSTALLER
echo ================================
echo.

echo [1/5] Checking Flutter installation...
flutter --version
if %errorlevel% neq 0 (
    echo ERROR: Flutter not found! Please install Flutter first.
    echo Visit: https://docs.flutter.dev/get-started/install
    pause
    exit /b 1
)

echo.
echo [2/5] Getting Flutter dependencies...
flutter pub get
if %errorlevel% neq 0 (
    echo ERROR: Failed to get dependencies!
    pause
    exit /b 1
)

echo.
echo [3/5] Cleaning build cache...
flutter clean

echo.
echo [4/5] Building project...
flutter pub get

echo.
echo [5/5] Checking for connected devices...
flutter devices

echo.
echo ================================
echo    INSTALLATION COMPLETED!
echo ================================
echo.
echo To run the app:
echo   - For debug mode: flutter run
echo   - For release mode: flutter run --release
echo   - For specific device: flutter run -d [device-id]
echo.
echo For more options, check README.md
echo.
pause
