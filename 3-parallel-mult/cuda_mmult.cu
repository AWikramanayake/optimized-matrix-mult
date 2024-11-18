#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <stdbool.h>

double** create_matrix(int, int);
void matrix_init(double**, int, int);
__global__ void cuda_mmult(double* a, double* b, double* c, int size);
static inline long long timestamp();

int main(int argc, char* argv[]) {
    int size = 1600;
    int BLOCK_SIZE = 16;
    float tmmult;
    float nflop = 2.0 * (double)size * (double)size * (double)size;

    double** A0, ** B0, ** C0;

    A0 = create_matrix(size, size);
    B0 = create_matrix(size, size);
    C0 = create_matrix(size, size);

    if (!A0 || !B0 || !C0) {
        perror("Malloc Failed");
        exit(EXIT_FAILURE);
    }
    printf("Malloc completed\n");

    double* A = A0[0];
    double* B = B0[0];
    double* C = C0[0];

    matrix_init(A0, size, size, false);
    matrix_init(B0, size, size, false);
    matrix_init(C0, size, size, true);

    printf("Init completed\n");

    double* cuda_A = 0;
    double* cuda_B = 0;
    double* cuda_C = 0;

    cudaMalloc(&cuda_A, size * size * sizeof(double));
    cudaMalloc(&cuda_B, size * size * sizeof(double));
    cudaMalloc(&cuda_C, size * size * sizeof(double));

    printf("cudaMalloc completed\n");

    cudaMemcpy(cuda_A, A, size * size * sizeof(double), cudaMemcpyHostToDevice);
    cudaMemcpy(cuda_B, B, size * size * sizeof(double), cudaMemcpyHostToDevice);

    printf("cudaMemcpy completed\n");


    /* kernel invocation parameters */
    int  nblocks_x = (size + BLOCK_SIZE - 1) / BLOCK_SIZE;
    int  nblocks_y = (size + BLOCK_SIZE - 1) / BLOCK_SIZE;
    dim3 dimGrid(nblocks_x, nblocks_y);
    dim3 dimBlock(BLOCK_SIZE, BLOCK_SIZE);

    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);


    /* START TEST*/

    cudaEventRecord(start);
    cuda_mmult <<<dimGrid, dimBlock>>> (cuda_A, cuda_B, cuda_C, size);
    cudaEventRecord(stop);
    /* END TEST*/

    cudaMemcpy(C, cuda_C, size * size * sizeof(double), cudaMemcpyDeviceToHost);

    double sum = 0.0;
    for (int i = 0; i < size && i < size; i++) {
        sum += C0[i][i];
    }

    cudaEventElapsedTime(&tmmult, start, stop);
       
    float tmmult_s = tmmult / 1000.0;

    printf("matrix_size, gflops_mmult, tmmult, trace_mmult\n");
    printf("%d, %f, %f, %12.12g\n", size, nflop / (tmmult_s * 1.0e9), tmmult_s, sum);

    cudaFree(cuda_A);
    cudaFree(cuda_B);
    cudaFree(cuda_C);

    free((void*)A0[0]);
    free((void*)B0[0]);
    free((void*)C0[0]);
    free((void*)A0);
    free((void*)B0);
    free((void*)C0);
}


double** create_matrix(int rows, int cols) {
    double** row_ptrs = (double**)malloc(rows * sizeof(double*));
    row_ptrs[0] = (double*)malloc(rows * cols * sizeof(double));

    for (int i = 1; i < rows; i++) {
        row_ptrs[i] = row_ptrs[0] + i * cols;
    }
    return row_ptrs;
}


void matrix_init(double** matrix, int rows, int cols, bool zeroes) {
    if(zeroes) {
        for (int i = 0; i < rows; i++) {
            for (int j = 0; j < cols; j++) {
                matrix[i][j] = 0.0;
            }
        }
    } else {
        for (int i = 0; i < rows; i++) {
            for (int j = 0; j < cols; j++) {
                matrix[i][j] = (double)(i) + (double)(j);
            }
        }
    }
}

__global__ void cuda_mmult(double* a, double* b, double* c, int size) {
    /* index calculation */
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    int j = blockIdx.y * blockDim.y + threadIdx.y;

    /* CUDA matrix multiplication */
    if (i < size && j < size) {
        for (int k = 0; k < size; ++k) {
            c[i * size + j] += a[i * size + k] * b[k * size + j];
        }
    }
}