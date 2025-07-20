use std::time::Instant;
use std::io::{self, Write};

const BUF_SIZES: [usize; 4] = [1024, 4096, 16384, 65536];
const TEST_DATA_SIZE: usize = 100 * 1024 * 1024; // 100MB

fn fill_buffer(buf: &mut [u8]) {
    for (i, byte) in buf.iter_mut().enumerate() {
        *byte = (i % 256) as u8;
    }
}

fn run_benchmark(buf_size: usize, total_size: usize) -> io::Result<()> {
    let mut buf = vec![0u8; buf_size];
    fill_buffer(&mut buf);
    
    let start = Instant::now();
    let mut total_written = 0;
    
    while total_written < total_size {
        let bytes_to_write = std::cmp::min(total_size - total_written, buf_size);
        io::stdout().write_all(&buf[..bytes_to_write])?;
        total_written += bytes_to_write;
    }
    
    let elapsed = start.elapsed().as_secs_f64();
    let throughput = (total_written as f64) / (1024.0 * 1024.0) / elapsed;
    
    eprintln!(
        "| {:<8} | {:<8.2} MB | {:<10.3} sec | {:<10.2} MB/s |",
        buf_size,
        total_written as f64 / (1024.0 * 1024.0),
        elapsed,
        throughput
    );
    
    Ok(())
}

fn main() -> io::Result<()> {
    eprintln!("=== WASI Rust Benchmark ===");
    eprintln!("| Buffer   | Data     | Time       | Throughput |");
    eprintln!("|----------|----------|------------|------------|");
    
    for &size in &BUF_SIZES {
        run_benchmark(size, TEST_DATA_SIZE)?;
    }
    
    eprintln!("\nTest completed. Data was written to stdout via Rust syscall.");
    Ok(())
}
