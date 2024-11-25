#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <stdbool.h>
#include <string.h>
#include <x86intrin.h>

#define MIN(a,b) ((a) < (b) ? (a) : (b))
#define BLOCKSIZE 32
#define UNROLL 4

double** create_matrix(int, int);
void matrix_init(double**, int, int, bool);
void block_avx2(double* A, double* B, double* C, int size);
void block_avx2_unrolled(double* A, double* B, double* C, int size);
static inline long long timestamp();

int main(int argc, char* argv[argc+1]) {
    double **A, **B, **C;
    int size = 0;
    long long tstart, tstop;
    double tmmult;
    double cum_nflop = 0;
    double sum = 0.0;

    int sizes[] = {32, 35, 40, 45, 56, 59, 64, 75, 96, 116, 128, 150, 175, 192, 200, 225, 256, 275, 300, 325, 350, 375, 400, 425, 450, 475, 500, 512, 550, 575, 600, 625, 650,
                    675, 700, 725, 750, 768, 800, 855, 900, 955, 1000, 1055, 1100, 1155, 1200, 1255, 1300, 1355, 1400, 1455, 1500, 1555, 1600, 1655, 1700, 1755, 1800};

    int nruns = sizeof(sizes) / sizeof(sizes[0]);

    printf("checkpoint 1\n");
    FILE *fpt1;
    fpt1 = fopen("test_reslts.csv", "w+");
    fprintf(fpt1,"matrix_size, gflops_mmult\n");

    int iters = 500;
    printf("starting loop\n");
    for (int testnum = 0; testnum < nruns; testnum++) {

        size = sizes[testnum];
        cum_nflop = 0;
        sum = 0.0;

        if (size > 1000) {
            iters = 100;
        } else if (size > 500) {
            iters = 500;
        }

        A = create_matrix(size, size);
        B = create_matrix(size, size);
        C = create_matrix(size, size);

        matrix_init(A, size, size, false);
        matrix_init(B, size, size, false);
        matrix_init(C, size, size, true);

        double* A0 = A[0];
        double* B0 = B[0];
        double* C0 = C[0];

        /*
        Using the pointers-to-row-of-pointers (A0, B0, C0) allows the use of matrix index notation,
        i.e. A[1][3], B[i][j], etc, while keeping data in a contiguous block. However, the pointer-to-pointer
        operations add a significant performance hit and hide some compiler optimizations. Therefore,
        we ignore the row pointers and use pointers to the start of the data block as "the matrix object".

        The tradeoff is that notation looks like *(A + i*size + j) instead of A[i][j].
        */


        double nflop = 2.0 * (double)size * (double)size * (double)size;
        // ^factor of 2 because fused multiply-add is 2 operations

        printf("Starting matrix mult test with matrix size %d\n", size);

        char *filename_base = "avx2_blocked_";
        char msize_str[5];
        itoa(size, msize_str, 10);
        char buffer[50];
        strcpy(buffer, filename_base);
        strcat(buffer, msize_str);
        strcat(buffer, ".csv");

        FILE *fpt;
        fpt = fopen(buffer, "w+");

        printf("matrix_size, gflops_mmult, tmmult, trace_mmult\n");
        fprintf(fpt,"matrix_size, gflops_mmult, tmmult, trace_mmult\n");

        for (int i = 0; i < iters; i++) {

            tstart = timestamp();
            //START TEST
            block_avx2_unrolled(A0, B0, C0, size);
            //END TEST
            tstop = timestamp();

            tmmult = (double)(tstop - tstart);

            for (int i = 0; i < size && i < size; i++) {
                sum += C[i][i];
            }
            printf("%d\n%d, %f, %f, %12.12g\n", i, size, nflop / tmmult, tmmult, sum);
            fprintf(fpt,"%d, %f, %f, %12.12g\n", size, nflop / tmmult, tmmult, sum);
            sum = 0.0;
            matrix_init(C, size, size, true);
            cum_nflop += (nflop / tmmult);
        
        }

        double avg_gflops = cum_nflop / (double)iters;
        printf("\n\n avg gflops = %f", avg_gflops);
        fprintf(fpt, "\n\n avg gflops = %f", avg_gflops);
        fprintf(fpt1,"%d, %f\n", size, avg_gflops);

        fclose(fpt);

        free((void*)A[0]);
        free((void*)B[0]);
        free((void*)C[0]);
        free((void*)A);
        free((void*)B);
        free((void*)C);
    }
    fclose(fpt1);
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


void block_avx2(double* A, double* B, double* C, int size) {
    int rem = size % 4;
    __m256i mask;
    int size4 = size - rem;
    
    for (int i0 = 0; i0 < size4; i0 += BLOCKSIZE) {
        for (int j0 = 0; j0 < size; j0 += BLOCKSIZE) {
            for (int k0 = 0; k0 < size; k0 += BLOCKSIZE) {
                for (int i = i0; i < MIN(i0+BLOCKSIZE, size4); i += 4) {
                    for (int j = j0; j < MIN(j0+BLOCKSIZE, size); j++) {
                        __m256d c0 = _mm256_load_pd(C+i+j*size);
                        for(int k = k0; k < MIN(k0+BLOCKSIZE, size); k++) {
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

    if (rem) {
        switch(rem) {
            case 1 : mask = _mm256_setr_epi32(1, -1, 1, 1, 1, 1, 1, 1); break;
            case 2 : mask = _mm256_setr_epi32(1, -1, 1, -1, 1, 1, 1, 1); break;
            case 3 : mask = _mm256_setr_epi32(1, -1, 1, -1, 1, -1, 1, 1); break;
        }

        for (int j0 = 0; j0 < size; j0 += BLOCKSIZE) {
            for (int k0 = 0; k0 < size; k0 += BLOCKSIZE) {        
                for (int j = j0; j < MIN(j0+BLOCKSIZE, size); j++) {
                    __m256d c0 = _mm256_maskload_pd(C + size4 + j*size, mask);
                    for(int k = k0; k < MIN(k0+BLOCKSIZE, size); k++) {
                        c0 = _mm256_add_pd(c0,
                        _mm256_mul_pd(_mm256_maskload_pd(A + size4 + k*size, mask),
                        _mm256_broadcast_sd(B + k + j*size)));

                        _mm256_maskstore_pd(C + size4 + j*size, mask, c0);
                    }
                }
            }
        }
    }
}


void block_avx2_unrolled(double* A, double* B, double* C, int size) {
    int rem = size % (UNROLL*4);
    __m256i mask;
    int sizeU4 = size - rem;

    for (int i0 = 0; i0 < size; i0 += BLOCKSIZE) {
        for (int j0 = 0; j0 < size; j0 += BLOCKSIZE) {
            for (int k0 = 0; k0 < size; k0 += BLOCKSIZE) {
                for (int i = i0; i < MIN(i0+BLOCKSIZE, sizeU4); i+=UNROLL*4 )
                    for ( int j = j0; j < MIN(j0+BLOCKSIZE, size); j++ ) {
                        __m256d c[UNROLL];
                        for ( int x = 0; x < UNROLL; x++ )
                            c[x] = _mm256_load_pd(C + i + x*4 + j*size);

                        for( int k = k0; k < MIN(k0+BLOCKSIZE, size); k++ )
                        {
                            __m256d b = _mm256_broadcast_sd(B + k + j*size);
                            for (int x = 0; x < UNROLL; x++)
                            c[x] = _mm256_add_pd(c[x],
                                _mm256_mul_pd(_mm256_load_pd(A + size*k + x*4 + i), b));
                        }

                        for ( int x = 0; x < UNROLL; x++ )
                            _mm256_store_pd(C + i+ x*4 + j*size, c[x]);
                        }
            }
        }
    }

    if (rem) {
        int fourBlocks = rem/4;
        for (int j0 = 0; j0 < size; j0 += BLOCKSIZE) {
            for (int k0 = 0; k0 < size; k0 += BLOCKSIZE) {        
                for (int j = j0; j < MIN(j0+BLOCKSIZE, size); j++) {
                    __m256d c[fourBlocks];
                    for (int x = 0; x < fourBlocks; x++)
                        c[x] = _mm256_load_pd(C + sizeU4 + x*4 + j*size);

                    for(int k = k0; k < MIN(k0+BLOCKSIZE, size); k++) {
                        __m256d b = _mm256_broadcast_sd(B + k + j*size);

                        for (int x = 0; x < fourBlocks; x++) {
                            c[x] = _mm256_add_pd(c[x],
                                _mm256_mul_pd(_mm256_load_pd(A + size*k + sizeU4 + x*4), b));
                        }
                    }

                    for ( int x = 0; x < fourBlocks; x++ )
                        _mm256_store_pd(C + sizeU4 + x*4 + j*size, c[x]);            

                }
            }
        }

        switch(rem % 4) {
            case 0 : goto SKIPLOOP;
            case 1 : mask = _mm256_setr_epi32(1, -1, 1, 1, 1, 1, 1, 1); sizeU4 = size - rem%4; break;
            case 2 : mask = _mm256_setr_epi32(1, -1, 1, -1, 1, 1, 1, 1); sizeU4 = size - rem%4; break;
            case 3 : mask = _mm256_setr_epi32(1, -1, 1, -1, 1, -1, 1, 1); sizeU4 = size - rem%4; break;
        }
        if(rem % 4) {
            for (int j0 = 0; j0 < size; j0 += BLOCKSIZE) {
                for (int k0 = 0; k0 < size; k0 += BLOCKSIZE) {
                    for (int j = j0; j < MIN(j0+BLOCKSIZE, size); j++ ) {
                        __m256d c0 = _mm256_maskload_pd(C + sizeU4 + j*size, mask);
                        for(int k = k0; k < MIN(k0+BLOCKSIZE, size); k++) {
                            c0 = _mm256_add_pd(c0,
                            _mm256_mul_pd(_mm256_maskload_pd(A + sizeU4 + k*size, mask),
                            _mm256_broadcast_sd(B + k + j*size)));

                            _mm256_maskstore_pd(C + sizeU4 + j*size, mask, c0);
                        }
                    }
                }
            }
        }   
SKIPLOOP:        
    }
}