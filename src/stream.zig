const std = @import("std");
const config = @import("config.zig");
const errors = @import("errors.zig");
const constants = @import("constants.zig");

pub const CompressStream = struct {
    allocator: std.mem.Allocator,
    algorithm: config.Algorithm,
    level: config.Level,
    buffer: std.ArrayList(u8),

    pub fn init(allocator: std.mem.Allocator, algorithm: config.Algorithm, level: config.Level) !CompressStream {
        return CompressStream{
            .allocator = allocator,
            .algorithm = algorithm,
            .level = level,
            .buffer = std.ArrayList(u8){},
        };
    }

    pub fn deinit(self: *CompressStream) void {
        self.buffer.deinit();
    }

    pub fn write(self: *CompressStream, data: []const u8) !void {
        try self.buffer.appendSlice(data);
    }

    pub fn finish(self: *CompressStream) ![]u8 {
        const algorithms = @import("archive.zig").algorithms;

        return switch (self.algorithm) {
            .none => self.allocator.dupe(u8, self.buffer.items),
            .deflate => algorithms.deflate.compress(self.allocator, self.buffer.items, self.level),
            .gzip => algorithms.gzip.compress(self.allocator, self.buffer.items, self.level),
            .zlib => algorithms.zlib.compress(self.allocator, self.buffer.items, self.level),
            .lz4 => algorithms.lz4.compress(self.allocator, self.buffer.items),
            .lzma => algorithms.lzma.compress(self.allocator, self.buffer.items, self.level),
            .xz => algorithms.xz.compress(self.allocator, self.buffer.items, self.level),
            .tar_gz => algorithms.tar_gz.compress(self.allocator, self.buffer.items, self.level),
            .zip => algorithms.zip.compress(self.allocator, self.buffer.items, self.level),
            .zstd => algorithms.zstd.compress(self.allocator, self.buffer.items, self.level),
        };
    }
};

pub const DecompressStream = struct {
    allocator: std.mem.Allocator,
    buffer: std.ArrayList(u8),

    pub fn init(allocator: std.mem.Allocator) DecompressStream {
        return DecompressStream{
            .allocator = allocator,
            .buffer = std.ArrayList(u8){},
        };
    }

    pub fn deinit(self: *DecompressStream) void {
        self.buffer.deinit();
    }

    pub fn write(self: *DecompressStream, data: []const u8) !void {
        try self.buffer.appendSlice(data);
    }

    pub fn finish(self: *DecompressStream) ![]u8 {
        const archive = @import("archive.zig");
        const detected = archive.detectFormat(self.buffer.items);
        const algorithms = archive.algorithms;

        return switch (detected) {
            .none => self.allocator.dupe(u8, self.buffer.items),
            .deflate => algorithms.deflate.decompress(self.allocator, self.buffer.items),
            .gzip => algorithms.gzip.decompress(self.allocator, self.buffer.items),
            .zlib => algorithms.zlib.decompress(self.allocator, self.buffer.items),
            .lz4 => algorithms.lz4.decompress(self.allocator, self.buffer.items),
            .lzma => algorithms.lzma.decompress(self.allocator, self.buffer.items),
            .xz => algorithms.xz.decompress(self.allocator, self.buffer.items),
            .tar_gz => algorithms.tar_gz.decompress(self.allocator, self.buffer.items),
            .zip => algorithms.zip.decompress(self.allocator, self.buffer.items),
            .zstd => algorithms.zstd.decompress(self.allocator, self.buffer.items),
        };
    }
};

test "compress stream" {
    const testing = std.testing;

    var stream = try CompressStream.init(testing.allocator, .deflate, .default);
    defer stream.deinit();

    try stream.write("Hello, ");
    try stream.write("World!");

    const compressed = try stream.finish();
    defer testing.allocator.free(compressed);

    try testing.expect(compressed.len > 0);
}

test "decompress stream" {
    const testing = std.testing;

    var compress_stream = try CompressStream.init(testing.allocator, .deflate, .default);
    defer compress_stream.deinit();

    const original = "Hello, World!";
    try compress_stream.write(original);

    const compressed = try compress_stream.finish();
    defer testing.allocator.free(compressed);

    var decompress_stream = DecompressStream.init(testing.allocator);
    defer decompress_stream.deinit();

    try decompress_stream.write(compressed);

    const decompressed = try decompress_stream.finish();
    defer testing.allocator.free(decompressed);

    try testing.expectEqualStrings(original, decompressed);
}
