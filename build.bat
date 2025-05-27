@echo off
setlocal enabledelayedexpansion

echo === C++ PyTorch Build Script ===

call :find_cmake
if %errorlevel% neq 0 (
    echo ERROR: CMake not found
    exit /b 1
)

echo SUCCESS: Found CMake at %CMAKE_EXE%

if not exist "libtorch" (
    echo ERROR: LibTorch not found. Run setup.bat first.
    exit /b 1
)

echo SUCCESS: Found LibTorch

echo INFO: Cleaning build directory...
if exist "build" rmdir /s /q "build"
mkdir "build"

echo INFO: Running CMake configuration...
cd "build"

"%CMAKE_EXE%" -DTorch_DIR="%cd%\..\libtorch\share\cmake\Torch" .. -G "Visual Studio 17 2022" -A x64
if %errorlevel% neq 0 (
    echo ERROR: CMake configuration failed
    cd ..
    exit /b 1
)

echo INFO: Building project...
"%CMAKE_EXE%" --build . --config Release --parallel
if %errorlevel% neq 0 (
    echo ERROR: Build failed
    cd ..
    exit /b 1
)

echo SUCCESS: Build completed!

if "%1"=="--run" (
    echo INFO: Running executable...
    Release\torch_project.exe
)

echo SUCCESS: All done!
cd ..
goto :eof

:find_cmake
set CMAKE_EXE=

where cmake >nul 2>&1
if %errorlevel% equ 0 (
    set CMAKE_EXE=cmake
    exit /b 0
)

set "PATH=%PATH%;C:\Program Files\CMake\bin"

where cmake >nul 2>&1
if %errorlevel% equ 0 (
    set CMAKE_EXE=cmake
    exit /b 0
)

if exist "C:\Program Files\CMake\bin\cmake.exe" (
    set CMAKE_EXE="C:\Program Files\CMake\bin\cmake.exe"
    exit /b 0
)

exit /b 1 