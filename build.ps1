# PowerShell build script for Windows
param(
    [switch]$Run,
    [switch]$Clean,
    [string]$Config = "Release"
)

$PROJECT_NAME = "torch_project"
$BUILD_DIR = "build"
$LIBTORCH_DIR = "libtorch"

Write-Host "=== C++ PyTorch Build Script (PowerShell) ===" -ForegroundColor Cyan

# Check if LibTorch exists
if (-not (Test-Path $LIBTORCH_DIR)) {
    Write-Host "❌ LibTorch not found. Run setup.bat or setup.ps1 first." -ForegroundColor Red
    exit 1
}

# Clean build directory if requested
if ($Clean -or (Test-Path $BUILD_DIR)) {
    Write-Host "🧹 Cleaning build directory..." -ForegroundColor Yellow
    if (Test-Path $BUILD_DIR) {
        Remove-Item -Recurse -Force $BUILD_DIR
    }
}

# Create build directory
Write-Host "📁 Creating build directory..." -ForegroundColor Green
New-Item -ItemType Directory -Force -Path $BUILD_DIR | Out-Null

# CMake configuration
Write-Host "⚙️ Running CMake configuration..." -ForegroundColor Blue
Push-Location $BUILD_DIR

$TorchDir = Join-Path (Get-Location).Path "..\$LIBTORCH_DIR\share\cmake\Torch"
$cmakeArgs = @(
    "-DTorch_DIR=`"$TorchDir`"",
    "..",
    "-G", "Visual Studio 17 2022",
    "-A", "x64"
)

& cmake @cmakeArgs
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ CMake configuration failed" -ForegroundColor Red
    Pop-Location
    exit 1
}

# Build
Write-Host "🔨 Building project..." -ForegroundColor Blue
& cmake --build . --config $Config --parallel
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Build failed" -ForegroundColor Red
    Pop-Location
    exit 1
}

Write-Host "✅ Build completed successfully!" -ForegroundColor Green

# Test run
if ($Run) {
    Write-Host "🚀 Running executable..." -ForegroundColor Magenta
    $exePath = Join-Path $Config "$PROJECT_NAME.exe"
    if (Test-Path $exePath) {
        & $exePath
    } else {
        Write-Host "❌ Executable not found: $exePath" -ForegroundColor Red
        Pop-Location
        exit 1
    }
}

Pop-Location
Write-Host "🎉 All done!" -ForegroundColor Green 