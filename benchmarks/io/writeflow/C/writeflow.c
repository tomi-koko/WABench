#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <sys/time.h>

#define NUM_SAMPLES 10000
#define FILENAME "sensor_data_c.txt"

typedef struct {
    long timestamp;
    double value;
} SensorData;

long get_current_ms() {
    struct timeval tv;
    gettimeofday(&tv, NULL);
    return tv.tv_sec * 1000 + tv.tv_usec / 1000;
}

void generate_data(SensorData* data, int count) {
    srand(time(NULL));
    for (int i = 0; i < count; i++) {
        data[i].timestamp = get_current_ms();
        data[i].value = (double)rand() / RAND_MAX * 100.0; // 0~100的随机值
    }
}

void write_data(SensorData* data, int count) {
    FILE* file = fopen(FILENAME, "w");
    if (!file) {
        perror("Failed to open file");
        exit(1);
    }
    for (int i = 0; i < count; i++) {
        fprintf(file, "%ld,%.2f\n", data[i].timestamp, data[i].value);
    }
    fclose(file);
}

double read_and_calculate() {
    FILE* file = fopen(FILENAME, "r");
    if (!file) {
        perror("Failed to open file");
        exit(1);
    }
    double sum = 0.0;
    int count = 0;
    long timestamp;
    double value;
    while (fscanf(file, "%ld,%lf\n", &timestamp, &value) == 2) {
        sum += value;
        count++;
    }
    fclose(file);
    return sum / count;
}

int main() {
    SensorData* data = malloc(NUM_SAMPLES * sizeof(SensorData));
    if (!data) {
        perror("Failed to allocate memory");
        exit(1);
    }
    long start, end;

    // 生成数据
    start = get_current_ms();
    generate_data(data, NUM_SAMPLES);
    end = get_current_ms();
    printf("[C] Data generation time: %ld ms\n", end - start);

    // 写入文件
    start = get_current_ms();
    write_data(data, NUM_SAMPLES);
    end = get_current_ms();
    printf("[C] Write time: %ld ms\n", end - start);

    // 读取并计算
    start = get_current_ms();
    double avg = read_and_calculate();
    end = get_current_ms();
    printf("[C] Read & calculate time: %ld ms\n", end - start);
    printf("[C] Average value: %.2f\n", avg);

    free(data);
    return 0;
}

