const std = @import("std");
const config = @import("../config.zig");
const errors = @import("../errors.zig");
const constants = @import("../constants.zig");
const zstd = @import("zstd");

pub fn compress(allocator: std.mem.Allocator, data: []const u8, options: config.Options) ![]u8 {
    if (data.len == 0) return allocator.alloc(u8, 0);

    const compression_level = if (options.zstd_level) |l| l else if (options.level) |l| @as(c_int, @intCast(l)) else constants.ZstdConstants.default_level;
    const max_dst_size = zstd.c.ZSTD_compressBound(data.len);

    if (max_dst_size == 0) return errors.CompressError.ZstdError;

    const dest_buffer = try allocator.alloc(u8, max_dst_size);
    errdefer allocator.free(dest_buffer);

    const compressed_size = zstd.c.ZSTD_compress(
        dest_buffer.ptr,
        max_dst_size,
        data.ptr,
        data.len,
        compression_level,
    );

    if (zstd.c.ZSTD_isError(compressed_size) != 0) {
        return errors.CompressError.ZstdError;
    }

    return allocator.realloc(dest_buffer, compressed_size);
}

pub fn decompress(allocator: std.mem.Allocator, data: []const u8, options: config.Options) ![]u8 {
    _ = options;
    if (data.len == 0) return allocator.alloc(u8, 0);

    const decompressed_size = zstd.c.ZSTD_getFrameContentSize(data.ptr, data.len);

    // Handle the overflow issue with ZSTD_CONTENTSIZE_ERROR
    const ZSTD_CONTENTSIZE_ERROR: c_ulonglong = @bitCast(@as(c_longlong, -2));
    const ZSTD_CONTENTSIZE_UNKNOWN: c_ulonglong = @bitCast(@as(c_longlong, -1));

    if (decompressed_size == ZSTD_CONTENTSIZE_ERROR) {
        return errors.CompressError.ZstdError;
    }

    if (decompressed_size == ZSTD_CONTENTSIZE_UNKNOWN) {
        return decompressUnknownSize(allocator, data);
    }

    const dest_size = std.math.cast(usize, decompressed_size) orelse return error.OutOfMemory;
    const dest_buffer = try allocator.alloc(u8, dest_size);
    errdefer allocator.free(dest_buffer);

    const result_size = zstd.c.ZSTD_decompress(
        dest_buffer.ptr,
        dest_size,
        data.ptr,
        data.len,
    );

    if (zstd.c.ZSTD_isError(result_size) != 0) {
        return errors.CompressError.ZstdError;
    }

    if (result_size != decompressed_size) {
        return errors.CompressError.CorruptedStream;
    }

    return dest_buffer;
}

fn decompressUnknownSize(allocator: std.mem.Allocator, data: []const u8) ![]u8 {
    const dctx = zstd.c.ZSTD_createDCtx();
    if (dctx == null) return errors.CompressError.ZstdError;
    defer _ = zstd.c.ZSTD_freeDCtx(dctx);

    var result = std.ArrayList(u8).initCapacity(allocator, 1024) catch return error.OutOfMemory;
    errdefer result.deinit(allocator);

    const buffer_size = 64 * 1024;
    const out_buffer = try allocator.alloc(u8, buffer_size);
    defer allocator.free(out_buffer);

    var input = zstd.c.ZSTD_inBuffer{
        .src = data.ptr,
        .size = data.len,
        .pos = 0,
    };

    while (input.pos < input.size) {
        var output = zstd.c.ZSTD_outBuffer{
            .dst = out_buffer.ptr,
            .size = buffer_size,
            .pos = 0,
        };

        const ret = zstd.c.ZSTD_decompressStream(dctx, &output, &input);
        if (zstd.c.ZSTD_isError(ret) != 0) {
            return errors.CompressError.ZstdError;
        }

        try result.appendSlice(allocator, out_buffer[0..output.pos]);

        if (ret == 0) break;
    }

    return result.toOwnedSlice(allocator);
}

