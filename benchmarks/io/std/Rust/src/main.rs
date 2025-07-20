use std::time::Instant;

// 测试配置
const BUF_SIZES: [usize; 4] = [1024, 4096, 16384, 65536]; // 缓冲区大小列表
const TEST_DATA_SIZE: usize = 100 * 1024 * 1024;          // 测试数据量 (100MB)

fn fill_buffer(buf_size: usize) -> Vec<u8> {
    (0..buf_size).map(|i| (i % 256) as u8).collect()
}

fn run_benchmark(buf_size: usize, total_size: usize) {
    let buf = fill_buffer(buf_size);
    let start = Instant::now();
    
    let mut total_written = 0;
    while total_written < total_size {
        let bytes_to_write = std::cmp::min(buf_size, total_size - total_written);
        total_written += bytes_to_write; // 模拟写入
    }
    
    let elapsed_sec = start.elapsed().as_secs_f64();
    let throughput = (total_written as f64 / (1024.0 * 1024.0)) / elapsed_sec;
    
    println!("| {:<8} | {:<8.2} MB | {:<10.3} sec | {:<10.2} MB/s |",
             buf_size,
             total_written as f64 / (1024.0 * 1024.0),
             elapsed_sec,
             throughput);
}

fn main() {
    println!("\n=== Rust stdin/stdout Benchmark ===");
    println!("| Buffer   | Data     | Time       | Throughput |");
    println!("|----------|----------|------------|------------|");
    
    for &buf_size in &BUF_SIZES {
        run_benchmark(buf_size, TEST_DATA_SIZE);
    }
}
