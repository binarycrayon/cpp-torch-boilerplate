#!/bin/bash

# Build script with timeout and progress monitoring
set -e

PROJECT_NAME="torch_project"
BUILD_DIR="build"
LIBTORCH_DIR="libtorch"
TIMEOUT=300  # 5 minutes timeout

echo "=== C++ PyTorch Build Script ==="

# Check if LibTorch exists
if [ ! -d "$LIBTORCH_DIR" ]; then
    echo "❌ LibTorch not found. Run 'make setup' first."
    exit 1
fi

# Clean and create build directory
echo "🧹 Cleaning build directory..."
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

# CMake configuration with timeout
echo "⚙️  Running CMake configuration..."
cd "$BUILD_DIR"

timeout $TIMEOUT cmake -DTorch_DIR="$(pwd)/../$LIBTORCH_DIR/share/cmake/Torch" .. || {
    echo "❌ CMake configuration failed or timed out"
    exit 1
}

# Build with timeout and progress
echo "🔨 Building project..."
timeout $TIMEOUT cmake --build . --parallel $(nproc) || {
    echo "❌ Build failed or timed out"
    exit 1
}

echo "✅ Build completed successfully!"

# Test run
if [ "$1" = "--run" ]; then
    echo "🚀 Running executable..."
    ./"$PROJECT_NAME"
fi

echo "🎉 All done!" 