const std = @import("std");

// ---------- 可选数据规模 ----------
const SMALL = 0;
const STANDARD = 1;
const LARGE = 2;

const DATASET = STANDARD;

const N = switch (DATASET) {
    SMALL => 50,
    LARGE => 2000,
    else => 500,
};

// ---------- 初始化矩阵 ----------
fn initMatrix(n: usize, graph: *[N][N]f64, seed: u32) void {
    var rng = std.rand.DefaultPrng.init(seed);
    for (0..n) |i| {
        for (0..n) |j| {
            graph[i][j] = if (i == j) 
                0.0 
            else 
                @as(f64, @floatFromInt(rng.random().intRangeAtMost(u8, 1, 100)));
        }
    }
}

// ---------- 打印矩阵 ----------
fn printMatrix(n: usize, graph: *[N][N]f64) void {
    const limit = @min(8, n);
    for (0..limit) |i| {
        for (0..limit) |j| {
            std.debug.print("{d:.2} ", .{graph[i][j]});
        }
        std.debug.print("\n", .{});
    }
}

// ---------- Floyd-Warshall算法 ----------
fn floydWarshall(n: usize, graph: *[N][N]f64) void {
    for (0..n) |k| {
        for (0..n) |i| {
            for (0..n) |j| {
                const new_dist = graph[i][k] + graph[k][j];
                if (graph[i][j] > new_dist) {
                    graph[i][j] = new_dist;
                }
            }
        }
    }
}

// ---------- 主函数 ----------
pub fn main() !void {
    var graph: [N][N]f64 = undefined;

    // WASI兼容的命令行参数解析
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const args = try std.process.argsAlloc(allocator);
    const seed = if (args.len > 1) 
        try std.fmt.parseInt(u32, args[1], 10)
    else 
        42;

    initMatrix(N, &graph, seed);

    const start = std.time.nanoTimestamp();
    floydWarshall(N, &graph);
    const end = std.time.nanoTimestamp();

    const elapsed_seconds = @as(f64, @floatFromInt(end - start)) / 1e9;
    std.debug.print("Finished Floyd-Warshall in {d:.3} seconds\n", .{elapsed_seconds});

    printMatrix(N, &graph);
}
