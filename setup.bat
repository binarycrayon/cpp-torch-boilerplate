@echo off
setlocal enabledelayedexpansion

REM Setup script for Windows - Downloads and extracts LibTorch
set LIBTORCH_VERSION=2.7.0

REM Check if CUDA_VERSION is provided as command line argument
if not "%~1"=="" (
    set CUDA_VERSION=%~1
    echo 📋 Using CUDA version from command line: %CUDA_VERSION%
) else if not "%CUDA_VERSION%"=="" (
    echo 📋 Using CUDA version from environment: %CUDA_VERSION%
) else (
    REM Try to detect CUDA version automatically
    call :detect_cuda_version
    if "!CUDA_VERSION!"=="" (
        REM Default fallback
        set CUDA_VERSION=cu128
        echo ⚠️ Could not detect CUDA version, using default: %CUDA_VERSION%
    ) else (
        echo 🔍 Detected CUDA version: !CUDA_VERSION!
    )
)
set LIBTORCH_DIR=libtorch
set LIBTORCH_ZIP=libtorch-%LIBTORCH_VERSION%-%CUDA_VERSION%-win.zip

REM Validate CUDA version and set download URL
call :validate_cuda_version
if errorlevel 1 exit /b 1

REM LibTorch download URL for Windows
set LIBTORCH_URL=https://download.pytorch.org/libtorch/%CUDA_VERSION%/libtorch-win-shared-with-deps-%LIBTORCH_VERSION%%%2B%CUDA_VERSION%.zip

echo === LibTorch Setup for Windows ===
echo Version: %LIBTORCH_VERSION%
echo CUDA: %CUDA_VERSION%
echo.

REM Check if LibTorch already exists and is valid
if exist "%LIBTORCH_DIR%" (
    if exist "%LIBTORCH_DIR%\lib\torch.lib" (
        echo ✅ LibTorch directory already exists and appears valid.
        echo Current LibTorch: %LIBTORCH_DIR%
        echo 💡 Delete the directory if you want to re-download: rmdir /s "%LIBTORCH_DIR%"
        goto :end
    ) else (
        echo ⚠️ LibTorch directory exists but appears incomplete. Removing and re-downloading...
        rmdir /s /q "%LIBTORCH_DIR%" 2>nul
    )
)

