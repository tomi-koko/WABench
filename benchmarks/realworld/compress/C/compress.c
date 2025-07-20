#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#define BUF_SIZE 8192

double now_sec() {
    struct timespec ts;
    clock_gettime(CLOCK_MONOTONIC, &ts);
    return ts.tv_sec + ts.tv_nsec / 1e9;
}

// 简化 RLE 压缩（遇到重复字节则编码为 [count][byte]）
size_t simple_compress(const unsigned char *in, size_t in_len, unsigned char *out) {
    size_t out_idx = 0;
    for (size_t i = 0; i < in_len;) {
        unsigned char b = in[i];
        size_t count = 1;
        while (i + count < in_len && in[i + count] == b && count < 255) count++;
        out[out_idx++] = count;
        out[out_idx++] = b;
        i += count;
    }
    return out_idx;
}

int main(int argc, char *argv[]) {
    if (argc != 2) {
        printf("Usage: %s <file>\n", argv[0]);
        return 1;
    }

    FILE *fp = fopen(argv[1], "rb");
    if (!fp) {
        perror("fopen");
        return 1;
    }

    fseek(fp, 0, SEEK_END);
    size_t fsize = ftell(fp);
    fseek(fp, 0, SEEK_SET);

    unsigned char *input = malloc(fsize);
    unsigned char *output = malloc(fsize * 2); // worst case

    fread(input, 1, fsize, fp);
    fclose(fp);

    double t_start = now_sec();
    size_t out_size = simple_compress(input, fsize, output);
    double t_end = now_sec();

    printf("Compression time: %.6f sec\n", t_end - t_start);
    printf("Original size: %zu bytes\nCompressed size: %zu bytes\n", fsize, out_size);

    free(input);
    free(output);
    return 0;
}
