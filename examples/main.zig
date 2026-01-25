const std = @import("std");
const archive = @import("archive");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    std.debug.print("=== Archive.zig Bootstrap Example ===\n\n", .{});
    std.debug.print("This example compresses and decompresses the project's own source files!\n\n", .{});

    try bootstrapProjectFiles(allocator);
    try algorithmComparison(allocator);
    try configurationExamples(allocator);

    std.debug.print("\nBootstrap example completed successfully!\n", .{});
}

fn bootstrapProjectFiles(allocator: std.mem.Allocator) !void {
    std.debug.print("1. Bootstrap Project File Compression\n", .{});
    std.debug.print("   ==================================\n", .{});

    // List of project files to compress
    const project_files = [_][]const u8{
        "src/archive.zig",
        "src/config.zig",
        "src/constants.zig",
        "src/errors.zig",
        "src/utils.zig",
        "src/stream.zig",
        "build.zig",
        "build.zig.zon",
        "README.md",
    };

    const algorithms = [_]struct { algo: archive.Algorithm, name: []const u8 }{
        .{ .algo = .gzip, .name = "gzip" },
        .{ .algo = .zstd, .name = "zstd" },
        .{ .algo = .lz4, .name = "lz4" },
        .{ .algo = .deflate, .name = "deflate" },
    };

    for (project_files) |file_path| {
        std.debug.print("\n   Processing: {s}\n", .{file_path});

        // Read the file
        const file_data = std.fs.cwd().readFileAlloc(allocator, file_path, 10 * 1024 * 1024) catch |err| {
            std.debug.print("   ERROR Could not read file: {}\n", .{err});
            continue;
        };
        defer allocator.free(file_data);

        std.debug.print("     📄 Original size: {d} bytes\n", .{file_data.len});

        // Test each algorithm
        for (algorithms) |a| {
            const compressed = archive.compress(allocator, file_data, a.algo) catch |err| {
                std.debug.print("     ERROR {s} compression failed: {}\n", .{ a.name, err });
                continue;
            };
            defer allocator.free(compressed);

            const decompressed = archive.decompress(allocator, compressed, a.algo) catch |err| {
                std.debug.print("     ERROR {s} decompression failed: {}\n", .{ a.name, err });
                continue;
            };
            defer allocator.free(decompressed);

            const verified = std.mem.eql(u8, file_data, decompressed);

            if (compressed.len < file_data.len) {
                const savings = ((1.0 - (@as(f64, @floatFromInt(compressed.len)) / @as(f64, @floatFromInt(file_data.len)))) * 100.0);
                std.debug.print("     OK {s:8}: {d:6} bytes ({d:5.1}% smaller) - {s}\n", .{ a.name, compressed.len, savings, if (verified) "PASS" else "FAIL" });
            } else {
                const increase = ((@as(f64, @floatFromInt(compressed.len)) / @as(f64, @floatFromInt(file_data.len))) - 1.0) * 100.0;
                std.debug.print("     UP {s:8}: {d:6} bytes ({d:5.1}% larger) - {s}\n", .{ a.name, compressed.len, increase, if (verified) "PASS" else "FAIL" });
            }
        }
    }
    std.debug.print("\n", .{});
}

