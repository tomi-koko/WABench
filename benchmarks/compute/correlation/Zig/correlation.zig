const std = @import("std");

// ---------- 可选数据规模 ----------
const SMALL = 0;
const STANDARD = 1;
const LARGE = 2;

// 默认数据规模（可通过编译选项覆盖）
const DATASET = STANDARD;

const M = switch (DATASET) {
    SMALL => 50,
    LARGE => 2000,
    else => 500,
};

const N = switch (DATASET) {
    SMALL => 60,
    LARGE => 2500,
    else => 600,
};

// ---------- 初始化随机矩阵 ----------
fn initArray(m: usize, n: usize, data: *[M][N]f64, float_n: *f64, seed: u32) void {
    float_n.* = @as(f64, @floatFromInt(n));
    var rng = std.rand.DefaultPrng.init(seed);
    for (0..m) |i| {
        for (0..n) |j| {
            data[i][j] = rng.random().float(f64);
        }
    }
}

// ---------- 打印部分输出矩阵（防止被编译器优化） ----------
fn printMatrix(m: usize, symmat: *[M][M]f64) void {
    const limit = @min(8, m);
    for (0..limit) |i| {
        for (0..limit) |j| {
            std.debug.print("{d:.2} ", .{symmat[i][j]});
        }
        std.debug.print("\n", .{});
    }
}

// ---------- 主计算过程 ----------
fn computeCorrelation(
    m: usize,
    n: usize,
    float_n: f64,
    data: *[M][N]f64,
    symmat: *[M][M]f64,
    mean: *[M]f64,
    stddev: *[M]f64,
) void {
    const eps = 0.1;

    // 均值
    for (0..m) |j| {
        mean[j] = 0.0;
        for (0..n) |i| {
            mean[j] += data[j][i];
        }
        mean[j] /= float_n;
    }

    // 标准差
    for (0..m) |j| {
        stddev[j] = 0.0;
        for (0..n) |i| {
            const val = data[j][i] - mean[j];
            stddev[j] += val * val;
        }
        stddev[j] = @sqrt(stddev[j] / float_n);
        if (stddev[j] <= eps) stddev[j] = 1.0;
    }

    // 中心化并标准化
    for (0..m) |j| {
        for (0..n) |i| {
            data[j][i] -= mean[j];
            data[j][i] /= @sqrt(float_n) * stddev[j];
        }
    }

    // 相关矩阵
    for (0..m) |i| {
        symmat[i][i] = 1.0;
        for (i + 1..m) |j| {
            symmat[i][j] = 0.0;
            for (0..n) |k| {
                symmat[i][j] += data[i][k] * data[j][k];
            }
            symmat[j][i] = symmat[i][j];
        }
    }
}

// ---------- 主函数 ----------
pub fn main() !void {
    var float_n: f64 = undefined;
    var data: [M][N]f64 = undefined;
    var symmat: [M][M]f64 = undefined;
    var mean: [M]f64 = undefined;
    var stddev: [M]f64 = undefined;

    // WASI 兼容的命令行参数解析
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const args = try std.process.argsAlloc(allocator);
    const seed = if (args.len > 1) 
        try std.fmt.parseInt(u32, args[1], 10)
    else 
        42;

    initArray(M, N, &data, &float_n, seed);

    const start = std.time.nanoTimestamp();
    computeCorrelation(M, N, float_n, &data, &symmat, &mean, &stddev);
    const end = std.time.nanoTimestamp();

    const elapsed_seconds = @as(f64, @floatFromInt(end - start)) / 1e9;
    std.debug.print("Finished correlation calculation in {d:.3} seconds\n", .{elapsed_seconds});

    printMatrix(M, &symmat); // 打印前8x8子矩阵
}
