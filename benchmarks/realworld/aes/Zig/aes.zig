const std = @import("std");
const builtin = @import("builtin");

const BLOCK_SIZE = 16;
const Nb = 4;
const Nk = 4;
const Nr = 10;

const sbox = [256]u8{
    0x63, 0x7c, 0x77, 0x7b, 0xf2, 0x6b, 0x6f, 0xc5, 0x30, 0x01, 0x67, 0x2b, 0xfe, 0xd7, 0xab, 0x76,
    0xca, 0x82, 0xc9, 0x7d, 0xfa, 0x59, 0x47, 0xf0, 0xad, 0xd4, 0xa2, 0xaf, 0x9c, 0xa4, 0x72, 0xc0,
    0xb7, 0xfd, 0x93, 0x26, 0x36, 0x3f, 0xf7, 0xcc, 0x34, 0xa5, 0xe5, 0xf1, 0x71, 0xd8, 0x31, 0x15,
    0x04, 0xc7, 0x23, 0xc3, 0x18, 0x96, 0x05, 0x9a, 0x07, 0x12, 0x80, 0xe2, 0xeb, 0x27, 0xb2, 0x75,
    0x09, 0x83, 0x2c, 0x1a, 0x1b, 0x6e, 0x5a, 0xa0, 0x52, 0x3b, 0xd6, 0xb3, 0x29, 0xe3, 0x2f, 0x84,
    0x53, 0xd1, 0x00, 0xed, 0x20, 0xfc, 0xb1, 0x5b, 0x6a, 0xcb, 0xbe, 0x39, 0x4a, 0x4c, 0x58, 0xcf,
    0xd0, 0xef, 0xaa, 0xfb, 0x43, 0x4d, 0x33, 0x85, 0x45, 0xf9, 0x02, 0x7f, 0x50, 0x3c, 0x9f, 0xa8,
    0x51, 0xa3, 0x40, 0x8f, 0x92, 0x9d, 0x38, 0xf5, 0xbc, 0xb6, 0xda, 0x21, 0x10, 0xff, 0xf3, 0xd2,
    0xcd, 0x0c, 0x13, 0xec, 0x5f, 0x97, 0x44, 0x17, 0xc4, 0xa7, 0x7e, 0x3d, 0x64, 0x5d, 0x19, 0x73,
    0x60, 0x81, 0x4f, 0xdc, 0x22, 0x2a, 0x90, 0x88, 0x46, 0xee, 0xb8, 0x14, 0xde, 0x5e, 0x0b, 0xdb,
    0xe0, 0x32, 0x3a, 0x0a, 0x49, 0x06, 0x24, 0x5c, 0xc2, 0xd3, 0xac, 0x62, 0x91, 0x95, 0xe4, 0x79,
    0xe7, 0xc8, 0x37, 0x6d, 0x8d, 0xd5, 0x4e, 0xa9, 0x6c, 0x56, 0xf4, 0xea, 0x65, 0x7a, 0xae, 0x08,
    0xba, 0x78, 0x25, 0x2e, 0x1c, 0xa6, 0xb4, 0xc6, 0xe8, 0xdd, 0x74, 0x1f, 0x4b, 0xbd, 0x8b, 0x8a,
    0x70, 0x3e, 0xb5, 0x66, 0x48, 0x03, 0xf6, 0x0e, 0x61, 0x35, 0x57, 0xb9, 0x86, 0xc1, 0x1d, 0x9e,
    0xe1, 0xf8, 0x98, 0x11, 0x69, 0xd9, 0x8e, 0x94, 0x9b, 0x1e, 0x87, 0xe9, 0xce, 0x55, 0x28, 0xdf,
    0x8c, 0xa1, 0x89, 0x0d, 0xbf, 0xe6, 0x42, 0x68, 0x41, 0x99, 0x2d, 0x0f, 0xb0, 0x54, 0xbb, 0x16,
};

const rcon = [11]u8{ 0x00, 0x01, 0x02, 0x04, 0x08, 0x10, 0x20, 0x40, 0x80, 0x1B, 0x36 };

fn KeyExpansion(RoundKey: []u8, Key: []const u8) void {
    var i: usize = 0;
    while (i < Nk) : (i += 1) {
        RoundKey[i*4] = Key[i*4];
        RoundKey[i*4+1] = Key[i*4+1];
        RoundKey[i*4+2] = Key[i*4+2];
        RoundKey[i*4+3] = Key[i*4+3];
    }
    
    i = Nk;
    while (i < Nb * (Nr + 1)) : (i += 1) {
        var temp = [4]u8{
            RoundKey[(i-1)*4],
            RoundKey[(i-1)*4+1],
            RoundKey[(i-1)*4+2],
            RoundKey[(i-1)*4+3],
        };
        
        if (i % Nk == 0) {
            const t = temp[0];
            temp[0] = sbox[temp[1]];
            temp[1] = sbox[temp[2]];
            temp[2] = sbox[temp[3]];
            temp[3] = sbox[t];
            temp[0] ^= rcon[i / Nk];
        }
        
        var j: usize = 0;
        while (j < 4) : (j += 1) {
            RoundKey[i*4+j] = RoundKey[(i-Nk)*4+j] ^ temp[j];
        }
    }
}

