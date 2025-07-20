import time

# 测试配置
BUF_SIZES = [1024, 4096, 16384, 65536]  # 缓冲区大小列表
TEST_DATA_SIZE = 100 * 1024 * 1024       # 测试数据量 (100MB)

def fill_buffer(buf_size):
    return bytearray(i % 256 for i in range(buf_size))

def run_benchmark(buf_size, total_size):
    buf = fill_buffer(buf_size)
    start_time = time.perf_counter()
    
    total_written = 0
    while total_written < total_size:
        bytes_to_write = min(buf_size, total_size - total_written)
        total_written += bytes_to_write  # 模拟写入
    
    elapsed_sec = time.perf_counter() - start_time
    throughput = (total_written / (1024 * 1024)) / elapsed_sec
    
    print(f"| {buf_size:<8} | {total_written / (1024 * 1024):<8.2f} MB | "
          f"{elapsed_sec:<10.3f} sec | {throughput:<10.2f} MB/s |")

def main():
    print("\n=== Python stdin/stdout Benchmark ===")
    print("| Buffer   | Data     | Time       | Throughput |")
    print("|----------|----------|------------|------------|")
    
    for buf_size in BUF_SIZES:
        run_benchmark(buf_size, TEST_DATA_SIZE)

if __name__ == "__main__":
    main()
