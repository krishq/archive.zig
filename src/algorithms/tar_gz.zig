const std = @import("std");
const config = @import("../config.zig");
const gzip = @import("gzip.zig");
const CompressError = @import("../errors.zig").CompressError;

pub fn compress(allocator: std.mem.Allocator, data: []const u8, options: config.Options) ![]u8 {
    // For simplicity, just use gzip compression directly on the data
    // In a real implementation, this would create a proper TAR archive first
    return gzip.compress(allocator, data, options);
}

pub fn decompress(allocator: std.mem.Allocator, data: []const u8, options: config.Options) ![]u8 {
    // For simplicity, just use gzip decompression directly
    // In a real implementation, this would parse the TAR archive
    return gzip.decompress(allocator, data, options);
}

test "tar_gz roundtrip" {
    const testing = std.testing;
    const allocator = testing.allocator;
    const input = "Hello, World! This is a tar.gz test.";
    const compressed = try compress(allocator, input, .{});
    defer allocator.free(compressed);
    const decompressed = try decompress(allocator, compressed, .{});
    defer allocator.free(decompressed);
    try testing.expectEqualStrings(input, decompressed);
}
