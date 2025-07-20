use std::env;
use std::time::Instant;
use rand::{Rng, SeedableRng};  // 同时导入两个 trait
use rand::rngs::StdRng;


const SMALL: usize = 0;
const STANDARD: usize = 1;
const LARGE: usize = 2;

const DATASET: usize = STANDARD;

const M: usize = match DATASET {
    SMALL => 50,
    LARGE => 2000,
    _ => 500,
};

const N: usize = match DATASET {
    SMALL => 60,
    LARGE => 2500,
    _ => 600,
};

fn init_array(seed: u64) -> (Vec<Vec<f64>>, f64) {
    let mut data = vec![vec![0.0; N]; M];
    let float_n = N as f64;
    let mut rng = rand::rngs::StdRng::seed_from_u64(seed);
    //use rand::Rng;
    for i in 0..M {
        for j in 0..N {
            data[i][j] = rng.gen::<f64>();
        }
    }
    (data, float_n)
}

fn print_matrix(symmat: &Vec<Vec<f64>>) {
    for i in 0..M.min(8) {
        for j in 0..M.min(8) {
            print!("{:.2} ", symmat[i][j]);
        }
        println!();
    }
}

fn compute_correlation(data: &mut Vec<Vec<f64>>, float_n: f64) -> Vec<Vec<f64>> {
    let mut mean = vec![0.0; M];
    let mut stddev = vec![0.0; M];
    let mut symmat = vec![vec![0.0; M]; M];
    let eps = 0.1;

    for j in 0..M {
        mean[j] = data[j].iter().sum::<f64>() / float_n;
    }

    for j in 0..M {
        stddev[j] = data[j].iter().map(|&v| (v - mean[j]).powi(2)).sum::<f64>() / float_n;
        stddev[j] = stddev[j].sqrt();
        if stddev[j] <= eps {
            stddev[j] = 1.0;
        }
    }

    for j in 0..M {
        for i in 0..N {
            data[j][i] = (data[j][i] - mean[j]) / (float_n.sqrt() * stddev[j]);
        }
    }

    for i in 0..M {
        symmat[i][i] = 1.0;
        for j in (i + 1)..M {
            symmat[i][j] = (0..N).map(|k| data[i][k] * data[j][k]).sum();
            symmat[j][i] = symmat[i][j];
        }
    }

    symmat
}

fn main() {
    let args: Vec<String> = env::args().collect();
    let seed: u64 = if args.len() > 1 { args[1].parse().unwrap() } else { 42 };

    let (mut data, float_n) = init_array(seed);
    let start = Instant::now();
    let symmat = compute_correlation(&mut data, float_n);
    let duration = start.elapsed();

    println!("Finished correlation calculation in {:.3} seconds", duration.as_secs_f64());
    print_matrix(&symmat);
}

