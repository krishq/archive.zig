# Streaming

Archive.zig provides streaming interfaces for memory-efficient compression and decompression of large files and real-time data processing.

## Stream Interface

### Basic Streaming

```zig
const std = @import("std");
const archive = @import("archive");

pub fn streamExample(allocator: std.mem.Allocator) !void {
    // Create a stream compressor
    var compressor = try archive.StreamCompressor.init(allocator, .gzip);
    defer compressor.deinit();
    
    // Process data in chunks
    const chunk1 = "First chunk of data ";
    const chunk2 = "Second chunk of data ";
    const chunk3 = "Final chunk of data";
    
    // Compress chunks
    const compressed1 = try compressor.compress(chunk1);
    const compressed2 = try compressor.compress(chunk2);
    const compressed3 = try compressor.finish(chunk3); // Finish the stream
    
    defer allocator.free(compressed1);
    defer allocator.free(compressed2);
    defer allocator.free(compressed3);
    
    std.debug.print("Compressed chunks: {d}, {d}, {d} bytes\n", .{ compressed1.len, compressed2.len, compressed3.len });
}
```

### Stream Decompression

```zig
pub fn streamDecompressExample(allocator: std.mem.Allocator, compressed_data: []const u8) !void {
    var decompressor = try archive.StreamDecompressor.init(allocator, .gzip);
    defer decompressor.deinit();
    
    // Process compressed data in chunks
    const chunk_size = 1024;
    var offset: usize = 0;
    
    while (offset < compressed_data.len) {
        const end = @min(offset + chunk_size, compressed_data.len);
        const chunk = compressed_data[offset..end];
        
        const decompressed_chunk = if (end == compressed_data.len)
            try decompressor.finish(chunk) // Last chunk
        else
            try decompressor.decompress(chunk);
        
        defer allocator.free(decompressed_chunk);
        
        // Process decompressed chunk
        std.debug.print("Decompressed chunk: {d} bytes\n", .{decompressed_chunk.len});
        
        offset = end;
    }
}
```

## File Streaming

### Stream Compress Large Files

```zig
pub fn streamCompressLargeFile(allocator: std.mem.Allocator, input_path: []const u8, output_path: []const u8) !void {
    const input_file = try std.fs.cwd().openFile(input_path, .{});
    defer input_file.close();
    
    const output_file = try std.fs.cwd().createFile(output_path, .{});
    defer output_file.close();
    
    var compressor = try archive.StreamCompressor.init(allocator, .zstd);
    defer compressor.deinit();
    
    var buffer: [64 * 1024]u8 = undefined; // 64KB buffer
    var total_read: usize = 0;
    var total_written: usize = 0;
    
    while (true) {
        const bytes_read = try input_file.readAll(&buffer);
        if (bytes_read == 0) break;
        
        total_read += bytes_read;
        
        const compressed_chunk = if (bytes_read < buffer.len)
            try compressor.finish(buffer[0..bytes_read]) // Last chunk
        else
            try compressor.compress(buffer[0..bytes_read]);
        
        defer allocator.free(compressed_chunk);
        
        try output_file.writeAll(compressed_chunk);
        total_written += compressed_chunk.len;
        
        if (bytes_read < buffer.len) break; // EOF
    }
    
    const ratio = @as(f64, @floatFromInt(total_written)) / @as(f64, @floatFromInt(total_read)) * 100;
    std.debug.print("Stream compressed {s} -> {s}: {d} -> {d} bytes ({d:.1}%)\n", 
                   .{ input_path, output_path, total_read, total_written, ratio });
}
```

### Stream Decompress Large Files

```zig
pub fn streamDecompressLargeFile(allocator: std.mem.Allocator, input_path: []const u8, output_path: []const u8, algorithm: archive.Algorithm) !void {
    const input_file = try std.fs.cwd().openFile(input_path, .{});
    defer input_file.close();
    
    const output_file = try std.fs.cwd().createFile(output_path, .{});
    defer output_file.close();
    
    var decompressor = try archive.StreamDecompressor.init(allocator, algorithm);
    defer decompressor.deinit();
    
    var buffer: [64 * 1024]u8 = undefined;
    var total_read: usize = 0;
    var total_written: usize = 0;
    
    while (true) {
        const bytes_read = try input_file.readAll(&buffer);
        if (bytes_read == 0) break;
        
        total_read += bytes_read;
        
        const decompressed_chunk = if (bytes_read < buffer.len)
            try decompressor.finish(buffer[0..bytes_read])
        else
            try decompressor.decompress(buffer[0..bytes_read]);
        
        defer allocator.free(decompressed_chunk);
        
        try output_file.writeAll(decompressed_chunk);
        total_written += decompressed_chunk.len;
        
        if (bytes_read < buffer.len) break;
    }
    
    std.debug.print("Stream decompressed {s} -> {s}: {d} -> {d} bytes\n", 
                   .{ input_path, output_path, total_read, total_written });
}
```

