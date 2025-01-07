#include <stdio.h>
#include <stdlib.h> // For rand()
#include <time.h>   // For time()
#define N 1024

// Error checking macro
#define cudaCheckError()                                       \
    {                                                          \
        cudaError_t e = cudaGetLastError();                    \
        if (e != cudaSuccess)                                  \
        {                                                      \
            printf("CUDA error: %s\n", cudaGetErrorString(e)); \
            exit(EXIT_FAILURE);                                \
        }                                                      \
    }

// random array population
void random_ints(int *array, int size)
{
    for (int ii = 0; ii < size; ii++)
    {
        array[ii] = rand() % 100;
    }
}

// cuda addition
__global__ void add(int *a, int *b, int *c, int size)
{
    int index = threadIdx.x + blockIdx.x * blockDim.x;
    if (index < size)
    {
        c[index] = a[index] + b[index];
    }
}

int main(void)
{
    int *a, *b, *c;       // host copies of a b c
    int *d_a, *d_b, *d_c; // device copies of a b c
    int size = N * sizeof(int);
    clock_t t0, t1, t2, t3, t4; // for timing

    t0 = clock();

    // device memory allocation
    cudaMalloc((void **)&d_a, size);
    cudaCheckError();
    cudaMalloc((void **)&d_b, size);
    cudaCheckError();
    cudaMalloc((void **)&d_c, size);
    cudaCheckError();

    // host memory allocation
    a = (int *)malloc(size);
    b = (int *)malloc(size);
    c = (int *)malloc(size);

    // host data creation
    // constant seed
    srand(0);
    // time varying seed
    // srand(time(NULL));
    random_ints(a, N);
    random_ints(b, N);

    t1 = clock();
    printf("Init took %f seconds.\n", ((double)(t1 - t0)) / CLOCKS_PER_SEC);

    // data transfer from host to device
    cudaMemcpy(d_a, a, size, cudaMemcpyHostToDevice);
    cudaCheckError();
    cudaMemcpy(d_b, b, size, cudaMemcpyHostToDevice);
    cudaCheckError();

    t2 = clock();

    // perform addition at device
    int threadsPerBlock = 128; // max is 1024
    int blocksPerGrid = (N + threadsPerBlock - 1) / threadsPerBlock;
    add<<<blocksPerGrid, threadsPerBlock>>>(d_a, d_b, d_c, N);
    cudaCheckError();
    t3 = clock();

    // transfer result to host
    cudaMemcpy(c, d_c, size, cudaMemcpyDeviceToHost);
    cudaCheckError();

    t4 = clock();
    printf("Data transfer took %f seconds.\n", ((double)(t2 - t1 + t4 - t3)) / CLOCKS_PER_SEC);
    printf("Compute took %f seconds.\n", ((double)(t3 - t2)) / CLOCKS_PER_SEC);

    // print result
    // printf("result is\n");
    // for (int ii = 0; ii < N; ii++)
    // {
    //     printf(" %d", c[ii]);
    // }
    // printf("\n");
    printf("a[0] = %d", a[0]);
    printf(" a[1] = %d\n", a[1]);
    printf("b[0] = %d b[1] = %d\n", b[0], b[1]);
    printf("c[0] = %d c[1] = %d\n", c[0], c[1]);

    free(a);
    free(b);
    free(c);
    cudaFree(d_a);
    cudaFree(d_b);
    cudaFree(d_c);

    return 0;
}