fn algorithmComparison(allocator: std.mem.Allocator) !void {
    std.debug.print("2. Algorithm Performance Comparison\n", .{});
    std.debug.print("   ================================\n", .{});

    // Read a substantial file for better comparison
    const test_file = "src/archive.zig";
    const file_data = std.fs.cwd().readFileAlloc(allocator, test_file, 10 * 1024 * 1024) catch |err| {
        std.debug.print("   ERROR Could not read {s}: {}\n", .{ test_file, err });
        return;
    };
    defer allocator.free(file_data);

    std.debug.print("   File: Testing with {s} ({d} bytes)\n\n", .{ test_file, file_data.len });

    const algorithms = [_]struct { algo: archive.Algorithm, name: []const u8 }{
        .{ .algo = .deflate, .name = "deflate" },
        .{ .algo = .gzip, .name = "gzip" },
        .{ .algo = .zlib, .name = "zlib" },
        .{ .algo = .zstd, .name = "zstd" },
        .{ .algo = .lz4, .name = "lz4" },
        .{ .algo = .lzma, .name = "lzma" },
        .{ .algo = .xz, .name = "xz" },
        .{ .algo = .tar_gz, .name = "tar_gz" },
        .{ .algo = .zip, .name = "zip" },
    };

    std.debug.print("   Algorithm | Compressed | Ratio      | Comp Time | Decomp Time | Status\n", .{});
    std.debug.print("   ----------|------------|------------|-----------|-------------|--------\n", .{});

    for (algorithms) |algo| {
        const start_time = std.time.nanoTimestamp();

        const compressed = archive.compress(allocator, file_data, algo.algo) catch |err| {
            std.debug.print("   {s:9} | ERROR: {}\n", .{ algo.name, err });
            continue;
        };
        defer allocator.free(compressed);

        const compress_time = std.time.nanoTimestamp();

        const decompressed = archive.decompress(allocator, compressed, algo.algo) catch |err| {
            std.debug.print("   {s:9} | DECOMP ERROR: {}\n", .{ algo.name, err });
            continue;
        };
        defer allocator.free(decompressed);

        const decompress_time = std.time.nanoTimestamp();

        const verified = std.mem.eql(u8, file_data, decompressed);
        const comp_ms = @as(f64, @floatFromInt(compress_time - start_time)) / 1_000_000.0;
        const decomp_ms = @as(f64, @floatFromInt(decompress_time - compress_time)) / 1_000_000.0;

        if (compressed.len < file_data.len) {
            const savings = ((1.0 - (@as(f64, @floatFromInt(compressed.len)) / @as(f64, @floatFromInt(file_data.len)))) * 100.0);
            std.debug.print("   {s:9} | {d:8}B | {d:6.1}% less | {d:7.2}ms | {d:9.2}ms | {s}\n", .{ algo.name, compressed.len, savings, comp_ms, decomp_ms, if (verified) "OK" else "FAIL" });
        } else {
            const increase = ((@as(f64, @floatFromInt(compressed.len)) / @as(f64, @floatFromInt(file_data.len))) - 1.0) * 100.0;
            std.debug.print("   {s:9} | {d:8}B | {d:6.1}% more | {d:7.2}ms | {d:9.2}ms | {s}\n", .{ algo.name, compressed.len, increase, comp_ms, decomp_ms, if (verified) "OK" else "FAIL" });
        }
    }
    std.debug.print("\n", .{});
}

