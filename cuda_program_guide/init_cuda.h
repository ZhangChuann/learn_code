#include <stdio.h>
#include <cuda_runtime.h>

//cuda init
bool InitCuda();
void printDeviceProp(const cudaDeviceProp &prop);
