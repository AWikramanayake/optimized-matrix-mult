#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <x86intrin.h>
#include <stdbool.h>

#define MIN(a,b) ((a) < (b) ? (a) : (b))
#define UNROLL 4
#define BLOCKSIZE 32

double** create_matrix(int, int);
void matrix_init(double**, int, int, bool);
void block_avx2(double* A, double* B, double* C, int size);
void block_avx2_unrolled(double* A, double* B, double* C, int size);

static inline long long timestamp();

int main(int argc, char* argv[argc+1]) {
    double **A, **B, **C;
    int size = 1600;
    long long tstart, tstop;
    double tmmult;
    printf("test");
    A = create_matrix(size, size);
    B = create_matrix(size, size);
    C = create_matrix(size, size);

    matrix_init(A, size, size, false);
    matrix_init(B, size, size, false);
    matrix_init(C, size, size, true);

    /*
    Using the pointers-to-row-of-pointers (A0, B0, C0) allows the use of matrix index notation,
    i.e. A[1][3], B[i][j], etc, while keeping data in a contiguous block. However, the pointer-to-pointer
    operations add a significant performance hit and hide some compiler optimizations. Therefore,
    we ignore the row pointers and use pointers to the start of the data block as "the matrix object".

    The tradeoff is that notation looks like *(A + i*size + j) instead of A[i][j].
    */
    double* A0 = A[0];
    double* B0 = B[0];
    double* C0 = C[0];

    double nflop = 2.0 * (double)size * (double)size * (double)size;
    // ^factor of 2 because fused multiply-add is 2 operations

    printf("Starting matrix mult test with matrix size %d\n", size);

    tstart = timestamp();
    /* START TEST*/ 
    block_avx2(A0, B0, C0, size);
    /* END TEST*/
    tstop = timestamp();


    tmmult = (double)(tstop - tstart);
    double sum = 0.0;
    for (int i = 0; i < size && i < size; i++) {
        sum += C[i][i];
    }

    FILE *fpt;
    fpt = fopen("blocked_mult.csv", "w+");
    printf("matrix_size, gflops_mmult, tmmult, trace_mmult\n");
    fprintf(fpt,"matrix_size, gflops_mmult, tmmult, trace_mmult\n");

    printf("%d, %f, %f, %12.12g\n", size, nflop / tmmult, tmmult, sum);
    fprintf(fpt,"%d, %f, %f, %12.12g\n", size, nflop / tmmult, tmmult, sum);

    fclose(fpt);

    free((void*)A[0]);
    free((void*)B[0]);
    free((void*)C[0]);
    free((void*)A);
    free((void*)B);
    free((void*)C);
}


static inline long long timestamp() {
    struct timespec ts;
    long long timestamp;
    timespec_get(&ts, TIME_UTC);
    timestamp = ts.tv_sec * 1000000000LL + ts.tv_nsec; 
    return timestamp;
}


double** create_matrix(int rows, int cols) {
    double** row_ptrs = malloc(rows * sizeof(double*));
    row_ptrs[0] = malloc(rows * cols * sizeof(double));

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

/*
    AVX2 Matrix multiplication function that breaks workload into blocks
    Blocks can be kept small to reduce cache misses
*/
void block_avx2(double* A, double* B, double* C, int size) {
    for (int i0 = 0; i0 < size; i0 += BLOCKSIZE) {
        for (int j0 = 0; j0 < size; j0 += BLOCKSIZE) {
            for (int k0 = 0; k0 < size; k0 += BLOCKSIZE) {
                for (int i = i0; i < MIN(i0+BLOCKSIZE, size); i += 4) {
                    for (int j = j0; j < MIN(j0+BLOCKSIZE, size); j++) {
                        __m256d c0 = _mm256_load_pd(C+i+j*size);
                        for( int k = k0; k < MIN(k0+BLOCKSIZE, size); k++ ) {
                            c0 = _mm256_add_pd(c0,
                            _mm256_mul_pd(_mm256_load_pd(A+i+k*size),
                            _mm256_broadcast_sd(B+k+j*size)));

                            _mm256_store_pd(C+i+j*size, c0);
                        }
                    }
                }
            }
        }
    }
}


void block_avx2_unrolled(double* A, double* B, double* C, int size) {
    for (int i0 = 0; i0 < size; i0 += BLOCKSIZE) {
        for (int j0 = 0; j0 < size; j0 += BLOCKSIZE) {
            for (int k0 = 0; k0 < size; k0 += BLOCKSIZE) {
                for (int i = i0; i < MIN(i0+BLOCKSIZE, size); i+=UNROLL*4 )
                    for ( int j = j0; j < MIN(j0+BLOCKSIZE, size); j++ ) {
                        __m256d c[UNROLL];
                        for ( int x = 0; x < UNROLL; x++ )
                            c[x] = _mm256_load_pd(C+i+x*4+j*size);

                        for( int k = k0; k < MIN(k0+BLOCKSIZE, size); k++ )
                        {
                            __m256d b = _mm256_broadcast_sd(B+k+j*size);
                            for (int x = 0; x < UNROLL; x++)
                            c[x] = _mm256_add_pd(c[x],
                                _mm256_mul_pd(_mm256_load_pd(A+size*k+x*4+i), b));
                        }

                        for ( int x = 0; x < UNROLL; x++ )
                            _mm256_store_pd(C+i+x*4+j*size, c[x]);
                        }
            }
        }
    }
}