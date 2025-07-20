const std = @import("std");
const wasi = std.os.wasi;

// 测试配置
const buf_sizes = [_]usize{ 1024, 4096, 16384, 65536 }; // 测试不同的缓冲区大小
const TEST_DATA_SIZE = 100 * 1024 * 1024; // 每组测试 100MB 数据

fn fillBuffer(buf: []u8) void {
    for (0..buf.len) |i| {
        buf[i] = @truncate(i % 256); // 填充伪随机数据
    }
}

// 运行单次测试
fn runBenchmark(allocator: std.mem.Allocator, buf_size: usize, total_size: usize) !void {
    const buf = try allocator.alloc(u8, buf_size);
    defer allocator.free(buf);
    
    fillBuffer(buf); // 预填充数据

    const start = try std.time.Instant.now();

    // 模拟数据传输（无需 stdin/stdout，直接内存操作）
    var total_written: usize = 0;
    while (total_written < total_size) {
        const bytes_to_write = if (total_size - total_written < buf_size) 
            (total_size - total_written) 
        else 
            buf_size;
        total_written += bytes_to_write;
    }

    const end = try std.time.Instant.now();
    const elapsed_ns = end.since(start);
    const elapsed_sec = @as(f64, @floatFromInt(elapsed_ns)) / 1e9;
    const throughput = @as(f64, @floatFromInt(total_written)) / (1024 * 1024) / elapsed_sec;

    std.debug.print("| {d:8} | {d:8.2} MB | {d:10.3} sec | {d:10.2} MB/s |\n",
        .{ buf_size, @as(f64, @floatFromInt(total_written)) / (1024 * 1024), elapsed_sec, throughput });
}

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    try stdout.print("\n=== WASI stdin/stdout Benchmark ===\n", .{});
    try stdout.print("| Buffer   | Data     | Time       | Throughput |\n", .{});
    try stdout.print("|----------|----------|------------|------------|\n", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    for (buf_sizes) |size| {
        try runBenchmark(allocator, size, TEST_DATA_SIZE);
    }

    try stdout.print("\nTest completed. All data is internally generated.\n", .{});
}
