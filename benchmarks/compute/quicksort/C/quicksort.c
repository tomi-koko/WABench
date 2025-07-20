#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#define SMALL 0
#define STANDARD 1
#define LARGE 2

// ---------- 可选数据规模 ----------
#if !defined(DATASET)
#define DATASET STANDARD
#endif

#if DATASET == SMALL
#define SIZE 10000
#elif DATASET == LARGE
#define SIZE 10000000
#else
#define SIZE 1000000
#endif

// ---------- 初始化随机数组 ----------
void init_array(int size, double data[size], unsigned int seed) {
    srand(seed);
    for (int i = 0; i < size; i++) {
        data[i] = (double)rand() / RAND_MAX;
    }
}

// ---------- 打印部分输出数组 ----------
void print_array(int size, double data[size]) {
    for (int i = 0; i < size && i < 8; i++) {
        printf("%0.2f ", data[i]);
    }
    printf("\n");
}

// ---------- 交换函数 ----------
void swap(double *a, double *b) {
    double temp = *a;
    *a = *b;
    *b = temp;
}

// ---------- 分区函数 ----------
int partition(int low, int high, double data[high+1]) {
    double pivot = data[high];
    int i = low - 1;
    
    for (int j = low; j < high; j++) {
        if (data[j] < pivot) {
            i++;
            swap(&data[i], &data[j]);
        }
    }
    swap(&data[i+1], &data[high]);
    return i + 1;
}

// ---------- 快速排序主函数 ----------
void quicksort(int low, int high, double data[high+1]) {
    if (low < high) {
        int pi = partition(low, high, data);
        quicksort(low, pi - 1, data);
        quicksort(pi + 1, high, data);
    }
}

// ---------- 主函数 ----------
int main(int argc, char** argv) {
    static double data[SIZE];
    unsigned int seed = (argc > 1) ? atoi(argv[1]) : 42;

    init_array(SIZE, data, seed);

    clock_t start = clock();
    quicksort(0, SIZE - 1, data);
    clock_t end = clock();

    printf("Finished quicksort in %.3f seconds\n",
           (double)(end - start) / CLOCKS_PER_SEC);

    print_array(SIZE, data); // 打印前8个元素
    return 0;
}
