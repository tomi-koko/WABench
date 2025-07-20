const std = @import("std");

pub fn main() !void {
    var data: [1024]u8 = undefined;
    @memset(&data, 0);

    for (0..1000) |i| {
        var fname: [64]u8 = undefined;
        const written = try std.fmt.bufPrint(&fname, "data/smallfile_{d}.bin", .{i});
        const file = try std.fs.cwd().createFile(written, .{});
        defer file.close();
        try file.writeAll(&data);
    }
}
