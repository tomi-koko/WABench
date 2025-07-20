const std = @import("std");

// ---------- 可选数据规模 ----------
const SMALL = 0;
const STANDARD = 1;
const LARGE = 2;

const DATASET = STANDARD;

const SIZE = switch (DATASET) {
    SMALL => 10000,
    LARGE => 10000000,
    else => 1000000,
};

// ---------- 初始化随机数组 ----------
fn initArray(size: usize, data: *[SIZE]f64, seed: u32) void {
    var rng = std.rand.DefaultPrng.init(seed);
    for (0..size) |i| {
        data[i] = rng.random().float(f64);
    }
}

// ---------- 打印部分输出数组 ----------
fn printArray(size: usize, data: *[SIZE]f64) void {
    const limit = @min(8, size);
    for (0..limit) |i| {
        std.debug.print("{d:.2} ", .{data[i]});
    }
    std.debug.print("\n", .{});
}

// ---------- 交换函数 ----------
fn swap(a: *f64, b: *f64) void {
    const temp = a.*;
    a.* = b.*;
    b.* = temp;
}

// ---------- 分区函数 ----------
fn partition(low: isize, high: isize, data: *[SIZE]f64) isize {
    const pivot = data[@intCast(high)];
    var i = low - 1;
    
    var j = low;
    while (j < high) : (j += 1) {
        if (data[@intCast(j)] < pivot) {
            i += 1;
            swap(&data[@intCast(i)], &data[@intCast(j)]);
        }
    }
    swap(&data[@intCast(i + 1)], &data[@intCast(high)]);
    return i + 1;
}

// ---------- 快速排序主函数 ----------
fn quicksort(low: isize, high: isize, data: *[SIZE]f64) void {
    if (low < high) {
        const pi = partition(low, high, data);
        quicksort(low, pi - 1, data);
        quicksort(pi + 1, high, data);
    }
}

// ---------- 主函数 ----------
pub fn main() !void {
    var data: [SIZE]f64 = undefined;

    // WASI兼容的命令行参数解析
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const args = try std.process.argsAlloc(allocator);
    const seed = if (args.len > 1) 
        try std.fmt.parseInt(u32, args[1], 10)
    else 
        42;

    initArray(SIZE, &data, seed);

    const start = std.time.nanoTimestamp();
    quicksort(0, @as(isize, @intCast(SIZE)) - 1, &data);
    const end = std.time.nanoTimestamp();

    const elapsed_seconds = @as(f64, @floatFromInt(end - start)) / 1e9;
    std.debug.print("Finished quicksort in {d:.3} seconds\n", .{elapsed_seconds});

    printArray(SIZE, &data);
}
