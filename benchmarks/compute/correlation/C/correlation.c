#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>
#include <time.h>

#define SMALL 0
#define STANDARD 1
#define LARGE 2


#if !defined(DATASET)
#define DATASET STANDARD
#endif

#if DATASET == SMALL
#define M 50
#define N 60
#elif DATASET == LARGE
#define M 2000
#define N 2500
#else
#define M 500
#define N 600
#endif


void init_array(int m, int n, double data[m][n], double *float_n, unsigned int seed) {
    *float_n = (double)n;
    srand(seed);
    for (int i = 0; i < m; i++)
        for (int j = 0; j < n; j++)
            data[i][j] = ((double)rand() / RAND_MAX);
}


void print_matrix(int m, double symmat[m][m]) {
    for (int i = 0; i < m && i < 8; i++) {
        for (int j = 0; j < m && j < 8; j++) {
            printf("%0.2f ", symmat[i][j]);
        }
        printf("\n");
    }
}


void compute_correlation(int m, int n, double float_n,
                         double data[m][n],
                         double symmat[m][m],
                         double mean[m],
                         double stddev[m]) {
    double eps = 0.1;


    for (int j = 0; j < m; j++) {
        mean[j] = 0.0;
        for (int i = 0; i < n; i++)
            mean[j] += data[j][i];
        mean[j] /= float_n;
    }


    for (int j = 0; j < m; j++) {
        stddev[j] = 0.0;
        for (int i = 0; i < n; i++) {
            double val = data[j][i] - mean[j];
            stddev[j] += val * val;
        }
        stddev[j] = sqrt(stddev[j] / float_n);
        if (stddev[j] <= eps) stddev[j] = 1.0;
    }


    for (int j = 0; j < m; j++)
        for (int i = 0; i < n; i++) {
            data[j][i] -= mean[j];
            data[j][i] /= (sqrt(float_n) * stddev[j]);
        }


    for (int i = 0; i < m; i++) {
        symmat[i][i] = 1.0;
        for (int j = i + 1; j < m; j++) {
            symmat[i][j] = 0.0;
            for (int k = 0; k < n; k++)
                symmat[i][j] += data[i][k] * data[j][k];
            symmat[j][i] = symmat[i][j];
        }
    }
}

int main(int argc, char** argv) {
    double float_n;
    static double data[M][N];
    static double symmat[M][M];
    static double mean[M];
    static double stddev[M];

    unsigned int seed = (argc > 1) ? atoi(argv[1]) : 42;

    init_array(M, N, data, &float_n, seed);

    clock_t start = clock();
    compute_correlation(M, N, float_n, data, symmat, mean, stddev);
    clock_t end = clock();

    printf("Finished correlation calculation in %.3f seconds\n",
           (double)(end - start) / CLOCKS_PER_SEC);

    print_matrix(M, symmat);
    return 0;
}