## Network Streaming

### HTTP Response Compression

```zig
pub fn compressHttpResponse(allocator: std.mem.Allocator, response_data: []const u8, writer: anytype) !void {
    var compressor = try archive.StreamCompressor.init(allocator, .gzip);
    defer compressor.deinit();
    
    // Compress in chunks for streaming
    const chunk_size = 8192;
    var offset: usize = 0;
    
    while (offset < response_data.len) {
        const end = @min(offset + chunk_size, response_data.len);
        const chunk = response_data[offset..end];
        
        const compressed_chunk = if (end == response_data.len)
            try compressor.finish(chunk)
        else
            try compressor.compress(chunk);
        
        defer allocator.free(compressed_chunk);
        
        // Write compressed chunk to network
        try writer.writeAll(compressed_chunk);
        
        offset = end;
    }
}
```

### Real-Time Data Compression

```zig
pub fn realTimeCompress(allocator: std.mem.Allocator) !void {
    var compressor = try archive.StreamCompressor.init(allocator, .lz4);
    defer compressor.deinit();
    
    // Simulate real-time data stream
    var i: u32 = 0;
    while (i < 100) {
        const data = try std.fmt.allocPrint(allocator, "Real-time data packet {d}\n", .{i});
        defer allocator.free(data);
        
        const compressed = try compressor.compress(data);
        defer allocator.free(compressed);
        
        // Send compressed data immediately
        std.debug.print("Packet {d}: {d} -> {d} bytes\n", .{ i, data.len, compressed.len });
        
        // Simulate delay
        std.time.sleep(10 * std.time.ns_per_ms);
        i += 1;
    }
    
    // Finish the stream
    const final_chunk = try compressor.finish("");
    defer allocator.free(final_chunk);
    
    if (final_chunk.len > 0) {
        std.debug.print("Final chunk: {d} bytes\n", .{final_chunk.len});
    }
}
```

## Advanced Streaming

### Buffered Streaming

```zig
pub const BufferedCompressor = struct {
    compressor: archive.StreamCompressor,
    buffer: std.ArrayList(u8),
    buffer_size: usize,
    allocator: std.mem.Allocator,
    
    pub fn init(allocator: std.mem.Allocator, algorithm: archive.Algorithm, buffer_size: usize) !BufferedCompressor {
        return BufferedCompressor{
            .compressor = try archive.StreamCompressor.init(allocator, algorithm),
            .buffer = std.ArrayList(u8).init(allocator),
            .buffer_size = buffer_size,
            .allocator = allocator,
        };
    }
    
    pub fn deinit(self: *BufferedCompressor) void {
        self.compressor.deinit();
        self.buffer.deinit();
    }
    
    pub fn write(self: *BufferedCompressor, data: []const u8) !?[]u8 {
        try self.buffer.appendSlice(data);
        
        if (self.buffer.items.len >= self.buffer_size) {
            return self.flush();
        }
        
        return null; // No output yet
    }
    
    pub fn flush(self: *BufferedCompressor) ![]u8 {
        if (self.buffer.items.len == 0) return try self.allocator.alloc(u8, 0);
        
        const compressed = try self.compressor.compress(self.buffer.items);
        self.buffer.clearRetainingCapacity();
        return compressed;
    }
    
    pub fn finish(self: *BufferedCompressor) ![]u8 {
        const compressed = try self.compressor.finish(self.buffer.items);
        self.buffer.clearRetainingCapacity();
        return compressed;
    }
};

pub fn bufferedStreamExample(allocator: std.mem.Allocator) !void {
    var buffered = try BufferedCompressor.init(allocator, .gzip, 4096);
    defer buffered.deinit();
    
    // Write data in small chunks
    var i: u32 = 0;
    while (i < 1000) {
        const data = try std.fmt.allocPrint(allocator, "Data chunk {d} ", .{i});
        defer allocator.free(data);
        
        if (try buffered.write(data)) |compressed| {
            defer allocator.free(compressed);
            std.debug.print("Flushed: {d} bytes\n", .{compressed.len});
        }
        
        i += 1;
    }
    
    // Finish the stream
    const final_compressed = try buffered.finish();
    defer allocator.free(final_compressed);
    std.debug.print("Final: {d} bytes\n", .{final_compressed.len});
}
```

