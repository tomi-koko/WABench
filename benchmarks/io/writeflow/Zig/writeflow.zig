const std = @import("std");
const os = std.os;
const fs = std.fs;
const time = std.time;
const mem = std.mem;
const math = std.math;
const Random = std.rand.Random;

const NUM_SAMPLES = 10000;
const FILENAME = "sensor_data_zig.txt";

const SensorData = struct {
    timestamp: i64,
    value: f64,
};

fn getCurrentMs() i64 {
    return @divFloor(time.nanoTimestamp(), 1000000);
}

fn generateData(allocator: std.mem.Allocator, count: usize) ![]SensorData {
    var data = try allocator.alloc(SensorData, count);
    var seed: u64 = @bitCast(u64, getCurrentMs());
    var prng = std.rand.DefaultPrng.init(seed);
    const random = prng.random();
    
    for (0..count) |i| {
        data[i] = SensorData{
            .timestamp = getCurrentMs(),
            .value = random.float(f64) * 100.0, // 0~100的随机值
        };
    }
    return data;
}

fn writeData(data: []const SensorData) !void {
    const file = try fs.cwd().createFile(FILENAME, .{});
    defer file.close();
    
    var buffer: [128]u8 = undefined;
    for (data) |item| {
        const line = try std.fmt.bufPrint(&buffer, "{d},{d:.2}\n", .{item.timestamp, item.value});
        _ = try file.write(line);
    }
}

fn readAndCalculate() !f64 {
    const file = try fs.cwd().openFile(FILENAME, .{});
    defer file.close();
    
    var sum: f64 = 0.0;
    var count: usize = 0;
    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();
    
    var line_buf: [128]u8 = undefined;
    while (try in_stream.readUntilDelimiterOrEof(&line_buf, '\n')) |line| {
        var parts = mem.split(u8, line, ",");
        const timestamp_str = parts.next() orelse continue;
        const value_str = parts.next() orelse continue;
        
        _ = std.fmt.parseInt(i64, timestamp_str, 10) catch continue;
        const value = std.fmt.parseFloat(f64, value_str) catch continue;
        
        sum += value;
        count += 1;
    }
    
    return if (count > 0) sum / @as(f64, @floatFromInt(count)) else 0.0;
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    
    var start: i64 = undefined;
    var end: i64 = undefined;
    
    // Generate data
    start = getCurrentMs();
    const data = try generateData(allocator, NUM_SAMPLES);
    end = getCurrentMs();
    std.debug.print("[Zig] Data generation time: {d} ms\n", .{end - start});
    
    // Write to file
    start = getCurrentMs();
    try writeData(data);
    end = getCurrentMs();
    std.debug.print("[Zig] Write time: {d} ms\n", .{end - start});
    
    // Read and calculate
    start = getCurrentMs();
    const avg = try readAndCalculate();
    end = getCurrentMs();
    std.debug.print("[Zig] Read & calculate time: {d} ms\n", .{end - start});
    std.debug.print("[Zig] Average value: {d:.2}\n", .{avg});
}
