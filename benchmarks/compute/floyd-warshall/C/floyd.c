#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#define SMALL 0
#define STANDARD 1
#define LARGE 2

#if !defined(DATASET)
#define DATASET STANDARD
#endif

#if DATASET == SMALL
#define N 50
#elif DATASET == LARGE
#define N 2000
#else
#define N 500
#endif

void init_matrix(int n, double graph[n][n], unsigned int seed) {
    srand(seed);
    for (int i = 0; i < n; i++)
        for (int j = 0; j < n; j++)
            graph[i][j] = (i == j) ? 0.0 : ((double)(rand() % 100) + 1);
}

void print_matrix(int n, double graph[n][n]) {
    for (int i = 0; i < n && i < 8; i++) {
        for (int j = 0; j < n && j < 8; j++) {
            printf("%0.2f ", graph[i][j]);
        }
        printf("\n");
    }
}

void floyd_warshall(int n, double graph[n][n]) {
    for (int k = 0; k < n; k++)
        for (int i = 0; i < n; i++)
            for (int j = 0; j < n; j++)
                if (graph[i][j] > graph[i][k] + graph[k][j])
                    graph[i][j] = graph[i][k] + graph[k][j];
}

int main(int argc, char** argv) {
    static double graph[N][N];
    unsigned int seed = (argc > 1) ? atoi(argv[1]) : 42;

    init_matrix(N, graph, seed);

    clock_t start = clock();
    floyd_warshall(N, graph);
    clock_t end = clock();

    printf("Finished Floyd-Warshall in %.3f seconds\n",
           (double)(end - start) / CLOCKS_PER_SEC);

    print_matrix(N, graph);
    return 0;
}

