# Project configuration
PROJECT_NAME = torch_project
BUILD_DIR = build
LIBTORCH_DIR = libtorch
LIBTORCH_VERSION = 2.5.1
CUDA_VERSION = cu124

# LibTorch download URL for Linux with CUDA 12.4
LIBTORCH_URL = https://download.pytorch.org/libtorch/cu124/libtorch-cxx11-abi-shared-with-deps-$(LIBTORCH_VERSION)%2B$(CUDA_VERSION).zip
LIBTORCH_ZIP = libtorch-$(LIBTORCH_VERSION)-$(CUDA_VERSION).zip

# Compiler settings
CXX = g++
CXXFLAGS = -std=c++17 -O3 -Wall
CUDA_FLAGS = -DWITH_CUDA

# Default target
.PHONY: all
all: setup build

# Help target
.PHONY: help
help:
	@echo "Available targets:"
	@echo "  all          - Setup LibTorch and build project (default)"
	@echo "  setup        - Download and extract LibTorch"
	@echo "  build        - Build the project using CMake"
	@echo "  run          - Run the compiled executable"
	@echo "  clean        - Clean build directory"
	@echo "  clean-all    - Clean build directory and LibTorch"
	@echo "  info         - Show project information"

# Setup LibTorch
.PHONY: setup
setup: $(LIBTORCH_DIR)

$(LIBTORCH_DIR): $(LIBTORCH_ZIP)
	@echo "Extracting LibTorch..."
	unzip -q $(LIBTORCH_ZIP)
	@echo "LibTorch extracted successfully!"

$(LIBTORCH_ZIP):
	@echo "Downloading LibTorch $(LIBTORCH_VERSION) with CUDA $(CUDA_VERSION)..."
	@echo "URL: $(LIBTORCH_URL)"
	wget -O $(LIBTORCH_ZIP) "$(LIBTORCH_URL)"
	@echo "Download completed!"

# Build project
.PHONY: build
build: $(BUILD_DIR)/$(PROJECT_NAME)

$(BUILD_DIR)/$(PROJECT_NAME): $(LIBTORCH_DIR) main.cpp CMakeLists.txt
	@echo "Building project..."
	mkdir -p $(BUILD_DIR)
	@echo "Running CMake configuration..."
	cd $(BUILD_DIR) && cmake -DTorch_DIR="$$(pwd)/../$(LIBTORCH_DIR)/share/cmake/Torch" ..
	@echo "Running CMake build..."
	cd $(BUILD_DIR) && cmake --build . --parallel 4
	@echo "Build completed!"

# Run the executable
.PHONY: run
run: $(BUILD_DIR)/$(PROJECT_NAME)
	@echo "Running $(PROJECT_NAME)..."
	cd $(BUILD_DIR) && ./$(PROJECT_NAME)

# Clean build directory
.PHONY: clean
clean:
	@echo "Cleaning build directory..."
	rm -rf $(BUILD_DIR)

# Clean everything including LibTorch
.PHONY: clean-all
clean-all: clean
	@echo "Cleaning LibTorch..."
	rm -rf $(LIBTORCH_DIR) $(LIBTORCH_ZIP)

# Show project information
.PHONY: info
info:
	@echo "Project: $(PROJECT_NAME)"
	@echo "LibTorch Version: $(LIBTORCH_VERSION)"
	@echo "CUDA Version: $(CUDA_VERSION)"
	@echo "Build Directory: $(BUILD_DIR)"
	@echo "LibTorch Directory: $(LIBTORCH_DIR)"
	@echo ""
	@echo "CUDA Compiler:"
	@nvcc --version 2>/dev/null || echo "CUDA not found"
	@echo ""
	@echo "CMake Version:"
	@cmake --version | head -1

# Force rebuild
.PHONY: rebuild
rebuild: clean build

# Development target - quick build without setup
.PHONY: dev
dev:
	@if [ ! -d "$(LIBTORCH_DIR)" ]; then \
		echo "LibTorch not found. Run 'make setup' first."; \
		exit 1; \
	fi
	mkdir -p $(BUILD_DIR)
	@echo "Running CMake configuration..."
	cd $(BUILD_DIR) && cmake -DTorch_DIR="$$(pwd)/../$(LIBTORCH_DIR)/share/cmake/Torch" ..
	@echo "Running CMake build..."
	cd $(BUILD_DIR) && cmake --build . --parallel 4
	@echo "Development build completed!" 