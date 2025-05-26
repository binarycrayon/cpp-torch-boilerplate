# PowerShell setup script for Windows - Downloads and extracts LibTorch
param(
    [string]$Version = "2.5.1",
    [string]$CudaVersion = "cu124"
)

$LIBTORCH_DIR = "libtorch"
$LIBTORCH_ZIP = "libtorch-$Version-$CudaVersion-win.zip"
$LIBTORCH_URL = "https://download.pytorch.org/libtorch/$CudaVersion/libtorch-win-shared-with-deps-$Version%2B$CudaVersion.zip"

Write-Host "=== LibTorch Setup for Windows (PowerShell) ===" -ForegroundColor Cyan
Write-Host "Version: $Version" -ForegroundColor Green
Write-Host "CUDA: $CudaVersion" -ForegroundColor Green
Write-Host ""

# Check if LibTorch already exists
if (Test-Path $LIBTORCH_DIR) {
    Write-Host "⚠️ LibTorch directory already exists. Delete it first if you want to re-download." -ForegroundColor Yellow
    Write-Host "Current LibTorch: $(Get-Location)\$LIBTORCH_DIR" -ForegroundColor Yellow
    return
}

# Check if zip already exists
if (Test-Path $LIBTORCH_ZIP) {
    Write-Host "📦 Found existing LibTorch zip file: $LIBTORCH_ZIP" -ForegroundColor Green
} else {
    # Download LibTorch
    Write-Host "📥 Downloading LibTorch $Version with CUDA $CudaVersion..." -ForegroundColor Blue
    Write-Host "URL: $LIBTORCH_URL" -ForegroundColor Gray
    Write-Host ""

    try {
        # Use TLS 1.2 for compatibility
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        
        # Download with progress
        $webClient = New-Object System.Net.WebClient
        $webClient.DownloadFile($LIBTORCH_URL, $LIBTORCH_ZIP)
        
        Write-Host "✅ Download completed!" -ForegroundColor Green
    }
    catch {
        Write-Host "❌ Download failed: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "Please check your internet connection and try again." -ForegroundColor Red
        exit 1
    }
}

# Extract LibTorch
Write-Host "📂 Extracting LibTorch..." -ForegroundColor Blue
try {
    Expand-Archive -Path $LIBTORCH_ZIP -DestinationPath "." -Force
    Write-Host "✅ LibTorch extracted successfully!" -ForegroundColor Green
    Write-Host "📁 LibTorch location: $(Get-Location)\$LIBTORCH_DIR" -ForegroundColor Green
}
catch {
    Write-Host "❌ Extraction failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "🎉 Setup completed! You can now run:" -ForegroundColor Cyan
Write-Host "   build.bat --run" -ForegroundColor White
Write-Host "   or" -ForegroundColor Gray
Write-Host "   .\build.ps1 -Run" -ForegroundColor White
Write-Host "" 