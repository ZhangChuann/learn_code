#include<stdio.h>
#include<stdlib.h>
#include<time.h>
#include "../init_cuda.h"

//cuda runtime api
#include<cuda_runtime.h>
#define DATA_SIZE   1048576
#define BLOCK_NUM   64
#define THREAD_NUM  256
int data[DATA_SIZE];
void GenerateNumber(int *number, int size)
{
    for(int i=0;i<size;i++)
    {
        number[i] = rand()%10;
        number[i] = 1;
    }
}

//global fun
//cycle 24949315 
__global__ void sumOfSquares(int *num, int *result, clock_t* time)
{
    int sum=0;
    printf("gpu test");
    printf("sum:%d\n", *result);
    int i;
    clock_t start = clock();
    for(i=0;i<DATA_SIZE;i++){
        sum+=num[i]*num[i]*num[i];
    }

    *result = sum;
    printf("sum gpu print:%d\n", *result);
    *time = clock() - start;
    printf("time gpu print:%d\n", *time);
}
//tree sum
//cycle 75434
__global__ void sumOfSquares_tree(int *num, int *result, clock_t* time)
{
    extern __shared__ int shared_mem[];
    const int tid = threadIdx.x;
    const int bid = blockIdx.x;
    shared_mem[tid] = 0;
    int i=0;
    clock_t start = clock();
    if(tid==0) time[bid] = clock();

    for(i=bid*THREAD_NUM + tid; i< DATA_SIZE; i+=BLOCK_NUM*THREAD_NUM)
    {
        shared_mem[tid] += num[i]*num[i]*num[i];
    }
    __syncthreads();
    //tree sum

    int offset = 1, mask =1;

    while(offset < THREAD_NUM)
    {
        if((tid & mask) == 0)
        {
            shared_mem[tid] += shared_mem[tid + offset];
        }
        offset += offset;
        mask = offset + mask;
        __syncthreads();
    }

    if(tid == 0)
    {
        result[bid] = shared_mem[0];
        time[bid + BLOCK_NUM] = clock();
    }
}

int main()
{
    if(!InitCuda())
        return 0;

    GenerateNumber(data, DATA_SIZE);

    int* gpudata, *result;
    clock_t *time;
    cudaMalloc((void**)&gpudata, sizeof(int)*DATA_SIZE);
    cudaMalloc((void**)&result, sizeof(int)*BLOCK_NUM);
    cudaMalloc((void**)&time, sizeof(clock_t)*BLOCK_NUM*2);
    cudaMemcpy(gpudata, data, sizeof(int)*DATA_SIZE, cudaMemcpyHostToDevice);
    sumOfSquares_tree<<<BLOCK_NUM, THREAD_NUM, THREAD_NUM*sizeof(int)>>>(gpudata, result, time);
    int sum[BLOCK_NUM];
    clock_t time_used[BLOCK_NUM*2];
    cudaMemcpy(&sum, result, sizeof(int)*BLOCK_NUM, cudaMemcpyDeviceToHost);
    cudaMemcpy(&time_used, time, sizeof(clock_t)*BLOCK_NUM*2, cudaMemcpyDeviceToHost);
    cudaFree(gpudata);
    cudaFree(result);
    cudaFree(time);

    int final_sum = 0;
    for(int i=0;i<BLOCK_NUM; i++)
    {
        final_sum += sum[i];
    }
    clock_t min_start, max_end;
    min_start = time_used[0];
    max_end = time_used[BLOCK_NUM];

    for (int i = 1; i < BLOCK_NUM; i++) {
        if (min_start > time_used[i])
            min_start = time_used[i];
        if (max_end < time_used[i + BLOCK_NUM])
            max_end = time_used[i + BLOCK_NUM];
    }

    printf("GPUsum: %d time: %d\n", final_sum, max_end - min_start);

    int cpu_sum = 0;

    for (int i = 0; i < DATA_SIZE; i++) {
        cpu_sum+= data[i] * data[i] * data[i];
    }

    printf("CPUsum: %d \n", cpu_sum);

    return 0;
}

