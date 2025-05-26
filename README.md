# C++ PyTorch Project with Self-Contained LibTorch

A cross-platform C++ project that demonstrates PyTorch functionality with automatic LibTorch setup and CUDA support.

## Features

- 🚀 Automatic LibTorch download and setup
- 🎯 CUDA 12.4 support
- 🛠️ Cross-platform automation (Linux & Windows)
- 📦 Self-contained (no system PyTorch dependency)
- ⚡ CPU and GPU tensor operations
- 🖥️ Support for Linux, Windows, and macOS

## Prerequisites

### Linux/macOS
- CMake (version 3.18 or higher)
- C++ compiler with C++17 support (GCC 7+ or Clang 5+)
- CUDA 12.4 (for GPU support)
- wget and unzip utilities

### Windows
- CMake (version 3.18 or higher)
- Visual Studio 2019 or 2022 with C++ support
- CUDA 12.4 (for GPU support)
- PowerShell (for scripts)

## Quick Start

### Linux/macOS
The easiest way to get started is using the provided Makefile:

```bash
# Download LibTorch, build, and run the project
make all

# Or step by step:
make setup    # Download and extract LibTorch
make build    # Build the project
make run      # Run the executable
```

### Windows
Use the provided batch scripts:

```cmd
# Download and setup LibTorch
setup.bat

# Build and run the project
build.bat --run
```

Or use PowerShell (recommended):

```powershell
# Setup LibTorch
.\setup.ps1

# Build and run with PowerShell
.\build.ps1 -Run
```

## Makefile Commands

| Command | Description |
|---------|-------------|
| `make all` | Setup LibTorch and build project (default) |
| `make setup` | Download and extract LibTorch |
| `make build` | Build the project using CMake |
| `make run` | Run the compiled executable |
| `make clean` | Clean build directory |
| `make clean-all` | Clean build directory and LibTorch |
| `make info` | Show project information |
| `make rebuild` | Clean and rebuild |
| `make dev` | Quick build (assumes LibTorch is already setup) |
| `make help` | Show all available commands |

## Alternative Build Scripts

### Linux/macOS
If you experience hanging issues with the Makefile, use the provided build script:

```bash
# Build with timeout protection
./build.sh

# Build and run
./build.sh --run
```

### Windows
Multiple options available:

```cmd
# Batch script
build.bat --run
```

```powershell
# PowerShell script with more options
.\build.ps1 -Run -Clean          # Clean build and run
.\build.ps1 -Config Debug        # Debug build
```

The build scripts include:
- ⏱️ Timeout protection (Linux/macOS)
- 🔄 Parallel compilation using all CPU cores
- 📊 Progress indicators
- ❌ Better error handling
- 🖥️ Platform-specific optimizations

## Manual Build (Alternative)

### Linux/macOS
If you prefer manual control:

```bash
# Download LibTorch manually
wget https://download.pytorch.org/libtorch/cu124/libtorch-cxx11-abi-shared-with-deps-2.5.1%2Bcu124.zip
unzip libtorch-cxx11-abi-shared-with-deps-2.5.1+cu124.zip

# Build with CMake
mkdir build
cd build
cmake -DTorch_DIR="../libtorch/share/cmake/Torch" ..
cmake --build . --parallel

# Run
./torch_project
```

### Windows
```cmd
# Download LibTorch manually (use browser or PowerShell)
# URL: https://download.pytorch.org/libtorch/cu124/libtorch-win-shared-with-deps-2.5.1%2Bcu124.zip

# Extract and build
mkdir build
cd build
cmake -DTorch_DIR="../libtorch/share/cmake/Torch" .. -G "Visual Studio 17 2022" -A x64
cmake --build . --config Release --parallel

# Run
Release\torch_project.exe
```

## Project Structure

```
.
├── main.cpp           # Main program with CPU/CUDA demos
├── CMakeLists.txt     # Cross-platform CMake configuration
├── Makefile          # Linux/macOS automation scripts
├── build.sh           # Linux/macOS build script
├── setup.bat          # Windows setup script
├── setup.ps1          # PowerShell setup script  
├── build.bat          # Windows build script
├── build.ps1          # PowerShell build script
├── README.md         # This file
├── .gitignore        # Git ignore rules
├── build/            # Build directory (created automatically)
└── libtorch/         # LibTorch installation (downloaded automatically)
```

## Configuration