pub fn compressWithLevel(allocator: std.mem.Allocator, data: []const u8, level: i32) ![]u8 {
    if (data.len == 0) return allocator.alloc(u8, 0);

    const max_dst_size = zstd.c.ZSTD_compressBound(data.len);
    if (max_dst_size == 0) return errors.CompressError.ZstdError;

    const max_dst_size_usize = std.math.cast(usize, max_dst_size) orelse return error.OutOfMemory;
    const dest_buffer = try allocator.alloc(u8, max_dst_size_usize);
    errdefer allocator.free(dest_buffer);

    const compressed_size = zstd.c.ZSTD_compress(
        dest_buffer.ptr,
        max_dst_size_usize,
        data.ptr,
        data.len,
        level,
    );

    if (zstd.c.ZSTD_isError(compressed_size) != 0) {
        return errors.CompressError.ZstdError;
    }

    const compressed_size_usize = std.math.cast(usize, compressed_size) orelse return error.OutOfMemory;
    return allocator.realloc(dest_buffer, compressed_size_usize);
}

pub fn compressStream(allocator: std.mem.Allocator, data: []const u8, options: config.Options) ![]u8 {
    const cctx = zstd.c.ZSTD_createCCtx();
    if (cctx == null) return errors.CompressError.ZstdError;
    defer _ = zstd.c.ZSTD_freeCCtx(cctx);

    const compression_level = if (options.zstd_level) |l| l else if (options.level) |l| @as(c_int, @intCast(l)) else constants.ZstdConstants.default_level;
    _ = zstd.c.ZSTD_CCtx_setParameter(cctx, zstd.c.ZSTD_c_compressionLevel, compression_level);

    var result = std.ArrayList(u8).initCapacity(allocator, 1024) catch return error.OutOfMemory;
    errdefer result.deinit(allocator);

    const buffer_size = 64 * 1024;
    const out_buffer = try allocator.alloc(u8, buffer_size);
    defer allocator.free(out_buffer);

    var input = zstd.c.ZSTD_inBuffer{
        .src = data.ptr,
        .size = data.len,
        .pos = 0,
    };

    while (input.pos < input.size) {
        var output = zstd.c.ZSTD_outBuffer{
            .dst = out_buffer.ptr,
            .size = buffer_size,
            .pos = 0,
        };

        const ret = zstd.c.ZSTD_compressStream2(cctx, &output, &input, zstd.c.ZSTD_e_continue);
        if (zstd.c.ZSTD_isError(ret) != 0) {
            return errors.CompressError.ZstdError;
        }

        try result.appendSlice(allocator, out_buffer[0..output.pos]);
    }

    while (true) {
        var output = zstd.c.ZSTD_outBuffer{
            .dst = out_buffer.ptr,
            .size = buffer_size,
            .pos = 0,
        };

        const ret = zstd.c.ZSTD_compressStream2(cctx, &output, &input, zstd.c.ZSTD_e_end);
        if (zstd.c.ZSTD_isError(ret) != 0) {
            return errors.CompressError.ZstdError;
        }

        try result.appendSlice(allocator, out_buffer[0..output.pos]);

        if (ret == 0) break;
    }

    return result.toOwnedSlice(allocator);
}

test "zstd compress and decompress" {
    const testing = std.testing;

    const data = "Hello, World! This is a test string for Zstandard compression.";
    const compressed = try compress(testing.allocator, data, .{});
    defer testing.allocator.free(compressed);

    const decompressed = try decompress(testing.allocator, compressed, .{});
    defer testing.allocator.free(decompressed);

    try testing.expectEqualStrings(data, decompressed);
}

test "zstd compress with custom level" {
    const testing = std.testing;

    const data = "Hello, World! This is a test string for Zstandard compression.";
    const compressed = try compressWithLevel(testing.allocator, data, 10);
    defer testing.allocator.free(compressed);

    const decompressed = try decompress(testing.allocator, compressed, .{});
    defer testing.allocator.free(decompressed);

    try testing.expectEqualStrings(data, decompressed);
}

test "zstd stream compress" {
    const testing = std.testing;

    const data = "Hello, World! This is a test string for Zstandard streaming compression.";
    const compressed = try compressStream(testing.allocator, data, .{});
    defer testing.allocator.free(compressed);

    const decompressed = try decompress(testing.allocator, compressed, .{});
    defer testing.allocator.free(decompressed);

    try testing.expectEqualStrings(data, decompressed);
}

test "zstd empty data" {
    const testing = std.testing;

    const data = "";
    const compressed = try compress(testing.allocator, data, .{});
    defer testing.allocator.free(compressed);

    const decompressed = try decompress(testing.allocator, compressed, .{});
    defer testing.allocator.free(decompressed);

    try testing.expectEqualStrings(data, decompressed);
}