REM Check if zip already exists
if exist "%LIBTORCH_ZIP%" (
    echo 📦 Found existing LibTorch zip file: %LIBTORCH_ZIP%
    goto :extract
) else (
    echo 📥 LibTorch zip not found, will download: %LIBTORCH_ZIP%
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

REM Clean up any incomplete extraction
if exist "%LIBTORCH_DIR%" (
    echo 🧹 Cleaning up incomplete extraction...
    rmdir /s /q "%LIBTORCH_DIR%" 2>nul
)

REM Try PowerShell Expand-Archive first, fallback to other methods if it fails
powershell -Command "try { Import-Module Microsoft.PowerShell.Archive -Force; Expand-Archive -Path '%LIBTORCH_ZIP%' -DestinationPath '.' -Force; exit 0 } catch { exit 1 }" >nul 2>&1

if errorlevel 1 (
    echo ⚠️ PowerShell Expand-Archive failed, trying alternative extraction method...
    
    REM Try using PowerShell with .NET classes as fallback
    powershell -Command "Add-Type -AssemblyName System.IO.Compression.FileSystem; [System.IO.Compression.ZipFile]::ExtractToDirectory('%LIBTORCH_ZIP%', '.')" >nul 2>&1
    
    if errorlevel 1 (
        echo ⚠️ .NET extraction failed, trying 7-Zip or WinRAR...
        
        REM Try 7-Zip if available
        where 7z >nul 2>&1
        if not errorlevel 1 (
            7z x "%LIBTORCH_ZIP%" -y >nul
        ) else (
            REM Try WinRAR if available
            where winrar >nul 2>&1
            if not errorlevel 1 (
                winrar x "%LIBTORCH_ZIP%" >nul
            ) else (
                echo ❌ Extraction failed. Please install 7-Zip, WinRAR, or ensure PowerShell modules are available.
                echo 💡 You can manually extract %LIBTORCH_ZIP% to the current directory.
                exit /b 1
            )
        )
    )
)

REM Verify extraction was successful
if exist "%LIBTORCH_DIR%\lib\torch.lib" (
    echo ✅ LibTorch extracted successfully!
    echo 📁 LibTorch location: %cd%\%LIBTORCH_DIR%
) else (
    echo ❌ LibTorch extraction appears to have failed - torch.lib not found.
    echo 💡 Please check if the zip file is corrupted or try manual extraction.
    exit /b 1
)

:end
echo.
echo 🎉 Setup completed! You can now run:
echo    build.bat --run
echo.
goto :eof

:validate_cuda_version
REM Function to validate CUDA version is supported by PyTorch 2.7.0
set VALID_CUDA=0

REM Check if CUDA version is supported (PyTorch 2.7.0 supports: cu118, cu124, cu126, cu128)
if "%CUDA_VERSION%"=="cu118" set VALID_CUDA=1
if "%CUDA_VERSION%"=="cu124" set VALID_CUDA=1
if "%CUDA_VERSION%"=="cu126" set VALID_CUDA=1
if "%CUDA_VERSION%"=="cu128" set VALID_CUDA=1
if "%CUDA_VERSION%"=="cpu" set VALID_CUDA=1

if %VALID_CUDA%==0 (
    echo ❌ Error: CUDA version '%CUDA_VERSION%' is not supported by PyTorch %LIBTORCH_VERSION%
    echo.
    echo 📋 Supported CUDA versions for PyTorch %LIBTORCH_VERSION%:
    echo    • cu118 ^(CUDA 11.8^)
    echo    • cu124 ^(CUDA 12.4^)
    echo    • cu126 ^(CUDA 12.6^)
    echo    • cu128 ^(CUDA 12.8^)
    echo    • cpu   ^(CPU-only^)
    echo.
    echo 💡 To use a specific version, run:
    echo    setup.bat cu128
    echo.
    exit /b 1
)

echo ✅ CUDA version '%CUDA_VERSION%' is supported by PyTorch %LIBTORCH_VERSION%
goto :eof 

:detect_cuda_version
REM Function to detect CUDA version
set CUDA_VERSION=

REM Check if nvcc is available and get version
where nvcc >nul 2>&1
if %errorlevel% equ 0 (
    for /f "tokens=5" %%i in ('nvcc --version ^| findstr "release"') do (
        set NVCC_VERSION=%%i
    )
    
    REM Convert NVCC version to PyTorch CUDA version format (supported versions for PyTorch 2.7.0)
    if "!NVCC_VERSION!"=="12.8," set CUDA_VERSION=cu128
    if "!NVCC_VERSION!"=="12.7," set CUDA_VERSION=cu128
    if "!NVCC_VERSION!"=="12.6," set CUDA_VERSION=cu126
    if "!NVCC_VERSION!"=="12.5," set CUDA_VERSION=cu126
    if "!NVCC_VERSION!"=="12.4," set CUDA_VERSION=cu124
    if "!NVCC_VERSION!"=="12.3," set CUDA_VERSION=cu124
    if "!NVCC_VERSION!"=="12.2," set CUDA_VERSION=cu124
    if "!NVCC_VERSION!"=="12.1," set CUDA_VERSION=cu124
    if "!NVCC_VERSION!"=="12.0," set CUDA_VERSION=cu124
    if "!NVCC_VERSION!"=="11.8," set CUDA_VERSION=cu118
    if "!NVCC_VERSION!"=="11.7," set CUDA_VERSION=cu118
    if "!NVCC_VERSION!"=="11.6," set CUDA_VERSION=cu118
)

REM If nvcc detection failed, try checking CUDA_PATH
if "!CUDA_VERSION!"=="" (
    if not "%CUDA_PATH%"=="" (
        REM Extract version from CUDA_PATH (e.g., C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v12.4)
        for %%i in ("%CUDA_PATH%") do set CUDA_DIR=%%~nxi
        if "!CUDA_DIR!"=="v12.8" set CUDA_VERSION=cu128
        if "!CUDA_DIR!"=="v12.7" set CUDA_VERSION=cu128
        if "!CUDA_DIR!"=="v12.6" set CUDA_VERSION=cu126
        if "!CUDA_DIR!"=="v12.5" set CUDA_VERSION=cu126
        if "!CUDA_DIR!"=="v12.4" set CUDA_VERSION=cu124
        if "!CUDA_DIR!"=="v12.3" set CUDA_VERSION=cu124
        if "!CUDA_DIR!"=="v12.2" set CUDA_VERSION=cu124
        if "!CUDA_DIR!"=="v12.1" set CUDA_VERSION=cu124
        if "!CUDA_DIR!"=="v12.0" set CUDA_VERSION=cu124
        if "!CUDA_DIR!"=="v11.8" set CUDA_VERSION=cu118
        if "!CUDA_DIR!"=="v11.7" set CUDA_VERSION=cu118
        if "!CUDA_DIR!"=="v11.6" set CUDA_VERSION=cu118
    )
)

goto :eof 