### Parallel Streaming

```zig
pub fn parallelStreamCompress(allocator: std.mem.Allocator, input_path: []const u8, output_path: []const u8) !void {
    const input_file = try std.fs.cwd().openFile(input_path, .{});
    defer input_file.close();
    
    const output_file = try std.fs.cwd().createFile(output_path, .{});
    defer output_file.close();
    
    const num_threads = 4;
    const chunk_size = 1024 * 1024; // 1MB chunks
    
    var threads: [num_threads]std.Thread = undefined;
    var chunks: [num_threads][]u8 = undefined;
    var compressed_chunks: [num_threads][]u8 = undefined;
    
    // Read and compress chunks in parallel
    var chunk_index: usize = 0;
    while (chunk_index < num_threads) {
        chunks[chunk_index] = try allocator.alloc(u8, chunk_size);
        const bytes_read = try input_file.readAll(chunks[chunk_index]);
        
        if (bytes_read == 0) break;
        
        chunks[chunk_index] = chunks[chunk_index][0..bytes_read];
        
        threads[chunk_index] = try std.Thread.spawn(.{}, compressChunk, .{ allocator, chunks[chunk_index], &compressed_chunks[chunk_index] });
        
        chunk_index += 1;
    }
    
    // Wait for all threads and write results
    for (threads[0..chunk_index]) |thread| {
        thread.join();
    }
    
    for (compressed_chunks[0..chunk_index]) |compressed| {
        try output_file.writeAll(compressed);
        allocator.free(compressed);
    }
    
    for (chunks[0..chunk_index]) |chunk| {
        allocator.free(chunk);
    }
    
    std.debug.print("Parallel stream compression completed\n", .{});
}

fn compressChunk(allocator: std.mem.Allocator, chunk: []const u8, result: *[]u8) void {
    result.* = archive.compress(allocator, chunk, .zstd) catch unreachable;
}
```

## Stream Configuration

### Configurable Streaming

```zig
pub fn configurableStreamCompress(allocator: std.mem.Allocator, input_path: []const u8, output_path: []const u8) !void {
    const config = archive.CompressionConfig.init(.zstd)
        .withZstdLevel(15)
        .withBufferSize(128 * 1024)
        .withChecksum();
    
    var compressor = try archive.StreamCompressor.initWithConfig(allocator, config);
    defer compressor.deinit();
    
    const input_file = try std.fs.cwd().openFile(input_path, .{});
    defer input_file.close();
    
    const output_file = try std.fs.cwd().createFile(output_path, .{});
    defer output_file.close();
    
    var buffer: [config.buffer_size]u8 = undefined;
    
    while (true) {
        const bytes_read = try input_file.readAll(&buffer);
        if (bytes_read == 0) break;
        
        const compressed = if (bytes_read < buffer.len)
            try compressor.finish(buffer[0..bytes_read])
        else
            try compressor.compress(buffer[0..bytes_read]);
        
        defer allocator.free(compressed);
        try output_file.writeAll(compressed);
        
        if (bytes_read < buffer.len) break;
    }
}
```

## Memory Management

### Memory-Efficient Streaming

```zig
pub fn memoryEfficientStream(allocator: std.mem.Allocator, input_path: []const u8, output_path: []const u8) !void {
    // Use arena allocator for temporary allocations
    var arena = std.heap.ArenaAllocator.init(allocator);
    defer arena.deinit();
    const arena_allocator = arena.allocator();
    
    const input_file = try std.fs.cwd().openFile(input_path, .{});
    defer input_file.close();
    
    const output_file = try std.fs.cwd().createFile(output_path, .{});
    defer output_file.close();
    
    var compressor = try archive.StreamCompressor.init(arena_allocator, .lz4);
    defer compressor.deinit();
    
    const buffer_size = 32 * 1024; // Small buffer for memory efficiency
    var buffer: [buffer_size]u8 = undefined;
    
    while (true) {
        const bytes_read = try input_file.readAll(&buffer);
        if (bytes_read == 0) break;
        
        const compressed = if (bytes_read < buffer.len)
            try compressor.finish(buffer[0..bytes_read])
        else
            try compressor.compress(buffer[0..bytes_read]);
        
        try output_file.writeAll(compressed);
        
        // Free compressed data immediately (arena will clean up)
        // No need for explicit free with arena allocator
        
        if (bytes_read < buffer.len) break;
    }
    
    std.debug.print("Memory-efficient streaming completed\n", .{});
}
```

