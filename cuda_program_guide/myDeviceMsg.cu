#include "cuda_runtime.h"  
#include "device_launch_parameters.h"  
#include<iostream>  
#include <stdio.h>  
using namespace std;  
cudaError_t addWithCuda(int *c, const int *a, const int *b, size_t size);  
  
__global__ void addKernel(int *c, const int *a, const int *b)  
{  
    int i = threadIdx.x;  
    c[i] = a[i] + b[i];  
}  
  
int main()  
{  
    const int arraySize = 5;  
    const int a[arraySize] = { 1, 2, 3, 4, 5 };  
    const int b[arraySize] = { 10, 20, 30, 40, 50 };  
    int c[arraySize] = { 0 };  
 
    //get device prop
    cudaError_t cudaStatus;
    int num = 0;
    cudaDeviceProp deviceProp;
    cudaStatus = cudaGetDeviceCount(&num);
    for(int i=0;i<num;i++)
    {
        cudaGetDeviceProperties(&deviceProp, i);
        cout << "设备 " << i + 1 << " 的主要属性： " << endl;  
        cout << "设备显卡型号： " << deviceProp.name << endl; 
 
        printf("maxGridSize:%d,%d,%d\n",deviceProp.maxGridSize[0],deviceProp.maxGridSize[1],deviceProp.maxGridSize[2]);
        printf("maxThreadDim:%d,%d,%d\n",deviceProp.maxThreadsDim[0],deviceProp.maxThreadsDim[1],deviceProp.maxThreadsDim[2]);
        printf("warpSize:%d\n",deviceProp.warpSize);
        printf("constanMemory:%d(K)\n",deviceProp.totalConstMem/1024);

        cout << "设备全局内存总量（以MB为单位）： " << deviceProp.totalGlobalMem / 1024 / 1024 << endl;  
        cout << "设备上一个线程块（Block）中可用的最大共享内存（以KB为单位）： " << deviceProp.sharedMemPerBlock / 1024 << endl;  
        cout << "设备上一个线程块（Block）种可用的32位寄存器数量： " << deviceProp.regsPerBlock << endl;  
        cout << "设备上一个线程块（Block）可包含的最大线程数量： " << deviceProp.maxThreadsPerBlock << endl;  
        cout << "设备的计算功能集（Compute Capability）的版本号： " << deviceProp.major << "." << deviceProp.minor << endl;  
        cout << "设备上多处理器的数量： " << deviceProp.multiProcessorCount << endl; 
    }
    return 0;  
}  
  
// Helper function for using CUDA to add vectors in parallel.  
cudaError_t addWithCuda(int *c, const int *a, const int *b, size_t size)  
{  
    int *dev_a = 0;  
    int *dev_b = 0;  
    int *dev_c = 0;  
    cudaError_t cudaStatus;  
  
    // Choose which GPU to run on, change this on a multi-GPU system.  
    cudaStatus = cudaSetDevice(0);  
    if (cudaStatus != cudaSuccess) {  
        fprintf(stderr, "cudaSetDevice failed!  Do you have a CUDA-capable GPU installed?");  
        goto Error;  
    }  
  
    // Allocate GPU buffers for three vectors (two input, one output)    .  
    cudaStatus = cudaMalloc((void**)&dev_c, size * sizeof(int));  
    if (cudaStatus != cudaSuccess) {  
        fprintf(stderr, "cudaMalloc failed!");  
        goto Error;  
    }  
  
    cudaStatus = cudaMalloc((void**)&dev_a, size * sizeof(int));  
    if (cudaStatus != cudaSuccess) {  
        fprintf(stderr, "cudaMalloc failed!");  
        goto Error;  
    }  
  
    cudaStatus = cudaMalloc((void**)&dev_b, size * sizeof(int));  
    if (cudaStatus != cudaSuccess) {  
        fprintf(stderr, "cudaMalloc failed!");  
        goto Error;  
    }  
  
    // Copy input vectors from host memory to GPU buffers.  
    cudaStatus = cudaMemcpy(dev_a, a, size * sizeof(int), cudaMemcpyHostToDevice);  
    if (cudaStatus != cudaSuccess) {  
        fprintf(stderr, "cudaMemcpy failed!");  
        goto Error;  
    }  
  
    cudaStatus = cudaMemcpy(dev_b, b, size * sizeof(int), cudaMemcpyHostToDevice);  
    if (cudaStatus != cudaSuccess) {  
        fprintf(stderr, "cudaMemcpy failed!");  
        goto Error;  
    }  
  
    // Launch a kernel on the GPU with one thread for each element.  
    addKernel<<<1, size>>>(dev_c, dev_a, dev_b);  
  
    // cudaThreadSynchronize waits for the kernel to finish, and returns  
    // any errors encountered during the launch.  
    cudaStatus = cudaThreadSynchronize();  
    if (cudaStatus != cudaSuccess) {  
        fprintf(stderr, "cudaThreadSynchronize returned error code %d after launching addKernel!\n", cudaStatus);  
        goto Error;  
    }  
  
    // Copy output vector from GPU buffer to host memory.  
    cudaStatus = cudaMemcpy(c, dev_c, size * sizeof(int), cudaMemcpyDeviceToHost);  
    if (cudaStatus != cudaSuccess) {  
        fprintf(stderr, "cudaMemcpy failed!");  
        goto Error;  
    }  
  
Error:  
    cudaFree(dev_c);  
    cudaFree(dev_a);  
    cudaFree(dev_b);  
      
    return cudaStatus;  
}  
