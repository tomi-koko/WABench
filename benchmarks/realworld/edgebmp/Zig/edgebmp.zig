const std = @import("std");
const time = std.time;

fn nowSec() f64 {
    const ns = @as(f64, @floatFromInt(time.nanoTimestamp()));
    return ns / 1_000_000_000.0;
}

const BitmapFileHeader = packed struct {
    bfType: u16,
    bfSize: u32,
    bfReserved1: u16,
    bfReserved2: u16,
    bfOffBits: u32,
};

const BitmapInfoHeader = packed struct {
    biSize: u32,
    biWidth: i32,
    biHeight: i32,
    biPlanes: u16,
    biBitCount: u16,
    biCompression: u32,
    biSizeImage: u32,
    biXPelsPerMeter: i32,
    biYPelsPerMeter: i32,
    biClrUsed: u32,
    biClrImportant: u32,
};

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    if (args.len != 2) {
        std.debug.print("Usage: {s} <image.bmp>\n", .{args[0]});
        return error.InvalidArguments;
    }

    const file = try std.fs.cwd().openFile(args[1], .{});
    defer file.close();

    const reader = file.reader();

    // 读取 BitmapFileHeader（14字节）
    var fh_buf: [14]u8 = undefined;
    _ = try reader.readNoEof(&fh_buf);
    const file_header = BitmapFileHeader{
        .bfType = std.mem.readInt(u16, fh_buf[0..2], .little),
        .bfSize = std.mem.readInt(u32, fh_buf[2..6], .little),
        .bfReserved1 = std.mem.readInt(u16, fh_buf[6..8], .little),
        .bfReserved2 = std.mem.readInt(u16, fh_buf[8..10], .little),
        .bfOffBits = std.mem.readInt(u32, fh_buf[10..14], .little),
    };

    if (file_header.bfType != 0x4D42) {
        std.debug.print("Error: Not a valid BMP file\n", .{});
        return error.InvalidFormat;
    }

    // 读取 BitmapInfoHeader（40字节）
    var ih_buf: [40]u8 = undefined;
    _ = try reader.readNoEof(&ih_buf);
    const info_header = BitmapInfoHeader{
        .biSize = std.mem.readInt(u32, ih_buf[0..4], .little),
        .biWidth = std.mem.readInt(i32, ih_buf[4..8], .little),
        .biHeight = std.mem.readInt(i32, ih_buf[8..12], .little),
        .biPlanes = std.mem.readInt(u16, ih_buf[12..14], .little),
        .biBitCount = std.mem.readInt(u16, ih_buf[14..16], .little),
        .biCompression = std.mem.readInt(u32, ih_buf[16..20], .little),
        .biSizeImage = std.mem.readInt(u32, ih_buf[20..24], .little),
        .biXPelsPerMeter = std.mem.readInt(i32, ih_buf[24..28], .little),
        .biYPelsPerMeter = std.mem.readInt(i32, ih_buf[28..32], .little),
        .biClrUsed = std.mem.readInt(u32, ih_buf[32..36], .little),
        .biClrImportant = std.mem.readInt(u32, ih_buf[36..40], .little),
    };

    if (info_header.biBitCount != 24) {
        std.debug.print("Error: Only 24-bit BMP supported (got {d}-bit)\n", .{info_header.biBitCount});
        return error.UnsupportedFormat;
    }

    const width = @as(usize, @intCast(info_header.biWidth));
    const height = @as(usize, @intCast(if (info_header.biHeight < 0) -info_header.biHeight else info_header.biHeight));
    const padding = (4 - (width * 3) % 4) % 4;

    std.debug.print("Processing {d}x{d} image...\n", .{width, height});

    // 分配灰度图和输出图像缓冲区
    var gray = try allocator.alloc(u8, width * height);
    defer allocator.free(gray);
    var output = try allocator.alloc(u8, width * height);
    defer allocator.free(output);

    // 跳转到像素数据偏移
    try file.seekTo(file_header.bfOffBits);
    const row_buffer = try allocator.alloc(u8, width * 3 + padding);
    defer allocator.free(row_buffer);

    // 读取像素数据并转换为灰度图像
    for (0..height) |y| {
        _ = try reader.readNoEof(row_buffer);
        const row_start = (height - 1 - y) * width;

        for (0..width) |x| {
            const b = row_buffer[x * 3];
            const g = row_buffer[x * 3 + 1];
            const r = row_buffer[x * 3 + 2];
            gray[row_start + x] = @as(u8, @intFromFloat(
                0.299 * @as(f32, @floatFromInt(r)) +
                0.587 * @as(f32, @floatFromInt(g)) +
                0.114 * @as(f32, @floatFromInt(b))
            ));
        }
    }

    // Sobel 边缘检测
    const start = nowSec();
    const gx = [3][3]i32{ .{ -1, 0, 1 }, .{ -2, 0, 2 }, .{ -1, 0, 1 } };
    const gy = [3][3]i32{ .{ 1, 2, 1 }, .{ 0, 0, 0 }, .{ -1, -2, -1 } };

    for (1..height - 1) |y| {
        for (1..width - 1) |x| {
            var sum_x: i32 = 0;
            var sum_y: i32 = 0;

            for (0..3) |ky| {
                for (0..3) |kx| {
                    const val = gray[(y + ky - 1) * width + (x + kx - 1)];
                    sum_x += @as(i32, val) * gx[ky][kx];
                    sum_y += @as(i32, val) * gy[ky][kx];
                }
            }

            const mag = @sqrt(@as(f64, @floatFromInt(sum_x * sum_x + sum_y * sum_y)));
            output[y * width + x] = @as(u8, @intFromFloat(std.math.clamp(mag, 0, 255)));
        }
    }

    const elapsed = nowSec() - start;
    std.debug.print("Edge detection completed in {d:.3} seconds\n", .{elapsed});

    // 输出结果到 raw 文件
    const out_file = try std.fs.cwd().createFile("output.raw", .{});
    defer out_file.close();
    _ = try out_file.write(output);

    std.debug.print("Output written to output.raw\n", .{});
}

