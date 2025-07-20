use std::time::Instant;
use rand::{Rng, SeedableRng};
use rand::rngs::StdRng;

// ---------- 可选数据规模 ----------
const DATASET: &str = "STANDARD";

// 使用函数来获取常量值
fn get_bodies() -> usize {
    match DATASET {
        "SMALL" => 100,
        "LARGE" => 5000,
        _ => 1000,
    }
}

fn get_iterations() -> usize {
    match DATASET {
        "SMALL" => 10,
        "LARGE" => 100,
        _ => 50,
    }
}

#[derive(Clone, Copy)]
struct Vec3 {
    x: f64,
    y: f64,
    z: f64,
}

#[derive(Clone, Copy)]
struct Body {
    position: Vec3,
    velocity: Vec3,
    acceleration: Vec3,
    mass: f64,
}

// ---------- 初始化天体 ----------
fn init_bodies(n: usize, seed: u64) -> Vec<Body> {
    let mut rng = StdRng::seed_from_u64(seed);
    let mut bodies = Vec::with_capacity(n);
    
    for _ in 0..n {
        bodies.push(Body {
            position: Vec3 {
                x: rng.gen::<f64>() * 100.0,
                y: rng.gen::<f64>() * 100.0,
                z: rng.gen::<f64>() * 100.0,
            },
            velocity: Vec3 {
                x: rng.gen::<f64>() * 10.0,
                y: rng.gen::<f64>() * 10.0,
                z: rng.gen::<f64>() * 10.0,
            },
            acceleration: Vec3 {
                x: 0.0,
                y: 0.0,
                z: 0.0,
            },
            mass: rng.gen::<f64>() * 1000.0 + 100.0,
        });
    }
    bodies
}

// ---------- 打印部分输出 ----------
fn print_result(bodies: &[Body]) {
    for (i, body) in bodies.iter().take(3).enumerate() {
        println!("Body {}: pos=({:.2}, {:.2}, {:.2}) vel=({:.2}, {:.2}, {:.2})",
                 i, body.position.x, body.position.y, body.position.z,
                 body.velocity.x, body.velocity.y, body.velocity.z);
    }
}

// ---------- 主计算过程 ----------
fn compute_nbody(n: usize, iterations: usize, bodies: &mut [Body]) {
    const G: f64 = 6.67430e-11; // 万有引力常数
    
    for _ in 0..iterations {
        // 重置加速度
        for body in bodies.iter_mut() {
            body.acceleration.x = 0.0;
            body.acceleration.y = 0.0;
            body.acceleration.z = 0.0;
        }
        
        // 计算引力
        for i in 0..n {
            for j in i+1..n {
                let dx = bodies[j].position.x - bodies[i].position.x;
                let dy = bodies[j].position.y - bodies[i].position.y;
                let dz = bodies[j].position.z - bodies[i].position.z;
                
                let dist_sq = dx*dx + dy*dy + dz*dz + 1e-10; // 避免除以零
                let dist = dist_sq.sqrt();
                let force = G * bodies[i].mass * bodies[j].mass / dist_sq;
                
                let fx = force * dx / dist;
                let fy = force * dy / dist;
                let fz = force * dz / dist;
                
                bodies[i].acceleration.x += fx / bodies[i].mass;
                bodies[i].acceleration.y += fy / bodies[i].mass;
                bodies[i].acceleration.z += fz / bodies[i].mass;
                
                bodies[j].acceleration.x -= fx / bodies[j].mass;
                bodies[j].acceleration.y -= fy / bodies[j].mass;
                bodies[j].acceleration.z -= fz / bodies[j].mass;
            }
        }
        
        // 更新速度和位置
        for body in bodies.iter_mut() {
            body.velocity.x += body.acceleration.x;
            body.velocity.y += body.acceleration.y;
            body.velocity.z += body.acceleration.z;
            
            body.position.x += body.velocity.x;
            body.position.y += body.velocity.y;
            body.position.z += body.velocity.z;
        }
    }
}

// ---------- 主函数 ----------
fn main() {
    let seed = std::env::args().nth(1)
        .and_then(|s| s.parse::<u64>().ok())
        .unwrap_or(42);
    
    let bodies_count = get_bodies();
    let iterations = get_iterations();
    let mut bodies = init_bodies(bodies_count, seed);

    let start = Instant::now();
    compute_nbody(bodies_count, iterations, &mut bodies);
    let duration = start.elapsed();

    println!("Finished N-body simulation in {:.3} seconds", duration.as_secs_f64());
    print_result(&bodies);
}
