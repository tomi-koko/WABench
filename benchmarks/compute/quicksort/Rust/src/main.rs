use rand::{Rng, SeedableRng};
use rand::rngs::StdRng;
use std::time::Instant;

// ---------- 可选数据规模 ----------
const SMALL: u8 = 0;
const STANDARD: u8 = 1;
const LARGE: u8 = 2;

const DATASET: u8 = STANDARD; // 默认标准规模

const SIZE: usize = match DATASET {
    SMALL => 10000,
    LARGE => 10000000,
    _ => 1000000,
};

// ---------- 初始化随机数组 ----------
fn init_array(size: usize, seed: u64) -> Vec<f64> {
    let mut rng = StdRng::seed_from_u64(seed);
    (0..size).map(|_| rng.gen()).collect()
}

// ---------- 打印部分输出数组 ----------
fn print_array(data: &[f64]) {
    for x in data.iter().take(8) {
        print!("{:.2} ", x);
    }
    println!();
}

// ---------- 快速排序实现 ----------
fn quicksort(data: &mut [f64], low: isize, high: isize) {
    if low < high {
        let pi = partition(data, low, high);
        quicksort(data, low, pi - 1);
        quicksort(data, pi + 1, high);
    }
}

fn partition(data: &mut [f64], low: isize, high: isize) -> isize {
    let pivot = data[high as usize];
    let mut i = low - 1;
    
    for j in low..high {
        if data[j as usize] < pivot {
            i += 1;
            data.swap(i as usize, j as usize);
        }
    }
    
    data.swap((i + 1) as usize, high as usize);
    i + 1
}

// ---------- 主函数 ----------
fn main() {
    let seed = std::env::args().nth(1)
        .and_then(|s| s.parse::<u64>().ok())
        .unwrap_or(42);
    
    let mut data = init_array(SIZE, seed);

    let start = Instant::now();
    quicksort(&mut data, 0, (SIZE - 1) as isize);
    let duration = start.elapsed();

    println!("Finished quicksort in {:.3} seconds", duration.as_secs_f64());
    print_array(&data); // 打印前8个元素
}
