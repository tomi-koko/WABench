const std = @import("std");
const builtin = @import("builtin");

const BUF_SIZE = 8192;

const SHA256_CTX = struct {
    state: [8]u32,
    bitlen: u64,
    data: [64]u8,
    datalen: usize,
};

fn rightRotate(x: u32, n: u5) u32 {
    return (x >> n) | (x << @intCast(@as(u6, 32) - n));
}

fn sha256Init(ctx: *SHA256_CTX) void {
    ctx.state = .{
        0x6a09e667, 0xbb67ae85, 0x3c6ef372, 0xa54ff53a,
        0x510e527f, 0x9b05688c, 0x1f83d9ab, 0x5be0cd19,
    };
    ctx.bitlen = 0;
    ctx.datalen = 0;
}

fn sha256Transform(ctx: *SHA256_CTX) void {
    const k = [_]u32{
        0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5, 0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,
        0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3, 0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
        0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc, 0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
        0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7, 0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,
        0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13, 0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
        0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3, 0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
        0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5, 0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
        0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208, 0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2,
    };

    var w: [64]u32 = undefined;
    var i: usize = 0;
    while (i < 16) : (i += 1) {
        w[i] = std.mem.readInt(u32, ctx.data[i*4..][0..4], .big);
    }
    while (i < 64) : (i += 1) {
        const s0 = rightRotate(w[i-15], 7) ^ rightRotate(w[i-15], 18) ^ (w[i-15] >> 3);
        const s1 = rightRotate(w[i-2], 17) ^ rightRotate(w[i-2], 19) ^ (w[i-2] >> 10);
        w[i] = w[i-16] +% s0 +% w[i-7] +% s1;
    }

    var a = ctx.state[0];
    var b = ctx.state[1];
    var c = ctx.state[2];
    var d = ctx.state[3];
    var e = ctx.state[4];
    var f = ctx.state[5];
    var g = ctx.state[6];
    var h = ctx.state[7];

    i = 0;
    while (i < 64) : (i += 1) {
        const s1 = rightRotate(e, 6) ^ rightRotate(e, 11) ^ rightRotate(e, 25);
        const ch = (e & f) ^ (~e & g);
        const temp1 = h +% s1 +% ch +% k[i] +% w[i];
        const s0 = rightRotate(a, 2) ^ rightRotate(a, 13) ^ rightRotate(a, 22);
        const maj = (a & b) ^ (a & c) ^ (b & c);
        const temp2 = s0 +% maj;

        h = g;
        g = f;
        f = e;
        e = d +% temp1;
        d = c;
        c = b;
        b = a;
        a = temp1 +% temp2;
    }

    ctx.state[0] +%= a;
    ctx.state[1] +%= b;
    ctx.state[2] +%= c;
    ctx.state[3] +%= d;
    ctx.state[4] +%= e;
    ctx.state[5] +%= f;
    ctx.state[6] +%= g;
    ctx.state[7] +%= h;
}

fn sha256Update(ctx: *SHA256_CTX, data: []const u8) void {
    var i: usize = 0;
    while (i < data.len) {
        const remaining = 64 - ctx.datalen;
        const to_copy = @min(remaining, data.len - i);

        @memcpy(ctx.data[ctx.datalen..ctx.datalen+to_copy], data[i..i+to_copy]);
        ctx.datalen += to_copy;
        i += to_copy;
        ctx.bitlen +%= @as(u64, to_copy) * 8;

        if (ctx.datalen == 64) {
            sha256Transform(ctx);
            ctx.datalen = 0;
        }
    }
}

fn sha256Final(ctx: *SHA256_CTX, hash: *[32]u8) void {
    var i = ctx.datalen;

    if (i < 56) {
        ctx.data[i] = 0x80;
        i += 1;

        while (i < 56) {
            ctx.data[i] = 0;
            i += 1;
        }
    } else {
        ctx.data[i] = 0x80;
        i += 1;

        while (i < 64) {
            ctx.data[i] = 0;
            i += 1;
        }

        sha256Transform(ctx);
        @memset(ctx.data[0..56], 0);
    }

    std.mem.writeInt(u64, ctx.data[56..][0..8], ctx.bitlen, .big);
    sha256Transform(ctx);

    for (0..8) |j| {
        std.mem.writeInt(u32, hash[j*4..][0..4], ctx.state[j], .big);
    }
}

pub fn main() !void {
    const args = try std.process.argsAlloc(std.heap.page_allocator);
    defer std.process.argsFree(std.heap.page_allocator, args);

    if (args.len != 2) {
        std.debug.print("Usage: {s} <file>\n", .{args[0]});
        return;
    }

    const file = try std.fs.cwd().openFile(args[1], .{});
    defer file.close();

    var ctx: SHA256_CTX = undefined;
    sha256Init(&ctx);

    var buffer: [BUF_SIZE]u8 = undefined;
    const start = std.time.nanoTimestamp();

    while (true) {
        const bytes_read = try file.read(&buffer);
        if (bytes_read == 0) break;
        sha256Update(&ctx, buffer[0..bytes_read]);
    }

    var hash: [32]u8 = undefined;
    sha256Final(&ctx, &hash);

    const end = std.time.nanoTimestamp();
    const elapsed = @as(f64, @floatFromInt(end - start)) / 1e9;

    std.debug.print("SHA256 time: {d:.6} sec\nHash: ", .{elapsed});
    for (hash) |b| {
        std.debug.print("{x:0>2}", .{b});
    }
    std.debug.print("\n", .{});
}
