use std::time::Instant;
use std::fs;
use std::env;

fn simple_compress(input: &[u8]) -> Vec<u8> {
    let mut output = Vec::new();
    let mut i = 0;
    while i < input.len() {
        let b = input[i];
        let mut count = 1;
        while i + count < input.len() && input[i + count] == b && count < 255 {
            count += 1;
        }
        output.push(count as u8);
        output.push(b);
        i += count;
    }
    output
}

fn main() {
    let args: Vec<String> = env::args().collect();
    if args.len() != 2 {
        eprintln!("Usage: {} <file>", args[0]);
        std::process::exit(1);
    }

    let input_data = fs::read(&args[1]).expect("Failed to read file");

    let t_start = Instant::now();
    let output_data = simple_compress(&input_data);
    let duration = t_start.elapsed();

    println!("Compression time: {:.6} sec", duration.as_secs_f64());
    println!("Original size: {} bytes", input_data.len());
    println!("Compressed size: {} bytes", output_data.len());
}
