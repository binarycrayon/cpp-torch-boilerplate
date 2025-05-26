@echo off
setlocal enabledelayedexpansion

REM Setup script for Windows - Downloads and extracts LibTorch
set LIBTORCH_VERSION=2.5.1
set CUDA_VERSION=cu124
set LIBTORCH_DIR=libtorch
set LIBTORCH_ZIP=libtorch-%LIBTORCH_VERSION%-%CUDA_VERSION%-win.zip

REM LibTorch download URL for Windows with CUDA 12.4
set LIBTORCH_URL=https://download.pytorch.org/libtorch/cu124/libtorch-win-shared-with-deps-%LIBTORCH_VERSION%%%2B%CUDA_VERSION%.zip

echo === LibTorch Setup for Windows ===
echo Version: %LIBTORCH_VERSION%
echo CUDA: %CUDA_VERSION%
echo.

REM Check if LibTorch already exists
if exist "%LIBTORCH_DIR%" (
    echo ⚠️ LibTorch directory already exists. Delete it first if you want to re-download.
    echo Current LibTorch: %LIBTORCH_DIR%
    goto :end
)

REM Check if zip already exists
if exist "%LIBTORCH_ZIP%" (
    echo 📦 Found existing LibTorch zip file: %LIBTORCH_ZIP%
    goto :extract
)

REM Download LibTorch
echo 📥 Downloading LibTorch %LIBTORCH_VERSION% with CUDA %CUDA_VERSION%...
echo URL: %LIBTORCH_URL%
echo.

REM Use PowerShell to download (available on Windows 7+)
powershell -Command "& {[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri '%LIBTORCH_URL%' -OutFile '%LIBTORCH_ZIP%' -UseBasicParsing}"

if errorlevel 1 (
    echo ❌ Download failed. Please check your internet connection.
    exit /b 1
)

echo ✅ Download completed!

:extract
REM Extract LibTorch
echo 📂 Extracting LibTorch...
powershell -Command "Expand-Archive -Path '%LIBTORCH_ZIP%' -DestinationPath '.' -Force"

if errorlevel 1 (
    echo ❌ Extraction failed.
    exit /b 1
)

echo ✅ LibTorch extracted successfully!
echo 📁 LibTorch location: %cd%\%LIBTORCH_DIR%

:end
echo.
echo 🎉 Setup completed! You can now run:
echo    build.bat --run
echo. 