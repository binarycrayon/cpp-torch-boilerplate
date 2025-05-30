cmake_minimum_required(VERSION 3.18 FATAL_ERROR)
project(torch_project LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Workaround for nvToolsExt issue with CUDA 12.x and PyTorch
# This addresses the "Failed to find nvToolsExt" error
find_package(CUDAToolkit QUIET)
if(CUDAToolkit_FOUND AND CUDAToolkit_VERSION VERSION_GREATER_EQUAL 12.0)
    message(STATUS "PyTorch NVTX headers workaround: Yes (CUDA ${CUDAToolkit_VERSION})")
    # Only do this if nvToolsExt is not defined and CUDA::nvtx3 exists
    if(NOT TARGET CUDA::nvToolsExt AND TARGET CUDA::nvtx3)
        add_library(CUDA::nvToolsExt INTERFACE IMPORTED)
        # Ensure that PyTorch is told to use NVTX3 headers
        target_compile_definitions(
            CUDA::nvToolsExt INTERFACE
            TORCH_CUDA_USE_NVTX3
        )
        target_link_libraries(CUDA::nvToolsExt INTERFACE CUDA::nvtx3)
    endif()
else()
    message(STATUS "PyTorch NVTX headers workaround: No")
endif()

# Find PyTorch package
find_package(Torch REQUIRED)

# Disable CUDA to avoid version conflicts
# Enable CUDA if available and found by Torch
# if(TORCH_CUDA_FOUND)
#     enable_language(CUDA)
#     set(CMAKE_CUDA_STANDARD 17)
# endif()

# Add executable
add_executable(${PROJECT_NAME} main.cpp)

# Link against PyTorch
target_link_libraries(${PROJECT_NAME} "${TORCH_LIBRARIES}")

# Set include directories
target_include_directories(${PROJECT_NAME} PRIVATE ${TORCH_INCLUDE_DIRS})

# Set compile definitions
target_compile_definitions(${PROJECT_NAME} PRIVATE ${TORCH_DEFINITIONS})

# Set C++ flags for PyTorch
set_property(TARGET ${PROJECT_NAME} PROPERTY CXX_STANDARD 17)

# Windows-specific configuration
if (WIN32)
    # Set the correct runtime library for Windows
    set_property(TARGET ${PROJECT_NAME} PROPERTY
                 MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>DLL")
    
    # The following code block is suggested to be used on Windows.
    # According to https://github.com/pytorch/pytorch/issues/25457,
    # the DLLs need to be copied to avoid memory errors.
    if (MSVC)
        file(GLOB TORCH_DLLS "${TORCH_INSTALL_PREFIX}/lib/*.dll")
        add_custom_command(TARGET ${PROJECT_NAME}
                           POST_BUILD
                           COMMAND ${CMAKE_COMMAND} -E copy_if_different
                           ${TORCH_DLLS}
                           $<TARGET_FILE_DIR:${PROJECT_NAME}>)
    endif (MSVC)
    
    # Add Windows-specific compile definitions
    target_compile_definitions(${PROJECT_NAME} PRIVATE 
        WIN32_LEAN_AND_MEAN
        NOMINMAX
    )
endif (WIN32) 