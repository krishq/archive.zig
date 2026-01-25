# Compressor API

The Compressor API provides advanced compression control with streaming capabilities and configuration management.

## Archive Struct

```zig
pub const Archive = struct {
    allocator: std.mem.Allocator,
    config: CompressionConfig,
    
    pub fn init(allocator: std.mem.Allocator, config: CompressionConfig) Archive
    pub fn deinit(self: *Archive) void
    pub fn compress(self: *Archive, data: []const u8) ![]u8
    pub fn decompress(self: *Archive, data: []const u8) ![]u8
    pub fn compressFile(self: *Archive, input_path: []const u8, output_path: []const u8) !void
    pub fn decompressFile(self: *Archive, input_path: []const u8, output_path: []const u8) !void
    pub fn setConfig(self: *Archive, config: CompressionConfig) void
    pub fn getConfig(self: *Archive) CompressionConfig
};
```

## StreamCompressor

```zig
pub const StreamCompressor = struct {
    allocator: std.mem.Allocator,
    algorithm: Algorithm,
    config: CompressionConfig,
    state: CompressionState,
    
    pub fn init(allocator: std.mem.Allocator, algorithm: Algorithm) !StreamCompressor
    pub fn initWithConfig(allocator: std.mem.Allocator, config: CompressionConfig) !StreamCompressor
    pub fn deinit(self: *StreamCompressor) void
    pub fn compress(self: *StreamCompressor, data: []const u8) ![]u8
    pub fn finish(self: *StreamCompressor, final_data: []const u8) ![]u8
    pub fn reset(self: *StreamCompressor) !void
    pub fn getStats(self: *StreamCompressor) CompressionStats
};
```

## StreamDecompressor

```zig
pub const StreamDecompressor = struct {
    allocator: std.mem.Allocator,
    algorithm: Algorithm,
    state: DecompressionState,
    
    pub fn init(allocator: std.mem.Allocator, algorithm: Algorithm) !StreamDecompressor
    pub fn deinit(self: *StreamDecompressor) void
    pub fn decompress(self: *StreamDecompressor, data: []const u8) ![]u8
    pub fn finish(self: *StreamDecompressor, final_data: []const u8) ![]u8
    pub fn reset(self: *StreamDecompressor) !void
    pub fn getStats(self: *StreamDecompressor) DecompressionStats
};
```

## Archive Usage

### Basic Archive Operations

```zig
const std = @import("std");
const archive = @import("archive");

pub fn archiveExample(allocator: std.mem.Allocator) !void {
    // Create archive with configuration
    const config = archive.CompressionConfig.init(.zstd)
        .withZstdLevel(10)
        .withChecksum();
    
    var arch = archive.Archive.init(allocator, config);
    defer arch.deinit();
    
    // Compress data
    const input = "Data to compress with archive";
    const compressed = try arch.compress(input);
    defer allocator.free(compressed);
    
    // Decompress data
    const decompressed = try arch.decompress(compressed);
    defer allocator.free(decompressed);
    
    std.debug.print("Archive operation completed\n", .{});
}
```

### File Operations

```zig
pub fn archiveFileExample(allocator: std.mem.Allocator) !void {
    const config = archive.CompressionConfig.init(.gzip)
        .withLevel(.best)
        .withChecksum();
    
    var arch = archive.Archive.init(allocator, config);
    defer arch.deinit();
    
    // Compress file
    try arch.compressFile("input.txt", "output.gz");
    
    // Decompress file
    try arch.decompressFile("output.gz", "restored.txt");
    
    std.debug.print("File operations completed\n", .{});
}
```

### Dynamic Configuration