fn configurationExamples(allocator: std.mem.Allocator) !void {
    std.debug.print("3. Configuration Examples\n", .{});
    std.debug.print("   ======================\n", .{});

    // Read build.zig for configuration testing
    const config_test_file = "build.zig";
    const file_data = std.fs.cwd().readFileAlloc(allocator, config_test_file, 10 * 1024 * 1024) catch |err| {
        std.debug.print("   ERROR Could not read {s}: {}\n", .{ config_test_file, err });
        return;
    };
    defer allocator.free(file_data);

    std.debug.print("   File: Testing configurations with {s} ({d} bytes)\n\n", .{ config_test_file, file_data.len });

    // ZSTD level comparison
    std.debug.print("   ZSTD Compression Levels:\n", .{});
    const zstd_levels = [_]c_int{ 1, 3, 6, 10, 15, 19, 22 };
    for (zstd_levels) |level| {
        const config = archive.CompressionConfig.init(.zstd).withZstdLevel(level);
        const start_time = std.time.nanoTimestamp();

        const compressed = archive.compressWithConfig(allocator, file_data, config) catch |err| {
            std.debug.print("     Level {d:2}: ERROR - {}\n", .{ level, err });
            continue;
        };
        defer allocator.free(compressed);

        const compress_time = std.time.nanoTimestamp();
        const comp_ms = @as(f64, @floatFromInt(compress_time - start_time)) / 1_000_000.0;

        if (compressed.len < file_data.len) {
            const savings = ((1.0 - (@as(f64, @floatFromInt(compressed.len)) / @as(f64, @floatFromInt(file_data.len)))) * 100.0);
            std.debug.print("     Level {d:2}: {d:6} bytes ({d:5.1}% smaller) - {d:6.2}ms\n", .{ level, compressed.len, savings, comp_ms });
        } else {
            std.debug.print("     Level {d:2}: {d:6} bytes (larger) - {d:6.2}ms\n", .{ level, compressed.len, comp_ms });
        }
    }

    std.debug.print("\n   LZ4 Compression Levels:\n", .{});
    const lz4_levels = [_]c_int{ 1, 3, 6, 9, 12 };
    for (lz4_levels) |level| {
        const config = archive.CompressionConfig.init(.lz4).withLz4Level(level);
        const start_time = std.time.nanoTimestamp();

        const compressed = archive.compressWithConfig(allocator, file_data, config) catch |err| {
            std.debug.print("     Level {d:2}: ERROR - {}\n", .{ level, err });
            continue;
        };
        defer allocator.free(compressed);

        const compress_time = std.time.nanoTimestamp();
        const comp_ms = @as(f64, @floatFromInt(compress_time - start_time)) / 1_000_000.0;

        if (compressed.len < file_data.len) {
            const savings = ((1.0 - (@as(f64, @floatFromInt(compressed.len)) / @as(f64, @floatFromInt(file_data.len)))) * 100.0);
            std.debug.print("     Level {d:2}: {d:6} bytes ({d:5.1}% smaller) - {d:6.2}ms\n", .{ level, compressed.len, savings, comp_ms });
        } else {
            std.debug.print("     Level {d:2}: {d:6} bytes (larger) - {d:6.2}ms\n", .{ level, compressed.len, comp_ms });
        }
    }

    std.debug.print("\n   Advanced Configuration Options:\n", .{});

    // Multi-threading example
    const mt_config = archive.CompressionConfig.init(.zstd)
        .withZstdLevel(10)
        .withThreads(4)
        .withChecksum();

    const mt_compressed = archive.compressWithConfig(allocator, file_data, mt_config) catch |err| {
        std.debug.print("     Multi-threaded ZSTD: ERROR - {}\n", .{err});
        return;
    };
    defer allocator.free(mt_compressed);

    if (mt_compressed.len < file_data.len) {
        const savings = ((1.0 - (@as(f64, @floatFromInt(mt_compressed.len)) / @as(f64, @floatFromInt(file_data.len)))) * 100.0);
        std.debug.print("     Multi-threaded ZSTD (4 threads + checksum): {d} bytes ({d:.1}% smaller)\n", .{ mt_compressed.len, savings });
    } else {
        std.debug.print("     Multi-threaded ZSTD (4 threads + checksum): {d} bytes (larger)\n", .{mt_compressed.len});
    }

    // Custom buffer size
    const buffer_config = archive.CompressionConfig.init(.gzip)
        .withBufferSize(256 * 1024)
        .withLevel(.best);

    const buffer_compressed = archive.compressWithConfig(allocator, file_data, buffer_config) catch |err| {
        std.debug.print("     Custom buffer GZIP: ERROR - {}\n", .{err});
        return;
    };
    defer allocator.free(buffer_compressed);

    if (buffer_compressed.len < file_data.len) {
        const savings = ((1.0 - (@as(f64, @floatFromInt(buffer_compressed.len)) / @as(f64, @floatFromInt(file_data.len)))) * 100.0);
        std.debug.print("     Custom buffer GZIP (256KB buffer, best level): {d} bytes ({d:.1}% smaller)\n", .{ buffer_compressed.len, savings });
    } else {
        std.debug.print("     Custom buffer GZIP (256KB buffer, best level): {d} bytes (larger)\n", .{buffer_compressed.len});
    }

    std.debug.print("\n   Auto-Detection Test:\n", .{});

    // Test auto-detection with different formats
    const auto_test_algorithms = [_]archive.Algorithm{ .gzip, .zstd, .lz4, .zlib };
    for (auto_test_algorithms) |algo| {
        const compressed = archive.compress(allocator, file_data, algo) catch continue;
        defer allocator.free(compressed);

        const detected = archive.detectAlgorithm(compressed);
        const auto_decompressed = archive.autoDecompress(allocator, compressed) catch continue;
        defer allocator.free(auto_decompressed);

        const verified = std.mem.eql(u8, file_data, auto_decompressed);
        std.debug.print("     {s:8}: detected as {?s} - {s}\n", .{ @tagName(algo), if (detected) |d| @tagName(d) else null, if (verified) "OK" else "FAIL" });
    }

    std.debug.print("\n   File Extension Mapping:\n", .{});
    const ext_algorithms = [_]archive.Algorithm{ .gzip, .zstd, .lz4, .lzma, .xz };
    for (ext_algorithms) |algo| {
        const ext = algo.extension();
        std.debug.print("     {s:8} -> {s}\n", .{ @tagName(algo), ext });
    }

    std.debug.print("\n", .{});
}
