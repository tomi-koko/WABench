use std::fs::File;
use std::io::{BufRead, BufReader, Write};
use std::time::{SystemTime, UNIX_EPOCH};

const NUM_SAMPLES: usize = 10_000;
const FILENAME: &str = "sensor_data_rust.txt";

#[derive(Debug)]
struct SensorData {
    timestamp: u128,
    value: f64,
}

fn get_current_ms() -> u128 {
    let now = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .expect("Time went backwards");
    now.as_secs() as u128 * 1000 + now.subsec_millis() as u128
}

fn generate_data(data: &mut Vec<SensorData>) {
    use rand::Rng;
    let mut rng = rand::thread_rng();
    for _ in 0..NUM_SAMPLES {
        data.push(SensorData {
            timestamp: get_current_ms(),
            value: rng.gen_range(0.0..100.0),
        });
    }
}

fn write_data(data: &[SensorData]) {
    let mut file = File::create(FILENAME).expect("Failed to open file");
    for d in data {
        writeln!(file, "{}, {:.2}", d.timestamp, d.value).expect("Failed to write");
    }
}

fn read_and_calculate() -> f64 {
    let file = File::open(FILENAME).expect("Failed to open file");
    let reader = BufReader::new(file);
    let mut sum = 0.0;
    let mut count = 0;

    for line in reader.lines() {
        let line = line.expect("Failed to read line");
        let parts: Vec<&str> = line.trim().split(',').collect();
        if parts.len() != 2 {
            continue;
        }
        let value: f64 = parts[1].trim().parse().expect("Failed to parse value");
        sum += value;
        count += 1;
    }

    if count == 0 {
        0.0
    } else {
        sum / count as f64
    }
}

fn main() {
    let mut data = Vec::with_capacity(NUM_SAMPLES);

    // 生成数据
    let start = get_current_ms();
    generate_data(&mut data);
    let end = get_current_ms();
    println!("[Rust] Data generation time: {} ms", end - start);

    // 写入文件
    let start = get_current_ms();
    write_data(&data);
    let end = get_current_ms();
    println!("[Rust] Write time: {} ms", end - start);

    // 读取并计算
    let start = get_current_ms();
    let avg = read_and_calculate();
    let end = get_current_ms();
    println!("[Rust] Read & calculate time: {} ms", end - start);
    println!("[Rust] Average value: {:.2}", avg);
}

