#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <time.h>
#include <complex.h>

#define SMALL 0
#define STANDARD 1
#define LARGE 2

#if !defined(DATASET)
#define DATASET STANDARD
#endif

#if DATASET == SMALL
#define M 64
#define N 64
#elif DATASET == LARGE
#define M 2048
#define N 2048
#else
#define M 512
#define N 512
#endif

void init_array(int m, int n, double data[m][n], unsigned int seed) {
    srand(seed);
    for (int i = 0; i < m; i++)
        for (int j = 0; j < n; j++)
            data[i][j] = ((double)rand() / RAND_MAX);
}

void fft(int n, double in[], double complex out[]) {
    if (n == 1) {
        out[0] = in[0];
        return;
    }
    int half = n / 2;
    double even_in[half], odd_in[half];
    double complex even_out[half], odd_out[half];
    for (int i = 0; i < half; i++) {
        even_in[i] = in[2 * i];
        odd_in[i] = in[2 * i + 1];
    }
    fft(half, even_in, even_out);
    fft(half, odd_in, odd_out);
    for (int k = 0; k < half; k++) {
        double complex t = cexp(-2.0 * I * M_PI * k / n) * odd_out[k];
        out[k] = even_out[k] + t;
        out[k + half] = even_out[k] - t;
    }
}

void compute_fft(int m, int n, double data[m][n], double complex result[m][n]) {
    for (int i = 0; i < m; i++)
        fft(n, data[i], result[i]);
}

void print_matrix(int m, int n, double complex result[m][n]) {
    for (int i = 0; i < m && i < 8; i++) {
        for (int j = 0; j < n && j < 8; j++) {
            printf("(%0.2f,%0.2f) ", creal(result[i][j]), cimag(result[i][j]));
        }
        printf("\n");
    }
}

int main(int argc, char** argv) {
    static double data[M][N];
    static double complex result[M][N];
    unsigned int seed = (argc > 1) ? atoi(argv[1]) : 42;

    init_array(M, N, data, seed);

    clock_t start = clock();
    compute_fft(M, N, data, result);
    clock_t end = clock();

    printf("Finished FFT in %.3f seconds\n",
           (double)(end - start) / CLOCKS_PER_SEC);

    print_matrix(M, N, result);
    return 0;
}

