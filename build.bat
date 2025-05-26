@echo off
setlocal enabledelayedexpansion

REM Build script for Windows with timeout and progress monitoring
set PROJECT_NAME=torch_project
set BUILD_DIR=build
set LIBTORCH_DIR=libtorch
set TIMEOUT=300

echo === C++ PyTorch Build Script (Windows) ===

REM Check if LibTorch exists
if not exist "%LIBTORCH_DIR%" (
    echo ❌ LibTorch not found. Run setup.bat first.
    exit /b 1
)

REM Clean and create build directory
echo 🧹 Cleaning build directory...
if exist "%BUILD_DIR%" rmdir /s /q "%BUILD_DIR%"
mkdir "%BUILD_DIR%"

REM CMake configuration
echo ⚙️ Running CMake configuration...
cd "%BUILD_DIR%"

cmake -DTorch_DIR="%cd%\..\%LIBTORCH_DIR%\share\cmake\Torch" .. -G "Visual Studio 17 2022" -A x64
if errorlevel 1 (
    echo ❌ CMake configuration failed
    exit /b 1
)

REM Build
echo 🔨 Building project...
cmake --build . --config Release --parallel
if errorlevel 1 (
    echo ❌ Build failed
    exit /b 1
)

echo ✅ Build completed successfully!

REM Test run
if "%1"=="--run" (
    echo 🚀 Running executable...
    Release\%PROJECT_NAME%.exe
)

echo 🎉 All done!
cd .. 