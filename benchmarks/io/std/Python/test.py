import time
import sys

BUF_SIZES = [1024, 4096, 16384, 65536]
TEST_DATA_SIZE = 100 * 1024 * 1024  # 100MB

def fill_buffer(buf):
    for i in range(len(buf)):
        buf[i] = i % 256

def run_benchmark(buf_size, total_size):
    buf = bytearray(buf_size)
    fill_buffer(buf)
    
    start = time.time()
    total_written = 0
    
    while total_written < total_size:
        bytes_to_write = min(total_size - total_written, buf_size)
        written = sys.stdout.buffer.write(buf[:bytes_to_write])
        total_written += written
    
    elapsed = time.time() - start
    throughput = total_written / (1024 * 1024) / elapsed
    
    print(f"| {buf_size:<8} | {total_written/(1024*1024):<8.2f} MB | {elapsed:<10.3f} sec | {throughput:<10.2f} MB/s |", 
          file=sys.stderr)

if __name__ == "__main__":
    print("=== WASI Python Benchmark ===", file=sys.stderr)
    print("| Buffer   | Data     | Time       | Throughput |", file=sys.stderr)
    print("|----------|----------|------------|------------|", file=sys.stderr)
    
    for size in BUF_SIZES:
        run_benchmark(size, TEST_DATA_SIZE)
    
    print("\nTest completed. Data was written to stdout via Python syscall.", file=sys.stderr)
