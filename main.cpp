#include <torch/torch.h>
#include <iostream>
#include <chrono>

int main() {
    std::cout << "=== PyTorch C++ with CUDA Demo ===" << std::endl;
    
    // Check CUDA availability
    if (torch::cuda::is_available()) {
        std::cout << "CUDA is available! Device count: " << torch::cuda::device_count() << std::endl;
    } else {
        std::cout << "CUDA is not available. Running on CPU." << std::endl;
    }
    
    // Create tensors on CPU
    std::cout << "\n--- CPU Operations ---" << std::endl;
    torch::Tensor cpu_tensor = torch::rand({3, 4});
    std::cout << "Random CPU tensor:\n" << cpu_tensor << std::endl;
    
    torch::Tensor cpu_ones = torch::ones({3, 4});
    torch::Tensor cpu_sum = cpu_tensor + cpu_ones;
    std::cout << "CPU tensor after adding ones:\n" << cpu_sum << std::endl;
    
    // CUDA operations if available
    if (torch::cuda::is_available()) {
        std::cout << "\n--- CUDA Operations ---" << std::endl;
        
        // Move tensors to GPU
        torch::Device cuda_device(torch::kCUDA, 0);
        torch::Tensor cuda_tensor = cpu_tensor.to(cuda_device);
        torch::Tensor cuda_ones = torch::ones({3, 4}, cuda_device);
        
        std::cout << "Tensor moved to CUDA device: " << cuda_tensor.device() << std::endl;
        
        // Perform operations on GPU
        torch::Tensor cuda_result = cuda_tensor * 2.0 + cuda_ones;
        
        // Move result back to CPU for display
        torch::Tensor result_cpu = cuda_result.to(torch::kCPU);
        std::cout << "CUDA computation result (moved back to CPU):\n" << result_cpu << std::endl;
        
        // Matrix multiplication example
        torch::Tensor a = torch::randn({1000, 1000}, cuda_device);
        torch::Tensor b = torch::randn({1000, 1000}, cuda_device);
        
        auto start = std::chrono::high_resolution_clock::now();
        torch::Tensor c = torch::mm(a, b);
        auto end = std::chrono::high_resolution_clock::now();
        
        auto duration = std::chrono::duration_cast<std::chrono::milliseconds>(end - start);
        std::cout << "CUDA matrix multiplication (1000x1000) took: " << duration.count() << " ms" << std::endl;
    }
    
    std::cout << "\n=== Demo completed successfully! ===" << std::endl;
    return 0;
} 