```zig
pub fn dynamicConfigExample(allocator: std.mem.Allocator) !void {
    var arch = archive.Archive.init(allocator, archive.CompressionConfig.init(.lz4));
    defer arch.deinit();
    
    const test_data = "Test data for dynamic configuration";
    
    // Compress with initial config (LZ4)
    const lz4_compressed = try arch.compress(test_data);
    defer allocator.free(lz4_compressed);
    
    // Change configuration to ZSTD
    const zstd_config = archive.CompressionConfig.init(.zstd)
        .withZstdLevel(15);
    arch.setConfig(zstd_config);
    
    // Compress with new config
    const zstd_compressed = try arch.compress(test_data);
    defer allocator.free(zstd_compressed);
    
    std.debug.print("LZ4: {d} bytes, ZSTD: {d} bytes\n", .{ lz4_compressed.len, zstd_compressed.len });
}
```

## Stream Compression

### Basic Streaming

```zig
pub fn streamCompressionExample(allocator: std.mem.Allocator) !void {
    var compressor = try archive.StreamCompressor.init(allocator, .gzip);
    defer compressor.deinit();
    
    // Compress data in chunks
    const chunk1 = "First chunk of streaming data ";
    const chunk2 = "Second chunk of streaming data ";
    const chunk3 = "Final chunk of streaming data";
    
    const compressed1 = try compressor.compress(chunk1);
    defer allocator.free(compressed1);
    
    const compressed2 = try compressor.compress(chunk2);
    defer allocator.free(compressed2);
    
    const compressed3 = try compressor.finish(chunk3);
    defer allocator.free(compressed3);
    
    std.debug.print("Stream compression: {d}, {d}, {d} bytes\n", 
                   .{ compressed1.len, compressed2.len, compressed3.len });
}
```

### Configured Streaming

```zig
pub fn configuredStreamExample(allocator: std.mem.Allocator) !void {
    const config = archive.CompressionConfig.init(.zstd)
        .withZstdLevel(15)
        .withBufferSize(128 * 1024)
        .withChecksum();
    
    var compressor = try archive.StreamCompressor.initWithConfig(allocator, config);
    defer compressor.deinit();
    
    // Process large data in chunks
    const chunk_size = 64 * 1024;
    const large_data = try allocator.alloc(u8, 1024 * 1024); // 1MB
    defer allocator.free(large_data);
    
    // Fill with test data
    for (large_data, 0..) |*byte, i| {
        byte.* = @intCast(i % 256);
    }
    
    var offset: usize = 0;
    var total_compressed: usize = 0;
    
    while (offset < large_data.len) {
        const end = @min(offset + chunk_size, large_data.len);
        const chunk = large_data[offset..end];
        
        const compressed = if (end == large_data.len)
            try compressor.finish(chunk)
        else
            try compressor.compress(chunk);
        
        defer allocator.free(compressed);
        total_compressed += compressed.len;
        
        offset = end;
    }
    
    const stats = compressor.getStats();
    std.debug.print("Configured streaming: {d} -> {d} bytes\n", .{ stats.input_bytes, total_compressed });
}
```

## Stream Decompression

### Basic Stream Decompression

```zig
pub fn streamDecompressionExample(allocator: std.mem.Allocator, compressed_data: []const u8) !void {
    var decompressor = try archive.StreamDecompressor.init(allocator, .gzip);
    defer decompressor.deinit();
    
    // Process compressed data in chunks
    const chunk_size = 1024;
    var offset: usize = 0;
    var total_decompressed: usize = 0;
    
    while (offset < compressed_data.len) {
        const end = @min(offset + chunk_size, compressed_data.len);
        const chunk = compressed_data[offset..end];
        
        const decompressed = if (end == compressed_data.len)
            try decompressor.finish(chunk)
        else
            try decompressor.decompress(chunk);
        
        defer allocator.free(decompressed);
        total_decompressed += decompressed.len;
        
        offset = end;
    }
    
    const stats = decompressor.getStats();
    std.debug.print("Stream decompression: {d} -> {d} bytes\n", .{ stats.input_bytes, total_decompressed });
}
```

## Statistics and Monitoring

### CompressionStats

```zig
pub const CompressionStats = struct {
    input_bytes: usize,
    output_bytes: usize,
    compression_ratio: f64,
    processing_time_ns: u64,
    chunks_processed: usize,
};
```

