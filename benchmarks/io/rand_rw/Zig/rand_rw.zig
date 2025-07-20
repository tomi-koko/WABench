const std = @import("std");
const fs = std.fs;
const os = std.os;
const math = std.math;
const time = std.time;

const FILESIZE = 104857600; // 100 MB
const OPS = 10000;
const BLOCK_SIZE = 4096;

pub fn main() !void {
    // 使用 std.fs 打开/创建文件
    const file = try fs.cwd().createFile("randio.bin", .{
        .read = true,
        .truncate = false,
    });
    defer file.close();

    // 设置文件大小 (对应 ftruncate)
    try file.setEndPos(FILESIZE);

    // 未初始化的缓冲区 (与 C 行为一致)
    var buf: [BLOCK_SIZE]u8 = undefined;

    // 初始化随机数生成器 (对应 srand(time(NULL)))
    var prng = std.rand.DefaultPrng.init(@intCast(time.timestamp()));
    const rand = prng.random();

    var i: usize = 0;
    while (i < OPS) : (i += 1) {
        // 计算随机偏移量 (对应 (rand() % (FILESIZE / 4096)) * 4096)
        const offset = blk: {
            const max_blocks = FILESIZE / BLOCK_SIZE;
            const block_idx = rand.intRangeAtMost(usize, 0, max_blocks - 1);
            break :blk block_idx * BLOCK_SIZE;
        };

        // 定位文件指针 (对应 lseek)
        try file.seekTo(offset);

        // 写入数据 (对应 write)
        try file.writeAll(&buf);
    }
}