You can customize the LibTorch version and CUDA version:

### Linux/macOS (Makefile)
```makefile
LIBTORCH_VERSION = 2.5.1
CUDA_VERSION = cu124
```

### Windows (setup.bat)
```batch
set LIBTORCH_VERSION=2.5.1
set CUDA_VERSION=cu124
```

### Windows (setup.ps1)
```powershell
.\setup.ps1 -Version "2.5.1" -CudaVersion "cu124"
```

Available CUDA versions:
- `cu124` - CUDA 12.4
- `cu121` - CUDA 12.1
- `cpu` - CPU only

**Note:** Windows and Linux use different LibTorch packages, so the URLs are automatically adjusted per platform.

## Platform Differences

| Feature | Linux/macOS | Windows |
|---------|-------------|---------|
| **Setup** | `make setup` or `./build.sh` | `setup.bat` or `.\setup.ps1` |
| **Build** | `make build` | `build.bat` or `.\build.ps1` |
| **Executable** | `./torch_project` | `Release\torch_project.exe` |
| **LibTorch Package** | `libtorch-cxx11-abi-shared-with-deps` | `libtorch-win-shared-with-deps` |
| **Compiler** | GCC/Clang | MSVC (Visual Studio) |
| **Build System** | Make + CMake | CMake + MSBuild |

## Windows Script Comparison

| Feature | setup.bat | setup.ps1 | build.bat | build.ps1 |
|---------|-----------|-----------|-----------|-----------|
| **Purpose** | Setup LibTorch | Setup LibTorch | Build project | Build project |
| **Language** | Batch | PowerShell | Batch | PowerShell |
| **Error Handling** | Basic | Advanced | Basic | Advanced |
| **Colored Output** | No | Yes | No | Yes |
| **Parameters** | Fixed | Configurable | Basic | Advanced |
| **Recommended** | ✅ Simple | ⭐ Best | ✅ Simple | ⭐ Best |

## Example Output

When you run the project, you should see output similar to:

```
=== PyTorch C++ with CUDA Demo ===
CUDA is available! Device count: 1

--- CPU Operations ---
Random CPU tensor:
 0.1234  0.5678  0.9012  0.3456
 0.7890  0.2345  0.6789  0.0123
 0.4567  0.8901  0.2345  0.6789
[ CPUFloatType{3,4} ]

--- CUDA Operations ---
Tensor moved to CUDA device: cuda:0
CUDA computation result (moved back to CPU):
 1.2468  2.1356  2.8024  1.6912
 2.5780  1.4690  2.3578  1.0246
 1.9134  2.7802  1.4690  2.3578
[ CPUFloatType{3,4} ]

CUDA matrix multiplication (1000x1000) took: 15 ms

=== Demo completed successfully! ===
```

## Troubleshooting

### CUDA Not Found
If CUDA is not detected, ensure:
1. NVIDIA drivers are installed
2. CUDA 12.4 is installed
3. `nvcc --version` works

### Download Issues
If LibTorch download fails:
1. Check internet connection
2. Verify the download URL in the Makefile
3. Try downloading manually

### Build Issues
If compilation fails:
1. Ensure CMake version ≥ 3.18
2. Check C++17 compiler support
3. Verify LibTorch was extracted correctly

### Build Hanging
**Linux/macOS:**
If `make build` hangs:
1. Use the alternative build script: `./build.sh`
2. Check system resources (RAM/CPU usage)
3. Try building with fewer parallel jobs: `cmake --build . --parallel 2`
4. Increase timeout in build.sh if needed

**Windows:**
If build hangs:
1. Use `build.bat` instead of manual CMake
2. Try building with fewer parallel jobs: `cmake --build . --parallel 2`
3. Check Visual Studio installation and CUDA toolkit
4. Use PowerShell script for better error reporting: `.\build.ps1 -Run`

### Windows-Specific Issues

**Visual Studio Not Found:**
- Ensure Visual Studio 2019 or 2022 is installed with C++ development tools
- Install "MSVC v143 - VS 2022 C++ x64/x86 build tools"
- Install "Windows 10/11 SDK"

**PowerShell Execution Policy:**
If PowerShell scripts are blocked:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

**DLL Issues:**
If you get DLL errors when running:
1. Ensure CUDA is in your PATH
2. The build script automatically copies required DLLs
3. Try running from the build directory: `cd build\Release && torch_project.exe` 