## Error Handling

### Robust Stream Processing

```zig
pub fn robustStreamCompress(allocator: std.mem.Allocator, input_path: []const u8, output_path: []const u8) !void {
    const input_file = std.fs.cwd().openFile(input_path, .{}) catch |err| switch (err) {
        error.FileNotFound => {
            std.debug.print("Error: Input file not found\n", .{});
            return err;
        },
        else => return err,
    };
    defer input_file.close();
    
    const output_file = std.fs.cwd().createFile(output_path, .{}) catch |err| switch (err) {
        error.AccessDenied => {
            std.debug.print("Error: Cannot create output file\n", .{});
            return err;
        },
        else => return err,
    };
    defer output_file.close();
    
    var compressor = archive.StreamCompressor.init(allocator, .gzip) catch |err| switch (err) {
        error.OutOfMemory => {
            std.debug.print("Error: Not enough memory for compressor\n", .{});
            return err;
        },
        else => return err,
    };
    defer compressor.deinit();
    
    var buffer: [64 * 1024]u8 = undefined;
    var total_processed: usize = 0;
    
    while (true) {
        const bytes_read = input_file.readAll(&buffer) catch |err| {
            std.debug.print("Error reading input file at offset {d}: {}\n", .{ total_processed, err });
            return err;
        };
        
        if (bytes_read == 0) break;
        
        const compressed = (if (bytes_read < buffer.len)
            compressor.finish(buffer[0..bytes_read])
        else
            compressor.compress(buffer[0..bytes_read])) catch |err| {
            std.debug.print("Error compressing data at offset {d}: {}\n", .{ total_processed, err });
            return err;
        };
        defer allocator.free(compressed);
        
        output_file.writeAll(compressed) catch |err| {
            std.debug.print("Error writing compressed data: {}\n", .{err});
            return err;
        };
        
        total_processed += bytes_read;
        
        if (bytes_read < buffer.len) break;
    }
    
    std.debug.print("Successfully processed {d} bytes\n", .{total_processed});
}
```

## Performance Tips

### Optimizing Stream Performance

```zig
pub fn optimizedStreamCompress(allocator: std.mem.Allocator, input_path: []const u8, output_path: []const u8) !void {
    // Use larger buffers for better performance
    const buffer_size = 1024 * 1024; // 1MB buffer
    
    // Use fast algorithm for streaming
    const config = archive.CompressionConfig.init(.lz4)
        .withLevel(.fastest)
        .withBufferSize(buffer_size);
    
    var compressor = try archive.StreamCompressor.initWithConfig(allocator, config);
    defer compressor.deinit();
    
    const input_file = try std.fs.cwd().openFile(input_path, .{});
    defer input_file.close();
    
    const output_file = try std.fs.cwd().createFile(output_path, .{});
    defer output_file.close();
    
    // Pre-allocate buffer
    const buffer = try allocator.alloc(u8, buffer_size);
    defer allocator.free(buffer);
    
    const start_time = std.time.nanoTimestamp();
    var total_bytes: usize = 0;
    
    while (true) {
        const bytes_read = try input_file.readAll(buffer);
        if (bytes_read == 0) break;
        
        total_bytes += bytes_read;
        
        const compressed = if (bytes_read < buffer.len)
            try compressor.finish(buffer[0..bytes_read])
        else
            try compressor.compress(buffer[0..bytes_read]);
        
        defer allocator.free(compressed);
        try output_file.writeAll(compressed);
        
        if (bytes_read < buffer.len) break;
    }
    
    const end_time = std.time.nanoTimestamp();
    const duration_ms = @as(f64, @floatFromInt(end_time - start_time)) / 1_000_000.0;
    const throughput_mb = @as(f64, @floatFromInt(total_bytes)) / (1024.0 * 1024.0) / (duration_ms / 1000.0);
    
    std.debug.print("Processed {d} bytes in {d:.2}ms ({d:.2} MB/s)\n", .{ total_bytes, duration_ms, throughput_mb });
}
```

## Next Steps

- Learn about [Error Handling](./errors.md) for robust streaming
- Explore [Memory Management](./memory.md) for optimization
- Check out [Threading](./threading.md) for parallel processing
- See [Examples](../examples/streaming.md) for practical usage