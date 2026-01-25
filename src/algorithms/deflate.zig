const std = @import("std");
const config = @import("../config.zig");
const errors = @import("../errors.zig");
const constants = @import("../constants.zig");
const utils = @import("../utils.zig");

pub fn compress(allocator: std.mem.Allocator, data: []const u8, options: config.Options) ![]u8 {
    if (data.len == 0) return allocator.alloc(u8, 0);

    var result = std.ArrayList(u8).initCapacity(allocator, data.len) catch return error.OutOfMemory;
    errdefer result.deinit(allocator);

    const compression_level = options.level orelse 6;

    if (compression_level == 0) {
        try writeLiteralBlock(data, &result, allocator);
        return result.toOwnedSlice(allocator);
    }

    const window_size: usize = switch (compression_level) {
        0 => 0,
        1...3 => constants.CompressionConstants.window_fast,
        4...6 => constants.CompressionConstants.window_default,
        7...9 => constants.CompressionConstants.window_best,
        else => constants.CompressionConstants.window_default,
    };

    const min_match = constants.CompressionConstants.min_match;
    const max_match = constants.CompressionConstants.max_match;

    var pos: usize = 0;
    var literal_start: usize = 0;

    while (pos < data.len) {
        var best_offset: usize = 0;
        var best_length: usize = 0;

        if (pos >= min_match) {
            const search_start = if (pos > window_size) pos - window_size else 0;
            var search_pos = search_start;

            while (search_pos < pos) : (search_pos += 1) {
                var match_len: usize = 0;
                while (match_len < max_match and
                    pos + match_len < data.len and
                    data[search_pos + match_len] == data[pos + match_len])
                {
                    match_len += 1;
                    if (search_pos + match_len >= pos) break;
                }

                if (match_len >= min_match and match_len > best_length) {
                    best_offset = pos - search_pos;
                    best_length = match_len;
                }
            }
        }

        if (best_length >= min_match and best_offset <= std.math.maxInt(u16)) {
            if (pos > literal_start) {
                try writeLiteralBlock(data[literal_start..pos], &result, allocator);
            }

            try result.append(allocator, 0xFF);
            try result.appendSlice(allocator, &std.mem.toBytes(@as(u16, @intCast(best_offset))));
            try result.append(allocator, @as(u8, @intCast(@min(best_length, 255))));

            pos += best_length;
            literal_start = pos;
        } else {
            pos += 1;
        }
    }

    if (literal_start < data.len) {
        try writeLiteralBlock(data[literal_start..], &result, allocator);
    }

    try result.append(allocator, 0x00);
    return result.toOwnedSlice(allocator);
}

pub fn decompress(allocator: std.mem.Allocator, data: []const u8, options: config.Options) ![]u8 {
    _ = options;
    if (data.len == 0) return allocator.alloc(u8, 0);

    var result = std.ArrayList(u8).initCapacity(allocator, data.len * 2) catch return error.OutOfMemory;
    errdefer result.deinit(allocator);

    var pos: usize = 0;

    while (pos < data.len) {
        const byte = data[pos];

        if (byte == 0x00) {
            break;
        } else if (byte == 0xFF) {
            if (pos + 4 > data.len) return errors.CompressError.InvalidData;

            const offset = std.mem.bytesToValue(u16, data[pos + 1 ..][0..2]);
            const length = data[pos + 3];

            try utils.copyMatchData(&result, allocator, offset, length);
            pos += 4;
        } else if (byte == 0xFE) {
            if (pos + 3 > data.len) return errors.CompressError.InvalidData;

            const count = data[pos + 1];
            const value = data[pos + 2];

            try result.appendNTimes(allocator, value, count);
            pos += 3;
        } else if (byte == 0xFD) {
            if (pos + 2 > data.len) return errors.CompressError.InvalidData;

            try result.append(allocator, data[pos + 1]);
            pos += 2;
        } else {
            try result.append(allocator, byte);
            pos += 1;
        }
    }

    return result.toOwnedSlice(allocator);
}

fn writeLiteralBlock(data: []const u8, result: *std.ArrayList(u8), allocator: std.mem.Allocator) !void {
    if (data.len == 0) return;

    var i: usize = 0;
    while (i < data.len) {
        const byte = data[i];

        var run_length: usize = 1;
        while (i + run_length < data.len and
            data[i + run_length] == byte and
            run_length < constants.CompressionConstants.max_run_length)
        {
            run_length += 1;
        }

        if (run_length >= 4) {
            try result.append(allocator, 0xFE);
            try result.append(allocator, @as(u8, @intCast(run_length)));
            try result.append(allocator, byte);
            i += run_length;
        } else {
            if (byte == 0xFF or byte == 0xFE or byte == 0x00) {
                try result.append(allocator, 0xFD);
            }
            try result.append(allocator, byte);
            i += 1;
        }
    }
}

test "deflate compress and decompress" {
    const testing = std.testing;

    const data = "Hello, World! This is a test string for deflate compression.";
    const compressed = try compress(testing.allocator, data, .{});
    defer testing.allocator.free(compressed);

    const decompressed = try decompress(testing.allocator, compressed, .{});
    defer testing.allocator.free(decompressed);

    try testing.expectEqualStrings(data, decompressed);
}

test "deflate empty data" {
    const testing = std.testing;

    const data = "";
    const compressed = try compress(testing.allocator, data, .{});
    defer testing.allocator.free(compressed);

    const decompressed = try decompress(testing.allocator, compressed, .{});
    defer testing.allocator.free(decompressed);

    try testing.expectEqualStrings(data, decompressed);
}

test "deflate repetitive data" {
    const testing = std.testing;

    const data = "AAAAAAAAAAAAAAAA" ** 10;
    const compressed = try compress(testing.allocator, data, .{});
    defer testing.allocator.free(compressed);

    try testing.expect(compressed.len < data.len);

    const decompressed = try decompress(testing.allocator, compressed, .{});
    defer testing.allocator.free(decompressed);

    try testing.expectEqualStrings(data, decompressed);
}