### DecompressionStats

```zig
pub const DecompressionStats = struct {
    input_bytes: usize,
    output_bytes: usize,
    decompression_ratio: f64,
    processing_time_ns: u64,
    chunks_processed: usize,
};
```

### Statistics Usage

```zig
pub fn statisticsExample(allocator: std.mem.Allocator) !void {
    var compressor = try archive.StreamCompressor.init(allocator, .zstd);
    defer compressor.deinit();
    
    const test_data = "Statistics test data " ** 100;
    
    const start_time = std.time.nanoTimestamp();
    const compressed = try compressor.finish(test_data);
    defer allocator.free(compressed);
    const end_time = std.time.nanoTimestamp();
    
    const stats = compressor.getStats();
    
    std.debug.print("Compression Statistics:\n", .{});
    std.debug.print("  Input: {d} bytes\n", .{stats.input_bytes});
    std.debug.print("  Output: {d} bytes\n", .{stats.output_bytes});
    std.debug.print("  Ratio: {d:.2}%\n", .{stats.compression_ratio * 100});
    std.debug.print("  Time: {d:.2}ms\n", .{@as(f64, @floatFromInt(end_time - start_time)) / 1_000_000});
    std.debug.print("  Chunks: {d}\n", .{stats.chunks_processed});
}
```

## Advanced Features

### Stream Reset

```zig
pub fn streamResetExample(allocator: std.mem.Allocator) !void {
    var compressor = try archive.StreamCompressor.init(allocator, .lz4);
    defer compressor.deinit();
    
    // First compression session
    const data1 = "First session data";
    const compressed1 = try compressor.finish(data1);
    defer allocator.free(compressed1);
    
    // Reset for new session
    try compressor.reset();
    
    // Second compression session
    const data2 = "Second session data";
    const compressed2 = try compressor.finish(data2);
    defer allocator.free(compressed2);
    
    std.debug.print("Session 1: {d} bytes, Session 2: {d} bytes\n", 
                   .{ compressed1.len, compressed2.len });
}
```

### Multi-Algorithm Compressor

```zig
pub const MultiAlgorithmCompressor = struct {
    allocator: std.mem.Allocator,
    compressors: std.HashMap(archive.Algorithm, archive.StreamCompressor, std.hash_map.AutoContext(archive.Algorithm), std.hash_map.default_max_load_percentage),
    
    pub fn init(allocator: std.mem.Allocator) MultiAlgorithmCompressor {
        return MultiAlgorithmCompressor{
            .allocator = allocator,
            .compressors = std.HashMap(archive.Algorithm, archive.StreamCompressor, std.hash_map.AutoContext(archive.Algorithm), std.hash_map.default_max_load_percentage).init(allocator),
        };
    }
    
    pub fn deinit(self: *MultiAlgorithmCompressor) void {
        var iterator = self.compressors.iterator();
        while (iterator.next()) |entry| {
            entry.value_ptr.deinit();
        }
        self.compressors.deinit();
    }
    
    pub fn compress(self: *MultiAlgorithmCompressor, data: []const u8, algorithm: archive.Algorithm) ![]u8 {
        if (self.compressors.getPtr(algorithm)) |compressor| {
            return compressor.compress(data);
        } else {
            var new_compressor = try archive.StreamCompressor.init(self.allocator, algorithm);
            try self.compressors.put(algorithm, new_compressor);
            return new_compressor.compress(data);
        }
    }
};

pub fn multiAlgorithmExample(allocator: std.mem.Allocator) !void {
    var multi_compressor = MultiAlgorithmCompressor.init(allocator);
    defer multi_compressor.deinit();
    
    const test_data = "Multi-algorithm compression test";
    
    // Compress with different algorithms
    const lz4_compressed = try multi_compressor.compress(test_data, .lz4);
    defer allocator.free(lz4_compressed);
    
    const gzip_compressed = try multi_compressor.compress(test_data, .gzip);
    defer allocator.free(gzip_compressed);
    
    const zstd_compressed = try multi_compressor.compress(test_data, .zstd);
    defer allocator.free(zstd_compressed);
    
    std.debug.print("LZ4: {d}, Gzip: {d}, ZSTD: {d} bytes\n", 
                   .{ lz4_compressed.len, gzip_compressed.len, zstd_compressed.len });
}
```

