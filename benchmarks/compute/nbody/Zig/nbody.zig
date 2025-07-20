const std = @import("std");

// ---------- 可选数据规模 ----------
const SMALL = 0;
const STANDARD = 1;
const LARGE = 2;

const DATASET = STANDARD;

const BODIES = switch (DATASET) {
    SMALL => 100,
    LARGE => 5000,
    else => 1000,
};

const ITERATIONS = switch (DATASET) {
    SMALL => 10,
    LARGE => 100,
    else => 50,
};

// ---------- 向量和天体结构 ----------
const Vec3 = struct {
    x: f64,
    y: f64,
    z: f64,
};

const Body = struct {
    position: Vec3,
    velocity: Vec3,
    acceleration: Vec3,
    mass: f64,
};

// ---------- 初始化天体 ----------
fn initBodies(n: usize, bodies: *[BODIES]Body, seed: u32) void {
    var rng = std.rand.DefaultPrng.init(seed);
    for (0..n) |i| {
        bodies[i] = Body{
            .position = Vec3{
                .x = rng.random().float(f64) * 100.0,
                .y = rng.random().float(f64) * 100.0,
                .z = rng.random().float(f64) * 100.0,
            },
            .velocity = Vec3{
                .x = rng.random().float(f64) * 10.0,
                .y = rng.random().float(f64) * 10.0,
                .z = rng.random().float(f64) * 10.0,
            },
            .acceleration = Vec3{
                .x = 0.0,
                .y = 0.0,
                .z = 0.0,
            },
            .mass = rng.random().float(f64) * 1000.0 + 100.0,
        };
    }
}

// ---------- 打印部分输出 ----------
fn printResult(n: usize, bodies: *[BODIES]Body) void {
    const limit = @min(3, n);
    for (0..limit) |i| {
        std.debug.print("Body {d}: pos=({d:.2}, {d:.2}, {d:.2}) vel=({d:.2}, {d:.2}, {d:.2})\n", .{
            i,
            bodies[i].position.x,
            bodies[i].position.y,
            bodies[i].position.z,
            bodies[i].velocity.x,
            bodies[i].velocity.y,
            bodies[i].velocity.z,
        });
    }
}

// ---------- 主计算过程 ----------
fn computeNbody(n: usize, iterations: usize, bodies: *[BODIES]Body) void {
    const G = 6.67430e-11; // 万有引力常数

    for (0..iterations) |_| {
        // 重置加速度
        for (0..n) |i| {
            bodies[i].acceleration = Vec3{ .x = 0.0, .y = 0.0, .z = 0.0 };
        }

        // 计算引力
        for (0..n) |i| {
            for (i + 1..n) |j| {
                const dx = bodies[j].position.x - bodies[i].position.x;
                const dy = bodies[j].position.y - bodies[i].position.y;
                const dz = bodies[j].position.z - bodies[i].position.z;

                const dist_sq = dx * dx + dy * dy + dz * dz + 1e-10; // 避免除以零
                const dist = @sqrt(dist_sq);
                const force = G * bodies[i].mass * bodies[j].mass / dist_sq;

                const fx = force * dx / dist;
                const fy = force * dy / dist;
                const fz = force * dz / dist;

                bodies[i].acceleration.x += fx / bodies[i].mass;
                bodies[i].acceleration.y += fy / bodies[i].mass;
                bodies[i].acceleration.z += fz / bodies[i].mass;

                bodies[j].acceleration.x -= fx / bodies[j].mass;
                bodies[j].acceleration.y -= fy / bodies[j].mass;
                bodies[j].acceleration.z -= fz / bodies[j].mass;
            }
        }

        // 更新速度和位置
        for (0..n) |i| {
            bodies[i].velocity.x += bodies[i].acceleration.x;
            bodies[i].velocity.y += bodies[i].acceleration.y;
            bodies[i].velocity.z += bodies[i].acceleration.z;

            bodies[i].position.x += bodies[i].velocity.x;
            bodies[i].position.y += bodies[i].velocity.y;
            bodies[i].position.z += bodies[i].velocity.z;
        }
    }
}

// ---------- 主函数 ----------
pub fn main() !void {
    var bodies: [BODIES]Body = undefined;

    // WASI兼容的命令行参数解析
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const args = try std.process.argsAlloc(allocator);
    const seed = if (args.len > 1) 
        try std.fmt.parseInt(u32, args[1], 10)
    else 
        42;

    initBodies(BODIES, &bodies, seed);

    const start = std.time.nanoTimestamp();
    computeNbody(BODIES, ITERATIONS, &bodies);
    const end = std.time.nanoTimestamp();

    const elapsed_seconds = @as(f64, @floatFromInt(end - start)) / 1e9;
    std.debug.print("Finished N-body simulation in {d:.3} seconds\n", .{elapsed_seconds});

    printResult(BODIES, &bodies);
}
