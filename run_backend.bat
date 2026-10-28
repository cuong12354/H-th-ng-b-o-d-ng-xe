@echo off
title VehicleCare ASP.NET Core Backend (Port 5054)
color 0A
echo ========================================================
echo   KHOI DONG HE THONG SERVER BACKEND (PORT 5054)
echo ========================================================
echo.

:: Port forward for Android Emulator and connected phones
echo [*] Dang chuyen tiep cong (ADB reverse 5054)...
adb reverse tcp:5054 tcp:5054 >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo [OK] ADB reverse thanh cong! Thiet bi Android da duoc ket noi cong 5054.
) else (
    echo [INFO] Khong tim thay thiet bi ADB hoac chua bat USB Debugging.
)

echo.
echo [*] Dang chay Backend ASP.NET Core tren dia chi: http://0.0.0.0:5054 ...
cd Backend
dotnet run --launch-profile http
pause