fn SubBytes(state: []u8) void {
    for (state) |*byte| {
        byte.* = sbox[byte.*];
    }
}

fn ShiftRows(state: []u8) void {
    var temp = state[1];
    state[1] = state[5];
    state[5] = state[9];
    state[9] = state[13];
    state[13] = temp;
    
    temp = state[2];
    state[2] = state[10];
    state[10] = temp;
    
    temp = state[6];
    state[6] = state[14];
    state[14] = temp;
    
    temp = state[3];
    state[3] = state[15];
    state[15] = state[11];
    state[11] = state[7];
    state[7] = temp;
}

fn xtime(x: u8) u8 {
    return (x << 1) ^ ((x >> 7) * 0x1b);
}

fn MixColumns(state: []u8) void {
    var tmp: [16]u8 = undefined;
    
    var i: usize = 0;
    while (i < 4) : (i += 1) {
        const idx = i * 4;
        tmp[idx] = xtime(state[idx]) ^ xtime(state[idx+1]) ^ state[idx+1] ^ state[idx+2] ^ state[idx+3];
        tmp[idx+1] = state[idx] ^ xtime(state[idx+1]) ^ xtime(state[idx+2]) ^ state[idx+2] ^ state[idx+3];
        tmp[idx+2] = state[idx] ^ state[idx+1] ^ xtime(state[idx+2]) ^ xtime(state[idx+3]) ^ state[idx+3];
        tmp[idx+3] = xtime(state[idx]) ^ state[idx] ^ state[idx+1] ^ state[idx+2] ^ xtime(state[idx+3]);
    }
    
    i = 0;
    while (i < 16) : (i += 1) {
        state[i] = tmp[i];
    }
}

fn AddRoundKey(state: []u8, RoundKey: []const u8, round: usize) void {
    var i: usize = 0;
    while (i < 16) : (i += 1) {
        state[i] ^= RoundKey[round * Nb * 4 + i];
    }
}

fn AES128_ECB_encrypt(input: []const u8, key: []const u8) [16]u8 {
    var state: [16]u8 = undefined;
    @memcpy(&state, input[0..16]);
    
    var RoundKey: [176]u8 = undefined;
    KeyExpansion(&RoundKey, key);
    
    AddRoundKey(&state, &RoundKey, 0);
    
    var round: usize = 1;
    while (round < Nr) : (round += 1) {
        SubBytes(&state);
        ShiftRows(&state);
        MixColumns(&state);
        AddRoundKey(&state, &RoundKey, round);
    }
    
    SubBytes(&state);
    ShiftRows(&state);
    AddRoundKey(&state, &RoundKey, Nr);
    
    return state;
}

fn now_sec() f64 {
    return @as(f64, @floatFromInt(std.time.nanoTimestamp())) / 1_000_000_000.0;
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
    
    const fsize = try file.getEndPos();
    const fsize_usize = @as(usize, @intCast(fsize));
    const padded = @as(usize, @intCast((fsize + BLOCK_SIZE - 1) / BLOCK_SIZE * BLOCK_SIZE));
    
    var input = try std.heap.page_allocator.alloc(u8, padded);
    defer std.heap.page_allocator.free(input);
    
    var output = try std.heap.page_allocator.alloc(u8, padded);
    defer std.heap.page_allocator.free(output);
    
    _ = try file.readAll(input[0..fsize_usize]);
    @memset(input[fsize_usize..padded], 0);
    
    const key = [_]u8{0} ** 16; // All zero key
    
    const start = now_sec();
    var i: usize = 0;
    while (i < padded) : (i += BLOCK_SIZE) {
        const encrypted = AES128_ECB_encrypt(input[i..i+BLOCK_SIZE], &key);
        @memcpy(output[i..i+BLOCK_SIZE], &encrypted);
    }
    const end = now_sec();
    
    std.debug.print("AES encryption time: {d:.6} sec ({d:.2} MB)\n", .{
        end - start, 
        @as(f64, @floatFromInt(padded)) / (1024 * 1024)
    });
    
    const out_file = try std.fs.cwd().createFile("enc_output.bin", .{});
    defer out_file.close();
    
    _ = try out_file.writeAll(output);
}
