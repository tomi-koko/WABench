#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>
#include <time.h>

#define SMALL 0
#define STANDARD 1
#define LARGE 2

// ---------- 可选数据规模 ----------
#if !defined(DATASET)
#define DATASET SMALL
#endif

#if DATASET == SMALL
#define NI 250
#define NJ 300
#define NK 350
#define NL 400
#define NM 450
#elif DATASET == LARGE
#define NI 2000
#define NJ 2200
#define NK 2400
#define NL 2600
#define NM 2800
#else
#define NI 500
#define NJ 600
#define NK 700
#define NL 800
#define NM 900
#endif

// ---------- 初始化随机矩阵 ----------
void init_array(int ni, int nj, int nk, int nl, int nm,
               double A[ni][nk], double B[nk][nj],
               double C[nj][nm], double D[nm][nl],
               unsigned int seed) {
    srand(seed);
    for (int i = 0; i < ni; i++)
        for (int k = 0; k < nk; k++)
            A[i][k] = ((double)rand() / RAND_MAX) * 10;
    
    for (int k = 0; k < nk; k++)
        for (int j = 0; j < nj; j++)
            B[k][j] = ((double)rand() / RAND_MAX) * 10;
    
    for (int j = 0; j < nj; j++)
        for (int m = 0; m < nm; m++)
            C[j][m] = ((double)rand() / RAND_MAX) * 10;
    
    for (int m = 0; m < nm; m++)
        for (int l = 0; l < nl; l++)
            D[m][l] = ((double)rand() / RAND_MAX) * 10;
}

// ---------- 打印部分输出矩阵（防止被编译器优化） ----------
void print_matrix(int ni, int nl, double G[ni][nl]) {
    for (int i = 0; i < ni && i < 8; i++) {
        for (int l = 0; l < nl && l < 8; l++) {
            printf("%0.2f ", G[i][l]);
        }
        printf("\n");
    }
}

// ---------- 主计算过程 ----------
void compute_3mm(int ni, int nj, int nk, int nl, int nm,
                double A[ni][nk], double B[nk][nj],
                double C[nj][nm], double D[nm][nl],
                double E[ni][nj], double F[nj][nl],
                double G[ni][nl]) {
    // E = A * B
    for (int i = 0; i < ni; i++) {
        for (int j = 0; j < nj; j++) {
            E[i][j] = 0.0;
            for (int k = 0; k < nk; k++) {
                E[i][j] += A[i][k] * B[k][j];
            }
        }
    }
    
    // F = C * D
    for (int j = 0; j < nj; j++) {
        for (int l = 0; l < nl; l++) {
            F[j][l] = 0.0;
            for (int m = 0; m < nm; m++) {
                F[j][l] += C[j][m] * D[m][l];
            }
        }
    }
    
    // G = E * F
    for (int i = 0; i < ni; i++) {
        for (int l = 0; l < nl; l++) {
            G[i][l] = 0.0;
            for (int j = 0; j < nj; j++) {
                G[i][l] += E[i][j] * F[j][l];
            }
        }
    }
}

// ---------- 主函数 ----------
int main(int argc, char** argv) {
    static double A[NI][NK];
    static double B[NK][NJ];
    static double C[NJ][NM];
    static double D[NM][NL];
    static double E[NI][NJ];
    static double F[NJ][NL];
    static double G[NI][NL];

    unsigned int seed = (argc > 1) ? atoi(argv[1]) : 42;

    init_array(NI, NJ, NK, NL, NM, A, B, C, D, seed);

    clock_t start = clock();
    compute_3mm(NI, NJ, NK, NL, NM, A, B, C, D, E, F, G);
    clock_t end = clock();

    printf("Finished 3mm calculation in %.3f seconds\n",
           (double)(end - start) / CLOCKS_PER_SEC);

    print_matrix(NI, NL, G); // 打印前8x8子矩阵
    return 0;
}