## Error Handling

### Compressor Error Handling

```zig
pub fn compressorErrorHandling(allocator: std.mem.Allocator) !void {
    var compressor = archive.StreamCompressor.init(allocator, .zstd) catch |err| switch (err) {
        error.OutOfMemory => {
            std.debug.print("Not enough memory to create compressor\n", .{});
            return err;
        },
        error.UnsupportedAlgorithm => {
            std.debug.print("ZSTD not supported on this platform\n", .{});
            return err;
        },
        else => return err,
    };
    defer compressor.deinit();
    
    const test_data = "Error handling test data";
    
    const compressed = compressor.compress(test_data) catch |err| switch (err) {
        error.InvalidData => {
            std.debug.print("Input data is invalid\n", .{});
            return err;
        },
        error.CompressionFailed => {
            std.debug.print("Compression operation failed\n", .{});
            return err;
        },
        else => return err,
    };
    defer allocator.free(compressed);
    
    std.debug.print("Compression successful: {d} bytes\n", .{compressed.len});
}
```

## Performance Optimization

### Optimized Compressor Configuration

```zig
pub fn optimizedCompressorExample(allocator: std.mem.Allocator) !void {
    // High-performance configuration
    const config = archive.CompressionConfig.init(.lz4)
        .withLevel(.fastest)
        .withBufferSize(256 * 1024)  // Large buffer for throughput
        .withMemoryLevel(1);         // Low memory usage
    
    var compressor = try archive.StreamCompressor.initWithConfig(allocator, config);
    defer compressor.deinit();
    
    // Benchmark compression
    const test_data = try allocator.alloc(u8, 10 * 1024 * 1024); // 10MB
    defer allocator.free(test_data);
    
    // Fill with test pattern
    for (test_data, 0..) |*byte, i| {
        byte.* = @intCast(i % 256);
    }
    
    const start_time = std.time.nanoTimestamp();
    const compressed = try compressor.finish(test_data);
    defer allocator.free(compressed);
    const end_time = std.time.nanoTimestamp();
    
    const duration_ms = @as(f64, @floatFromInt(end_time - start_time)) / 1_000_000.0;
    const throughput_mb = @as(f64, @floatFromInt(test_data.len)) / (1024.0 * 1024.0) / (duration_ms / 1000.0);
    
    std.debug.print("Optimized compression: {d:.2} MB/s\n", .{throughput_mb});
}
```

## Best Practices

### Compressor Guidelines

1. **Reuse compressors** - Create once, use multiple times
2. **Configure appropriately** - Match settings to use case
3. **Monitor statistics** - Track performance and ratios
4. **Handle errors gracefully** - Provide fallback strategies
5. **Reset when needed** - Clear state between sessions
6. **Choose right streaming** - Use streaming for large data
7. **Optimize buffers** - Larger buffers = better compression

### Common Patterns

```zig
// Long-lived compressor for repeated operations
var compressor = try archive.StreamCompressor.init(allocator, .zstd);
defer compressor.deinit();

// Process multiple files
for (file_list) |file_path| {
    const file_data = try readFile(allocator, file_path);
    defer allocator.free(file_data);
    
    const compressed = try compressor.compress(file_data);
    defer allocator.free(compressed);
    
    try writeFile(compressed_path, compressed);
    
    // Reset for next file
    try compressor.reset();
}
```

## Next Steps

- Learn about [Stream](./stream.md) for streaming interfaces
- Explore [Utils](./utils.md) for compression utilities
- Check [Constants](./constants.md) for compressor constants
- See [Examples](../examples/streaming.md) for practical streaming usage