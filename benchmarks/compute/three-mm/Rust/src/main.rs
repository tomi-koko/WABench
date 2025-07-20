use rand::{Rng, SeedableRng};
use rand::rngs::StdRng;
use std::time::Instant;

// ---------- 可选数据规模 ----------
const SMALL: u8 = 0;
const STANDARD: u8 = 1;
const LARGE: u8 = 2;

const DATASET: u8 = SMALL;

const NI: usize = if DATASET == SMALL {
    250
} else if DATASET == LARGE {
    2000
} else {
    500
};

const NJ: usize = if DATASET == SMALL {
    300
} else if DATASET == LARGE {
    2200
} else {
    600
};

const NK: usize = if DATASET == SMALL {
    350
} else if DATASET == LARGE {
    2400
} else {
    700
};

const NL: usize = if DATASET == SMALL {
    400
} else if DATASET == LARGE {
    2600
} else {
    800
};

const NM: usize = if DATASET == SMALL {
    450
} else if DATASET == LARGE {
    2800
} else {
    900
};

// ---------- 初始化随机矩阵 ----------
fn init_array(seed: u64) -> (Vec<Vec<f64>>, Vec<Vec<f64>>, Vec<Vec<f64>>, Vec<Vec<f64>>) {
    let mut rng = StdRng::seed_from_u64(seed);
    
    let A: Vec<Vec<f64>> = (0..NI)
        .map(|_| (0..NK).map(|_| rng.gen::<f64>() * 10.0).collect())
        .collect();
    
    let B: Vec<Vec<f64>> = (0..NK)
        .map(|_| (0..NJ).map(|_| rng.gen::<f64>() * 10.0).collect())
        .collect();
    
    let C: Vec<Vec<f64>> = (0..NJ)
        .map(|_| (0..NM).map(|_| rng.gen::<f64>() * 10.0).collect())
        .collect();
    
    let D: Vec<Vec<f64>> = (0..NM)
        .map(|_| (0..NL).map(|_| rng.gen::<f64>() * 10.0).collect())
        .collect();
    
    (A, B, C, D)
}

// ---------- 打印部分输出矩阵 ----------
fn print_matrix(G: &[Vec<f64>]) {
    for i in 0..8.min(G.len()) {
        for l in 0..8.min(G[i].len()) {
            print!("{:.2} ", G[i][l]);
        }
        println!();
    }
}

// ---------- 主计算过程 ----------
fn compute_3mm(
    A: &[Vec<f64>],
    B: &[Vec<f64>],
    C: &[Vec<f64>],
    D: &[Vec<f64>],
) -> Vec<Vec<f64>> {
    // E = A * B
    let mut E = vec![vec![0.0; NJ]; NI];
    for i in 0..NI {
        for j in 0..NJ {
            for k in 0..NK {
                E[i][j] += A[i][k] * B[k][j];
            }
        }
    }
    
    // F = C * D
    let mut F = vec![vec![0.0; NL]; NJ];
    for j in 0..NJ {
        for l in 0..NL {
            for m in 0..NM {
                F[j][l] += C[j][m] * D[m][l];
            }
        }
    }
    
    // G = E * F
    let mut G = vec![vec![0.0; NL]; NI];
    for i in 0..NI {
        for l in 0..NL {
            for j in 0..NJ {
                G[i][l] += E[i][j] * F[j][l];
            }
        }
    }
    
    G
}

// ---------- 主函数 ----------
fn main() {
    let seed = std::env::args()
        .nth(1)
        .and_then(|s| s.parse::<u64>().ok())
        .unwrap_or(42);
    
    let (A, B, C, D) = init_array(seed);
    
    let start = Instant::now();
    let G = compute_3mm(&A, &B, &C, &D);
    let duration = start.elapsed();
    
    println!("Finished 3mm calculation in {:.3} seconds", duration.as_secs_f64());
    print_matrix(&G);
}
