const std = @import("std");
const print = std.debug.print;

// ---------- 可选数据规模 ----------
const DataSet = enum {
    small,
    standard,
    large,
};

const dataset: DataSet = .small;

const NI: usize = switch (dataset) {
    .small => 250,
    .large => 2000,
    else => 500,
};
const NJ: usize = switch (dataset) {
    .small => 300,
    .large => 2200,
    else => 600,
};
const NK: usize = switch (dataset) {
    .small => 350,
    .large => 2400,
    else => 700,
};
const NL: usize = switch (dataset) {
    .small => 400,
    .large => 2600,
    else => 800,
};
const NM: usize = switch (dataset) {
    .small => 450,
    .large => 2800,
    else => 900,
};

// ---------- 初始化随机矩阵 ----------
fn initArray(
    A: *[NI][NK]f64,
    B: *[NK][NJ]f64,
    C: *[NJ][NM]f64,
    D: *[NM][NL]f64,
    seed: u32,
) void {
    var prng = std.rand.DefaultPrng.init(seed);
    const random = prng.random();

    for (0..NI) |i| {
        for (0..NK) |k| {
            A[i][k] = random.float(f64) * 10;
        }
    }

    for (0..NK) |k| {
        for (0..NJ) |j| {
            B[k][j] = random.float(f64) * 10;
        }
    }

    for (0..NJ) |j| {
        for (0..NM) |m| {
            C[j][m] = random.float(f64) * 10;
        }
    }

    for (0..NM) |m| {
        for (0..NL) |l| {
            D[m][l] = random.float(f64) * 10;
        }
    }
}

// ---------- 打印部分输出矩阵（防止被编译器优化） ----------
fn printMatrix(G: *[NI][NL]f64) void {
    const rows = if (NI < 8) NI else 8;
    const cols = if (NL < 8) NL else 8;

    for (0..rows) |i| {
        for (0..cols) |l| {
            print("{d:.2} ", .{G[i][l]});
        }
        print("\n", .{});
    }
}

// ---------- 主计算过程 ----------
fn compute3mm(
    A: *const [NI][NK]f64,
    B: *const [NK][NJ]f64,
    C: *const [NJ][NM]f64,
    D: *const [NM][NL]f64,
    E: *[NI][NJ]f64,
    F: *[NJ][NL]f64,
    G: *[NI][NL]f64,
) void {
    // E = A * B
    for (0..NI) |i| {
        for (0..NJ) |j| {
            E[i][j] = 0.0;
            for (0..NK) |k| {
                E[i][j] += A[i][k] * B[k][j];
            }
        }
    }

    // F = C * D
    for (0..NJ) |j| {
        for (0..NL) |l| {
            F[j][l] = 0.0;
            for (0..NM) |m| {
                F[j][l] += C[j][m] * D[m][l];
            }
        }
    }

    // G = E * F
    for (0..NI) |i| {
        for (0..NL) |l| {
            G[i][l] = 0.0;
            for (0..NJ) |j| {
                G[i][l] += E[i][j] * F[j][l];
            }
        }
    }
}

// ---------- 主函数 ----------
pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var A: [NI][NK]f64 = undefined;
    var B: [NK][NJ]f64 = undefined;
    var C: [NJ][NM]f64 = undefined;
    var D: [NM][NL]f64 = undefined;
    var E: [NI][NJ]f64 = undefined;
    var F: [NJ][NL]f64 = undefined;
    var G: [NI][NL]f64 = undefined;

    // 处理命令行参数
    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    const seed = if (args.len > 1) 
        try std.fmt.parseInt(u32, args[1], 10)
    else 
        42;

    initArray(&A, &B, &C, &D, seed);

    const start = std.time.milliTimestamp();
    compute3mm(&A, &B, &C, &D, &E, &F, &G);
    const end = std.time.milliTimestamp();

    const elapsed = @as(f64, @floatFromInt(end - start)) / 1000.0;
    print("Finished 3mm calculation in {d:.3} seconds\n", .{elapsed});

    printMatrix(&G); // 打印前8x8子矩阵
}
