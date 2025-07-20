use std::env;
use std::time::Instant;
use rand::{Rng, SeedableRng};
use rand::rngs::StdRng;

const SMALL: usize = 0;
const STANDARD: usize = 1;
const LARGE: usize = 2;

const DATASET: usize = STANDARD;

const N: usize = match DATASET {
    SMALL => 50,
    LARGE => 2000,
    _ => 500,
};

fn init_matrix(n: usize, seed: u64) -> Vec<Vec<f64>> {
    let mut rng = StdRng::seed_from_u64(seed);
    let mut graph = vec![vec![0.0; n]; n];
    for i in 0..n {
        for j in 0..n {
            graph[i][j] = if i == j { 0.0 } else { rng.gen_range(1..=100) as f64 };
        }
    }
    graph
}

fn print_matrix(n: usize, graph: &Vec<Vec<f64>>) {
    for i in 0..n.min(8) {
        for j in 0..n.min(8) {
            print!("{:.2} ", graph[i][j]);
        }
        println!();
    }
}

fn floyd_warshall(n: usize, graph: &mut Vec<Vec<f64>>) {
    for k in 0..n {
        for i in 0..n {
            for j in 0..n {
                if graph[i][j] > graph[i][k] + graph[k][j] {
                    graph[i][j] = graph[i][k] + graph[k][j];
                }
            }
        }
    }
}

fn main() {
    let args: Vec<String> = env::args().collect();
    let seed = if args.len() > 1 { args[1].parse().unwrap() } else { 42 };

    let mut graph = init_matrix(N, seed);

    let start = Instant::now();
    floyd_warshall(N, &mut graph);
    let duration = start.elapsed();

    println!("Finished Floyd-Warshall in {:.3} seconds", duration.as_secs_f64());
    print_matrix(N, &graph);
}

