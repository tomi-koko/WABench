use std::env;
use std::time::Instant;

const SMALL: usize = 0;
const STANDARD: usize = 1;
const LARGE: usize = 2;

const DATASET: usize = STANDARD;

const M: usize = match DATASET {
    SMALL => 64,
    LARGE => 2048,
    _ => 512,
};
const N: usize = match DATASET {
    SMALL => 64,
    LARGE => 2048,
    _ => 512,
};

#[derive(Clone, Copy, Debug)]
struct Complex {
    re: f64,
    im: f64,
}

impl Complex {
    fn new(re: f64, im: f64) -> Self {
        Complex { re, im }
    }

    fn exp(theta: f64) -> Complex {
        Complex {
            re: theta.cos(),
            im: theta.sin(),
        }
    }

    fn mul(self, other: Complex) -> Complex {
        Complex {
            re: self.re * other.re - self.im * other.im,
            im: self.re * other.im + self.im * other.re,
        }
    }

    fn add(self, other: Complex) -> Complex {
        Complex {
            re: self.re + other.re,
            im: self.im + other.im,
        }
    }

    fn sub(self, other: Complex) -> Complex {
        Complex {
            re: self.re - other.re,
            im: self.im - other.im,
        }
    }
}

fn init_array(seed: u64) -> Vec<Vec<f64>> {
    let mut state = seed;
    let mut result = vec![vec![0.0; N]; M];
    for i in 0..M {
        for j in 0..N {
            // 简单的 LCG 随机数
            state = state.wrapping_mul(1103515245).wrapping_add(12345);
            result[i][j] = ((state >> 16) & 0x7FFF) as f64 / 32768.0;
        }
    }
    result
}

fn fft(input: &[f64]) -> Vec<Complex> {
    let n = input.len();
    if n == 1 {
        return vec![Complex::new(input[0], 0.0)];
    }
    let half = n / 2;
    let even: Vec<f64> = input.iter().step_by(2).copied().collect();
    let odd: Vec<f64> = input.iter().skip(1).step_by(2).copied().collect();

    let even_out = fft(&even);
    let odd_out = fft(&odd);

    let mut result = vec![Complex::new(0.0, 0.0); n];
    for k in 0..half {
        let angle = -2.0 * std::f64::consts::PI * k as f64 / n as f64;
        let twiddle = Complex::exp(angle).mul(odd_out[k]);
        result[k] = even_out[k].add(twiddle);
        result[k + half] = even_out[k].sub(twiddle);
    }
    result
}

fn compute_fft(data: &[Vec<f64>]) -> Vec<Vec<Complex>> {
    data.iter().map(|row| fft(row)).collect()
}

fn print_matrix(result: &[Vec<Complex>]) {
    for i in 0..M.min(8) {
        for j in 0..N.min(8) {
            let val = result[i][j];
            print!("({:.2},{:.2}) ", val.re, val.im);
        }
        println!();
    }
}

fn main() {
    let args: Vec<String> = env::args().collect();
    let seed = if args.len() > 1 {
        args[1].parse().unwrap_or(42)
    } else {
        42
    };

    let data = init_array(seed);
    let start = Instant::now();
    let result = compute_fft(&data);
    let duration = start.elapsed();

    println!("Finished FFT in {:.3} seconds", duration.as_secs_f64());
    print_matrix(&result);
}

