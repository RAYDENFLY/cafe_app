@echo off
echo ================================
echo    CAFE APP BUILD RELEASE
echo ================================
echo.

echo Building APK for Android...
flutter build apk --release

if %errorlevel% equ 0 (
    echo.
    echo ================================
    echo    BUILD SUCCESS!
    echo ================================
    echo APK location: build\app\outputs\flutter-apk\app-release.apk
) else (
    echo.
    echo BUILD FAILED!
)

echo.
pause
