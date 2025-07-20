#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <wasi/api.h>  // WASI API for fd_write

#define BUF_SIZES {1024, 4096, 16384, 65536}  // 测试不同的缓冲区大小
#define TEST_DATA_SIZE (100 * 1024 * 1024)    // 每组测试 100MB 数据

static void fill_buffer(char *buf, size_t size) {
    for (size_t i = 0; i < size; i++) {
        buf[i] = (char)(i % 256);  // 填充伪随机数据
    }
}

// 使用 WASI API 向 stdout 写入数据
static __wasi_errno_t write_to_stdout(char *buf, size_t size) {
    __wasi_ciovec_t iov = {
        .buf = buf,
        .buf_len = size
    };

    size_t bytes_written = 0;
    return __wasi_fd_write(1, &iov, 1, &bytes_written);
}

static void run_benchmark(size_t buf_size, size_t total_size) {
    char *buf = malloc(buf_size);
    if (!buf) {
        fprintf(stderr, "malloc failed for size %zu\n", buf_size);
        return;
    }
    fill_buffer(buf, buf_size);

    uint64_t start, end;
    __wasi_clock_time_get(__WASI_CLOCKID_MONOTONIC, 1, &start);

    size_t total_written = 0;
    while (total_written < total_size) {
        size_t bytes_to_write = (total_size - total_written < buf_size)
                              ? (total_size - total_written)
                              : buf_size;

        __wasi_errno_t err = write_to_stdout(buf, bytes_to_write);
        if (err != 0) {
            fprintf(stderr, "fd_write failed at offset %zu, errno = %d\n", total_written, err);
            break;
        }

        total_written += bytes_to_write;
    }

    __wasi_clock_time_get(__WASI_CLOCKID_MONOTONIC, 1, &end);
    double elapsed_sec = (double)(end - start) / 1e9;
    double throughput = (double)total_written / (1024 * 1024) / elapsed_sec;

    fprintf(stderr, "\n| %-8zu | %-8.2f MB | %-10.3f sec | %-10.2f MB/s |\n",
           buf_size, (double)total_written / (1024 * 1024), elapsed_sec, throughput);

    free(buf);
}

int main() {
    size_t buf_sizes[] = BUF_SIZES;
    size_t num_tests = sizeof(buf_sizes) / sizeof(buf_sizes[0]);

    printf("=== WASI Real fd_write Benchmark ===\n");
    printf("| Buffer   | Data     | Time       | Throughput |\n");
    printf("|----------|----------|------------|------------|\n");

    for (size_t i = 0; i < num_tests; i++) {
        run_benchmark(buf_sizes[i], TEST_DATA_SIZE);
    }

    printf("\nTest completed. Data was written to stdout via WASI syscall.\n");
    return 0;
}

