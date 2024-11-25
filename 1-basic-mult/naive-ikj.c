#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <stdbool.h>
#include <string.h>


double** create_matrix(int, int);
void matrix_init(double**, int, int, bool);
void mmult_naive(double* A, double* B, double* C, int size);
void mmult_ikj(double* A, double* B, double* C, int size);
static inline long long timestamp();

int main(int argc, char* argv[argc+1]) {
    double **A, **B, **C;
    int size = 35;
    long long tstart, tstop;
    double tmmult;

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
    mmult_ikj(A0, B0, C0, size);
    /* END TEST*/
    tstop = timestamp();


    tmmult = (double)(tstop - tstart);
    double sum = 0.0;
    for (int i = 0; i < size && i < size; i++) {
        sum += C[i][i];
    }

    char *filename_base = "ikj_vtune_";
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

/* simple matrix multiplication function */
void mmult_naive(double* A, double* B, double* C, int size) {
    for (int i = 0; i < size; i++) {
        for (int j = 0; j < size; j++) {
            for (int k = 0; k < size; k++) {
                *(C + i*size + j) += *(A + i*size + k) * *(B + k*size + j);
            }
        }
    }
}

/* simple matrix multiplication function with j and k iterator orders swapped */
void mmult_ikj(double* A, double* B, double* C, int size) {
    for (int i = 0; i < size; i++) {
        for (int k = 0; k < size; k++) {
            for (int j = 0; j < size; j++) {
                *(C + i*size + j) += *(A + i*size + k) * *(B + k*size + j);
            }
        }
    }
}

