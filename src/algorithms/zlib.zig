const std = @import("std");
const config = @import("../config.zig");
const errors = @import("../errors.zig");
const constants = @import("../constants.zig");
const utils = @import("../utils.zig");
const deflate = @import("deflate.zig");

pub fn compress(allocator: std.mem.Allocator, data: []const u8, options: config.Options) ![]u8 {
    var result = std.ArrayList(u8).initCapacity(allocator, data.len + 50) catch return error.OutOfMemory;
    errdefer result.deinit(allocator);

    try result.appendSlice(allocator, &constants.Magic.zlib);

    const compressed_data = try deflate.compress(allocator, data, options);
    defer allocator.free(compressed_data);

    try result.appendSlice(allocator, compressed_data);

    const adler32 = calculateAdler32(data);
    try result.appendSlice(allocator, &std.mem.toBytes(std.mem.nativeToBig(u32, adler32)));

    return result.toOwnedSlice(allocator);
}

pub fn decompress(allocator: std.mem.Allocator, data: []const u8, options: config.Options) ![]u8 {
    if (data.len < 6) return errors.CompressError.InvalidData;

    if (!std.mem.eql(u8, data[0..2], &constants.Magic.zlib)) {
        return errors.CompressError.InvalidMagic;
    }

    const compressed_data = data[2 .. data.len - 4];
    const stored_adler = std.mem.readInt(u32, data[data.len - 4 ..][0..4], .big);

    const decompressed = try deflate.decompress(allocator, compressed_data, options);
    errdefer allocator.free(decompressed);

    const calculated_adler = calculateAdler32(decompressed);
    if (calculated_adler != stored_adler) {
        allocator.free(decompressed);
        return errors.CompressError.ChecksumMismatch;
    }

    return decompressed;
}

fn calculateAdler32(data: []const u8) u32 {
    const MOD_ADLER = 65521;
    var a: u32 = 1;
    var b: u32 = 0;

    for (data) |byte| {
        a = (a + byte) % MOD_ADLER;
        b = (b + a) % MOD_ADLER;
    }

    return (b << 16) | a;
}

test "zlib compress and decompress" {
    const testing = std.testing;

    const data = "Hello, World! This is a test string for zlib compression.";
    const compressed = try compress(testing.allocator, data, .{});
    defer testing.allocator.free(compressed);

    try testing.expect(std.mem.startsWith(u8, compressed, &constants.Magic.zlib));

    const decompressed = try decompress(testing.allocator, compressed, .{});
    defer testing.allocator.free(decompressed);

    try testing.expectEqualStrings(data, decompressed);
}

test "zlib adler32 checksum" {
    const data = "Wikipedia";
    const expected: u32 = 0x11E60398;
    const result = calculateAdler32(data);
    try std.testing.expectEqual(expected, result);
}
