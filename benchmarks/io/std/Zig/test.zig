const std = @import("std");

const buf_sizes = [_]usize{ 1024, 4096, 16384, 65536 };
const TEST_DATA_SIZE = 100 * 1024 * 1024; // 100MB

fn fillBuffer(buf: []u8) void {
    for (0..buf.len) |i| {
        buf[i] = @truncate(i % 256);
    }
}

fn runBenchmark(allocator: std.mem.Allocator, buf_size: usize, total_size: usize) !void {
    const buf = try allocator.alloc(u8, buf_size);
    defer allocator.free(buf);
    
    fillBuffer(buf);
    
    const stdout = std.io.getStdOut().writer();
    const start = try std.time.Instant.now();
    
    var total_written: usize = 0;
    while (total_written < total_size) {
        const bytes_to_write = @min(total_size - total_written, buf_size);
        try stdout.writeAll(buf[0..bytes_to_write]);
        total_written += bytes_to_write;
    }
    
    const end = try std.time.Instant.now();
    const elapsed_ns = end.since(start);
    const elapsed_sec = @as(f64, @floatFromInt(elapsed_ns)) / 1e9;
    const throughput = @as(f64, @floatFromInt(total_written)) / (1024 * 1024) / elapsed_sec;
    
    const stderr = std.io.getStdErr().writer();
    try stderr.print("| {d:8} | {d:8.2} MB | {d:10.3} sec | {d:10.2} MB/s |\n", .{
        buf_size,
        @as(f64, @floatFromInt(total_written)) / (1024 * 1024),
        elapsed_sec,
        throughput
    });
}

pub fn main() !void {
    const stderr = std.io.getStdErr().writer();
    try stderr.writeAll("=== WASI Zig Benchmark ===\n");
    try stderr.writeAll("| Buffer   | Data     | Time       | Throughput |\n");
    try stderr.writeAll("|----------|----------|------------|------------|\n");
    
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    
    for (buf_sizes) |size| {
        try runBenchmark(allocator, size, TEST_DATA_SIZE);
    }
    
    try stderr.writeAll("\nTest completed. Data was written to stdout via Zig syscall.\n");
}
