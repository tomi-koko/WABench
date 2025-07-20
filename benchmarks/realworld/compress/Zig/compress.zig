const std = @import("std");

fn nowSec() f64 {
    return @as(f64, @floatFromInt(std.time.microTimestamp())) / 1_000_000.0;
}

fn simpleCompress(allocator: std.mem.Allocator, input: []const u8) ![]u8 {
    var output = std.ArrayList(u8).init(allocator);
    defer output.deinit();
    
    var i: usize = 0;
    while (i < input.len) {
        const b = input[i];
        var count: usize = 1;
        while (i + count < input.len and input[i + count] == b and count < 255) {
            count += 1;
        }
        try output.append(@intCast(count));
        try output.append(b);
        i += count;
    }
    return output.toOwnedSlice();
}

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    if (args.len != 2) {
        try stdout.print("Usage: {s} <file>\n", .{args[0]});
        std.process.exit(1);
    }

    const input_data = try std.fs.cwd().readFileAlloc(allocator, args[1], std.math.maxInt(usize));
    
    const t_start = nowSec();
    const output_data = try simpleCompress(allocator, input_data);
    const t_end = nowSec();

    try stdout.print("Compression time: {d:.6} sec\n", .{t_end - t_start});
    try stdout.print("Original size: {d} bytes\n", .{input_data.len});
    try stdout.print("Compressed size: {d} bytes\n", .{output_data.len});
}
