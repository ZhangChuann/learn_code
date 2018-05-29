#include<stdio.h>
#include<stdlib.h>
#include<time.h>
#include "../init_cuda.h"

//cuda runtime api
#include<cuda_runtime.h>
#define DATA_SIZE   1048576
int data[DATA_SIZE];
void GenerateNumber(int *number, int size)
{
    for(int i=0;i<size;i++)
    {
        number[i] = rand()%10;
    }
}

//global fun

__global__ void sumOfSquares(int *num, int *result, clock_t* time)
{
    int sum=0;
    printf("gpu test");
    printf("sum:%d\n", *result);
    int i;
    clock_t start = clock();
    for(i=0;i<DATA_SIZE;i++){
        printf("hh");
        sum+=num[i]*num[i]*num[i];
    }

    *result = sum;
    printf("sum gpu print:%d\n", *result);
    *time = clock() - start;
}

int main()
{
    if(!InitCuda())
        return 0;

    GenerateNumber(data, DATA_SIZE);

    int* gpudata, *result;
    clock_t *time;
    cudaMalloc((void**)&gpudata, sizeof(int)*DATA_SIZE);
    cudaMalloc((void**)&result, sizeof(int));
    cudaMalloc((void**)&time, sizeof(int));
    cudaMemcpy(gpudata, data, sizeof(int)*DATA_SIZE, cudaMemcpyHostToDevice);
    sumOfSquares<<<1, 1, 0>>>(gpudata, result, time);
    int sum;
    clock_t time_used;
    cudaMemcpy(&sum, result, sizeof(int), cudaMemcpyDeviceToHost);
    cudaMemcpy(&time_used, time, sizeof(clock_t), cudaMemcpyDeviceToHost);
    cudaFree(gpudata);
    cudaFree(result);
    cudaFree(time);

    printf("GPUsum: %d time: %d\n", sum, time_used);

    sum = 0;

    for (int i = 0; i < DATA_SIZE; i++) {
        sum += data[i] * data[i] * data[i];
    }

    printf("CPUsum: %d \n", sum);

    return 0;
}

