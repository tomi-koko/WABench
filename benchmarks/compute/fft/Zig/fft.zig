const std = @import("std");

// ---------- 可选数据规模 ----------
const SMALL = 0;
const STANDARD = 1;
const LARGE = 2;

const DATASET = STANDARD;

const M = switch (DATASET) {
    SMALL => 64,
    LARGE => 2048,
    else => 512,
};

const N = switch (DATASET) {
    SMALL => 64,
    LARGE => 2048,
    else => 512,
};

// ---------- 复数类型 ----------
const Complex = struct {
    real: f64,
    imag: f64,
};

// ---------- 初始化数组 ----------
fn initArray(m: usize, n: usize, data: *[M][N]f64, seed: u32) void {
    var rng = std.rand.DefaultPrng.init(seed);
    for (0..m) |i| {
        for (0..n) |j| {
            data[i][j] = rng.random().float(f64);
        }
    }
}

// ---------- FFT计算 ----------
fn fft(allocator: std.mem.Allocator, n: usize, in: []const f64, out: []Complex) !void {
    if (n == 1) {
        out[0] = Complex{ .real = in[0], .imag = 0 };
        return;
    }

    const half = n / 2;
    
    // 使用const声明未修改的变量
    const even_in = try allocator.alloc(f64, half);
    defer allocator.free(even_in);
    const odd_in = try allocator.alloc(f64, half);
    defer allocator.free(odd_in);
    
    const even_out = try allocator.alloc(Complex, half);
    defer allocator.free(even_out);
    const odd_out = try allocator.alloc(Complex, half);
    defer allocator.free(odd_out);

    for (0..half) |i| {
        even_in[i] = in[2 * i];
        odd_in[i] = in[2 * i + 1];
    }

    try fft(allocator, half, even_in, even_out);
    try fft(allocator, half, odd_in, odd_out);

    for (0..half) |k| {
        const angle = -2.0 * std.math.pi * @as(f64, @floatFromInt(k)) / @as(f64, @floatFromInt(n));
        const t_real = @cos(angle) * odd_out[k].real - @sin(angle) * odd_out[k].imag;
        const t_imag = @sin(angle) * odd_out[k].real + @cos(angle) * odd_out[k].imag;
        
        out[k] = Complex{
            .real = even_out[k].real + t_real,
            .imag = even_out[k].imag + t_imag,
        };
        
        out[k + half] = Complex{
            .real = even_out[k].real - t_real,
            .imag = even_out[k].imag - t_imag,
        };
    }
}

// ---------- 计算FFT矩阵 ----------
fn computeFft(allocator: std.mem.Allocator, m: usize, n: usize, data: *[M][N]f64, result: *[M][N]Complex) !void {
    for (0..m) |i| {
        try fft(allocator, n, &data[i], &result[i]);
    }
}

// ---------- 打印矩阵 ----------
fn printMatrix(m: usize, n: usize, result: *[M][N]Complex) void {
    const limit = @min(8, m);
    for (0..limit) |i| {
        for (0..@min(8, n)) |j| {
            std.debug.print("({d:.2},{d:.2}) ", .{ result[i][j].real, result[i][j].imag });
        }
        std.debug.print("\n", .{});
    }
}

// ---------- 主函数 ----------
pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var data: [M][N]f64 = undefined;
    var result: [M][N]Complex = undefined;

    const args = try std.process.argsAlloc(allocator);
    const seed = if (args.len > 1) 
        try std.fmt.parseInt(u32, args[1], 10)
    else 
        42;

    initArray(M, N, &data, seed);

    const start = std.time.nanoTimestamp();
    try computeFft(allocator, M, N, &data, &result);
    const end = std.time.nanoTimestamp();

    const elapsed_seconds = @as(f64, @floatFromInt(end - start)) / 1e9;
    std.debug.print("Finished FFT in {d:.3} seconds\n", .{elapsed_seconds});

    printMatrix(M, N, &result);
}
