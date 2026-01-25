const std = @import("std");
const config = @import("../config.zig");
const errors = @import("../errors.zig");
const constants = @import("../constants.zig");
const utils = @import("../utils.zig");
const deflate = @import("deflate.zig");

pub fn compress(allocator: std.mem.Allocator, data: []const u8, options: config.Options) ![]u8 {
    var result = std.ArrayList(u8).initCapacity(allocator, data.len + 50) catch return error.OutOfMemory;
    errdefer result.deinit(allocator);

    try result.appendSlice(allocator, &constants.Magic.gzip);
    try result.append(allocator, 0x08);
    try result.append(allocator, 0x00);

    const timestamp = @as(u32, @intCast(std.time.timestamp()));
    try result.appendSlice(allocator, &std.mem.toBytes(timestamp));

    try result.append(allocator, 0x00);
    try result.append(allocator, 0xFF);

    const compressed_data = try deflate.compress(allocator, data, options);
    defer allocator.free(compressed_data);

    try result.appendSlice(allocator, compressed_data);

    const crc32 = utils.calculateCRC32(data);
    try result.appendSlice(allocator, &std.mem.toBytes(crc32));

    const size = @as(u32, @intCast(data.len));
    try result.appendSlice(allocator, &std.mem.toBytes(size));

    return result.toOwnedSlice(allocator);
}

pub fn decompress(allocator: std.mem.Allocator, data: []const u8, options: config.Options) ![]u8 {
    if (data.len < 18) return errors.CompressError.InvalidData;

    if (!std.mem.eql(u8, data[0..2], &constants.Magic.gzip)) {
        return errors.CompressError.InvalidMagic;
    }

    if (data[2] != 0x08) {
        return errors.CompressError.UnsupportedAlgorithm;
    }

    const flags = data[3];
    var pos: usize = 10;

    if (flags & 0x04 != 0) {
        if (pos + 2 > data.len) return errors.CompressError.InvalidData;
        const xlen = std.mem.readInt(u16, data[pos..][0..2], .little);
        pos += 2 + xlen;
    }

    if (flags & 0x08 != 0) {
        while (pos < data.len and data[pos] != 0) pos += 1;
        pos += 1;
    }

    if (flags & 0x10 != 0) {
        while (pos < data.len and data[pos] != 0) pos += 1;
        pos += 1;
    }

    if (flags & 0x02 != 0) {
        pos += 2;
    }

    if (pos + 8 > data.len) return errors.CompressError.InvalidData;

    const compressed_data = data[pos .. data.len - 8];
    const stored_crc = std.mem.readInt(u32, data[data.len - 8 ..][0..4], .little);
    const stored_size = std.mem.readInt(u32, data[data.len - 4 ..][0..4], .little);

    const decompressed = try deflate.decompress(allocator, compressed_data, options);
    errdefer allocator.free(decompressed);

    if (decompressed.len != stored_size) {
        return errors.CompressError.CorruptedStream;
    }

    const calculated_crc = utils.calculateCRC32(decompressed);
    if (calculated_crc != stored_crc) {
        return errors.CompressError.ChecksumMismatch;
    }

    return decompressed;
}

test "gzip compress and decompress" {
    const testing = std.testing;

    const data = "Hello, World! This is a test string for gzip compression.";
    const compressed = try compress(testing.allocator, data, .{});
    defer testing.allocator.free(compressed);

    try testing.expect(std.mem.startsWith(u8, compressed, &constants.Magic.gzip));

    const decompressed = try decompress(testing.allocator, compressed, .{});
    defer testing.allocator.free(decompressed);

    try testing.expectEqualStrings(data, decompressed);
}

test "gzip empty data" {
    const testing = std.testing;

    const data = "";
    const compressed = try compress(testing.allocator, data, .{});
    defer testing.allocator.free(compressed);

    const decompressed = try decompress(testing.allocator, compressed, .{});
    defer testing.allocator.free(decompressed);

    try testing.expectEqualStrings(data, decompressed);
}
