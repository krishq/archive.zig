# Stream API

The Stream API provides memory-efficient interfaces for processing large amounts of data without loading everything into memory at once.

## Stream Interfaces

### Reader Interface

```zig
pub const Reader = struct {
    ptr: *anyopaque,
    vtable: *const VTable,
    
    pub const VTable = struct {
        read: *const fn (ptr: *anyopaque, buffer: []u8) anyerror!usize,
    };
    
    pub fn read(self: Reader, buffer: []u8) !usize {
        return self.vtable.read(self.ptr, buffer);
    }
};
```

### Writer Interface

```zig
pub const Writer = struct {
    ptr: *anyopaque,
    vtable: *const VTable,
    
    pub const VTable = struct {
        write: *const fn (ptr: *anyopaque, data: []const u8) anyerror!usize,
    };
    
    pub fn write(self: Writer, data: []const u8) !usize {
        return self.vtable.write(self.ptr, data);
    }
    
    pub fn writeAll(self: Writer, data: []const u8) !void {
        var written: usize = 0;
        while (written < data.len) {
            written += try self.write(data[written..]);
        }
    }
};
```

## Compression Streams

### CompressStream

```zig
pub const CompressStream = struct {
    allocator: std.mem.Allocator,
    compressor: StreamCompressor,
    reader: Reader,
    buffer: []u8,
    finished: bool,
    
    pub fn init(allocator: std.mem.Allocator, reader: Reader, algorithm: Algorithm, buffer_size: usize) !CompressStream
    pub fn initWithConfig(allocator: std.mem.Allocator, reader: Reader, config: CompressionConfig) !CompressStream
    pub fn deinit(self: *CompressStream) void
    pub fn read(self: *CompressStream, buffer: []u8) !usize
    pub fn reader(self: *CompressStream) Reader
};
```

### DecompressStream

```zig
pub const DecompressStream = struct {
    allocator: std.mem.Allocator,
    decompressor: StreamDecompressor,
    reader: Reader,
    buffer: []u8,
    finished: bool,
    
    pub fn init(allocator: std.mem.Allocator, reader: Reader, algorithm: Algorithm, buffer_size: usize) !DecompressStream
    pub fn deinit(self: *DecompressStream) void
    pub fn read(self: *DecompressStream, buffer: []u8) !usize
    pub fn reader(self: *DecompressStream) Reader
};
```

## Stream Usage Examples

### File Compression Stream

```zig
const std = @import("std");
const archive = @import("archive");

pub fn fileCompressionStream(allocator: std.mem.Allocator, input_path: []const u8, output_path: []const u8) !void {
    // Open input file
    const input_file = try std.fs.cwd().openFile(input_path, .{});
    defer input_file.close();
    
    // Create file reader
    const file_reader = input_file.reader();
    
    // Create compression stream
    var compress_stream = try archive.CompressStream.init(
        allocator,
        file_reader.any(),
        .gzip,
        64 * 1024 // 64KB buffer
    );
    defer compress_stream.deinit();
    
    // Open output file
    const output_file = try std.fs.cwd().createFile(output_path, .{});
    defer output_file.close();
    
    // Stream compressed data to output file
    var buffer: [8192]u8 = undefined;
    const stream_reader = compress_stream.reader();
    
    while (true) {
        const bytes_read = try stream_reader.read(&buffer);
        if (bytes_read == 0) break;
        
        try output_file.writeAll(buffer[0..bytes_read]);
    }
    
    std.debug.print("File compression stream completed\n", .{});
}
```

### File Decompression Stream

```zig
pub fn fileDecompressionStream(allocator: std.mem.Allocator, input_path: []const u8, output_path: []const u8) !void {
    // Open compressed file
    const input_file = try std.fs.cwd().openFile(input_path, .{});
    defer input_file.close();
    
    // Create file reader
    const file_reader = input_file.reader();
    
    // Auto-detect algorithm from file header
    var header_buffer: [16]u8 = undefined;
    _ = try input_file.readAll(&header_buffer);
    try input_file.seekTo(0); // Reset to beginning
    
    const algorithm = archive.detectAlgorithm(&header_buffer) orelse {
        return error.UnknownFormat;
    };
    
    // Create decompression stream
    var decompress_stream = try archive.DecompressStream.init(
        allocator,
        file_reader.any(),
        algorithm,
        64 * 1024
    );
    defer decompress_stream.deinit();
    
    // Open output file
    const output_file = try std.fs.cwd().createFile(output_path, .{});
    defer output_file.close();
    
    // Stream decompressed data to output file
    var buffer: [8192]u8 = undefined;
    const stream_reader = decompress_stream.reader();
    
    while (true) {
        const bytes_read = try stream_reader.read(&buffer);
        if (bytes_read == 0) break;
        
        try output_file.writeAll(buffer[0..bytes_read]);
    }
    
    std.debug.print("File decompression stream completed\n", .{});
}
```

## Memory Streams

### MemoryReader

```zig
pub const MemoryReader = struct {
    data: []const u8,
    pos: usize,
    
    pub fn init(data: []const u8) MemoryReader {
        return MemoryReader{
            .data = data,
            .pos = 0,
        };
    }
    
    pub fn read(self: *MemoryReader, buffer: []u8) !usize {
        const remaining = self.data.len - self.pos;
        const to_read = @min(buffer.len, remaining);
        
        if (to_read == 0) return 0;
        
        @memcpy(buffer[0..to_read], self.data[self.pos..self.pos + to_read]);
        self.pos += to_read;
        
        return to_read;
    }
    
    pub fn reader(self: *MemoryReader) Reader {
        return Reader{
            .ptr = self,
            .vtable = &.{
                .read = readImpl,
            },
        };
    }
    
    fn readImpl(ptr: *anyopaque, buffer: []u8) anyerror!usize {
        const self: *MemoryReader = @ptrCast(@alignCast(ptr));
        return self.read(buffer);
    }
};
```

### MemoryWriter

```zig
pub const MemoryWriter = struct {
    buffer: std.ArrayList(u8),
    
    pub fn init(allocator: std.mem.Allocator) MemoryWriter {
        return MemoryWriter{
            .buffer = std.ArrayList(u8).init(allocator),
        };
    }
    
    pub fn deinit(self: *MemoryWriter) void {
        self.buffer.deinit();
    }
    
    pub fn write(self: *MemoryWriter, data: []const u8) !usize {
        try self.buffer.appendSlice(data);
        return data.len;
    }
    
    pub fn getWritten(self: *MemoryWriter) []const u8 {
        return self.buffer.items;
    }
    
    pub fn writer(self: *MemoryWriter) Writer {
        return Writer{
            .ptr = self,
            .vtable = &.{
                .write = writeImpl,
            },
        };
    }
    
    fn writeImpl(ptr: *anyopaque, data: []const u8) anyerror!usize {
        const self: *MemoryWriter = @ptrCast(@alignCast(ptr));
        return self.write(data);
    }
};
```

### Memory Stream Example

```zig
pub fn memoryStreamExample(allocator: std.mem.Allocator) !void {
    const input_data = "Memory stream compression test data " ** 100;
    
    // Create memory reader
    var memory_reader = MemoryReader.init(input_data);
    
    // Create compression stream
    var compress_stream = try archive.CompressStream.init(
        allocator,
        memory_reader.reader(),
        .lz4,
        32 * 1024
    );
    defer compress_stream.deinit();
    
    // Create memory writer for output
    var memory_writer = MemoryWriter.init(allocator);
    defer memory_writer.deinit();
    
    // Stream compressed data
    var buffer: [4096]u8 = undefined;
    const stream_reader = compress_stream.reader();
    const writer = memory_writer.writer();
    
    while (true) {
        const bytes_read = try stream_reader.read(&buffer);
        if (bytes_read == 0) break;
        
        _ = try writer.write(buffer[0..bytes_read]);
    }
    
    const compressed_data = memory_writer.getWritten();
    const ratio = @as(f64, @floatFromInt(compressed_data.len)) / @as(f64, @floatFromInt(input_data.len)) * 100;
    
    std.debug.print("Memory stream: {d} -> {d} bytes ({d:.1}%)\n", 
                   .{ input_data.len, compressed_data.len, ratio });
}
```

## Network Streams

### HTTP Compression Stream

```zig
pub fn httpCompressionExample(allocator: std.mem.Allocator, response_data: []const u8, writer: anytype) !void {
    // Create memory reader for response data
    var memory_reader = MemoryReader.init(response_data);
    
    // Create gzip compression stream for HTTP
    const config = archive.CompressionConfig.init(.gzip)
        .withLevel(.fast)
        .withBufferSize(16 * 1024); // Smaller buffer for low latency
    
    var compress_stream = try archive.CompressStream.initWithConfig(
        allocator,
        memory_reader.reader(),
        config
    );
    defer compress_stream.deinit();
    
    // Stream compressed data to network writer
    var buffer: [2048]u8 = undefined;
    const stream_reader = compress_stream.reader();
    
    while (true) {
        const bytes_read = try stream_reader.read(&buffer);
        if (bytes_read == 0) break;
        
        try writer.writeAll(buffer[0..bytes_read]);
    }
}
```

### Real-Time Data Stream

```zig
pub const RealTimeCompressor = struct {
    allocator: std.mem.Allocator,
    compressor: archive.StreamCompressor,
    output_writer: Writer,
    buffer: []u8,
    
    pub fn init(allocator: std.mem.Allocator, output_writer: Writer, algorithm: archive.Algorithm) !RealTimeCompressor {
        const buffer = try allocator.alloc(u8, 8192);
        
        return RealTimeCompressor{
            .allocator = allocator,
            .compressor = try archive.StreamCompressor.init(allocator, algorithm),
            .output_writer = output_writer,
            .buffer = buffer,
        };
    }
    
    pub fn deinit(self: *RealTimeCompressor) void {
        self.compressor.deinit();
        self.allocator.free(self.buffer);
    }
    
    pub fn processData(self: *RealTimeCompressor, data: []const u8) !void {
        const compressed = try self.compressor.compress(data);
        defer self.allocator.free(compressed);
        
        _ = try self.output_writer.write(compressed);
    }
    
    pub fn finish(self: *RealTimeCompressor) !void {
        const final_data = try self.compressor.finish("");
        defer self.allocator.free(final_data);
        
        if (final_data.len > 0) {
            _ = try self.output_writer.write(final_data);
        }
    }
};

pub fn realTimeStreamExample(allocator: std.mem.Allocator) !void {
    // Create memory writer for output
    var memory_writer = MemoryWriter.init(allocator);
    defer memory_writer.deinit();
    
    // Create real-time compressor
    var rt_compressor = try RealTimeCompressor.init(
        allocator,
        memory_writer.writer(),
        .lz4
    );
    defer rt_compressor.deinit();
    
    // Simulate real-time data processing
    for (0..100) |i| {
        const data = try std.fmt.allocPrint(allocator, "Real-time packet {d}\n", .{i});
        defer allocator.free(data);
        
        try rt_compressor.processData(data);
        
        // Simulate real-time interval
        std.time.sleep(1 * std.time.ns_per_ms);
    }
    
    // Finish compression
    try rt_compressor.finish();
    
    const compressed_output = memory_writer.getWritten();
    std.debug.print("Real-time compression: {d} bytes\n", .{compressed_output.len});
}
```

## Buffered Streams

### BufferedCompressStream

```zig
pub const BufferedCompressStream = struct {
    allocator: std.mem.Allocator,
    compress_stream: CompressStream,
    input_buffer: std.fifo.LinearFifo(u8, .Dynamic),
    output_buffer: std.fifo.LinearFifo(u8, .Dynamic),
    buffer_size: usize,
    
    pub fn init(allocator: std.mem.Allocator, reader: Reader, algorithm: archive.Algorithm, buffer_size: usize) !BufferedCompressStream {
        return BufferedCompressStream{
            .allocator = allocator,
            .compress_stream = try archive.CompressStream.init(allocator, reader, algorithm, buffer_size),
            .input_buffer = std.fifo.LinearFifo(u8, .Dynamic).init(allocator),
            .output_buffer = std.fifo.LinearFifo(u8, .Dynamic).init(allocator),
            .buffer_size = buffer_size,
        };
    }
    
    pub fn deinit(self: *BufferedCompressStream) void {
        self.compress_stream.deinit();
        self.input_buffer.deinit();
        self.output_buffer.deinit();
    }
    
    pub fn read(self: *BufferedCompressStream, buffer: []u8) !usize {
        // Fill output buffer if needed
        if (self.output_buffer.readableLength() < buffer.len) {
            try self.fillOutputBuffer();
        }
        
        // Read from output buffer
        const to_read = @min(buffer.len, self.output_buffer.readableLength());
        self.output_buffer.readFirst(buffer[0..to_read]);
        
        return to_read;
    }
    
    fn fillOutputBuffer(self: *BufferedCompressStream) !void {
        var temp_buffer: [4096]u8 = undefined;
        const bytes_read = try self.compress_stream.read(&temp_buffer);
        
        if (bytes_read > 0) {
            try self.output_buffer.writeSlice(temp_buffer[0..bytes_read]);
        }
    }
    
    pub fn reader(self: *BufferedCompressStream) Reader {
        return Reader{
            .ptr = self,
            .vtable = &.{
                .read = readImpl,
            },
        };
    }
    
    fn readImpl(ptr: *anyopaque, buffer: []u8) anyerror!usize {
        const self: *BufferedCompressStream = @ptrCast(@alignCast(ptr));
        return self.read(buffer);
    }
};
```

## Stream Utilities

### Stream Copy

```zig
pub fn streamCopy(reader: Reader, writer: Writer, buffer_size: usize) !usize {
    const buffer = try std.heap.page_allocator.alloc(u8, buffer_size);
    defer std.heap.page_allocator.free(buffer);
    
    var total_copied: usize = 0;
    
    while (true) {
        const bytes_read = try reader.read(buffer);
        if (bytes_read == 0) break;
        
        _ = try writer.write(buffer[0..bytes_read]);
        total_copied += bytes_read;
    }
    
    return total_copied;
}
```

### Stream Tee

```zig
pub const TeeWriter = struct {
    writer1: Writer,
    writer2: Writer,
    
    pub fn init(writer1: Writer, writer2: Writer) TeeWriter {
        return TeeWriter{
            .writer1 = writer1,
            .writer2 = writer2,
        };
    }
    
    pub fn write(self: *TeeWriter, data: []const u8) !usize {
        _ = try self.writer1.write(data);
        _ = try self.writer2.write(data);
        return data.len;
    }
    
    pub fn writer(self: *TeeWriter) Writer {
        return Writer{
            .ptr = self,
            .vtable = &.{
                .write = writeImpl,
            },
        };
    }
    
    fn writeImpl(ptr: *anyopaque, data: []const u8) anyerror!usize {
        const self: *TeeWriter = @ptrCast(@alignCast(ptr));
        return self.write(data);
    }
};
```

## Error Handling

### Stream Error Recovery

```zig
pub fn streamErrorHandling(allocator: std.mem.Allocator, input_path: []const u8, output_path: []const u8) !void {
    const input_file = std.fs.cwd().openFile(input_path, .{}) catch |err| switch (err) {
        error.FileNotFound => {
            std.debug.print("Input file not found: {s}\n", .{input_path});
            return err;
        },
        error.AccessDenied => {
            std.debug.print("Cannot access input file: {s}\n", .{input_path});
            return err;
        },
        else => return err,
    };
    defer input_file.close();
    
    const file_reader = input_file.reader();
    
    var compress_stream = archive.CompressStream.init(
        allocator,
        file_reader.any(),
        .gzip,
        64 * 1024
    ) catch |err| switch (err) {
        error.OutOfMemory => {
            std.debug.print("Not enough memory for compression stream\n", .{});
            return err;
        },
        error.UnsupportedAlgorithm => {
            std.debug.print("Gzip not supported\n", .{});
            return err;
        },
        else => return err,
    };
    defer compress_stream.deinit();
    
    const output_file = std.fs.cwd().createFile(output_path, .{}) catch |err| switch (err) {
        error.AccessDenied => {
            std.debug.print("Cannot create output file: {s}\n", .{output_path});
            return err;
        },
        error.NoSpaceLeft => {
            std.debug.print("No space left on device\n", .{});
            return err;
        },
        else => return err,
    };
    defer output_file.close();
    
    // Stream with error handling
    var buffer: [8192]u8 = undefined;
    const stream_reader = compress_stream.reader();
    var total_written: usize = 0;
    
    while (true) {
        const bytes_read = stream_reader.read(&buffer) catch |err| switch (err) {
            error.CorruptedStream => {
                std.debug.print("Stream corruption detected at offset {d}\n", .{total_written});
                return err;
            },
            error.CompressionFailed => {
                std.debug.print("Compression failed at offset {d}\n", .{total_written});
                return err;
            },
            else => return err,
        };
        
        if (bytes_read == 0) break;
        
        output_file.writeAll(buffer[0..bytes_read]) catch |err| switch (err) {
            error.NoSpaceLeft => {
                std.debug.print("Disk full after writing {d} bytes\n", .{total_written});
                return err;
            },
            else => return err,
        };
        
        total_written += bytes_read;
    }
    
    std.debug.print("Stream processing completed: {d} bytes written\n", .{total_written});
}
```

## Performance Optimization

### High-Performance Streaming

```zig
pub fn highPerformanceStream(allocator: std.mem.Allocator, input_path: []const u8, output_path: []const u8) !void {
    // Use large buffers for high throughput
    const buffer_size = 1024 * 1024; // 1MB buffer
    
    const input_file = try std.fs.cwd().openFile(input_path, .{});
    defer input_file.close();
    
    const output_file = try std.fs.cwd().createFile(output_path, .{});
    defer output_file.close();
    
    // Configure for maximum performance
    const config = archive.CompressionConfig.init(.lz4)
        .withLevel(.fastest)
        .withBufferSize(buffer_size);
    
    var compress_stream = try archive.CompressStream.initWithConfig(
        allocator,
        input_file.reader().any(),
        config
    );
    defer compress_stream.deinit();
    
    // Use large read buffer
    const read_buffer = try allocator.alloc(u8, buffer_size);
    defer allocator.free(read_buffer);
    
    const start_time = std.time.nanoTimestamp();
    var total_bytes: usize = 0;
    
    const stream_reader = compress_stream.reader();
    
    while (true) {
        const bytes_read = try stream_reader.read(read_buffer);
        if (bytes_read == 0) break;
        
        try output_file.writeAll(read_buffer[0..bytes_read]);
        total_bytes += bytes_read;
    }
    
    const end_time = std.time.nanoTimestamp();
    const duration_ms = @as(f64, @floatFromInt(end_time - start_time)) / 1_000_000.0;
    const throughput_mb = @as(f64, @floatFromInt(total_bytes)) / (1024.0 * 1024.0) / (duration_ms / 1000.0);
    
    std.debug.print("High-performance streaming: {d:.2} MB/s\n", .{throughput_mb});
}
```

## Best Practices

### Stream Guidelines

1. **Use appropriate buffer sizes** - Larger buffers = better performance
2. **Handle errors gracefully** - Streams can fail at any point
3. **Close resources properly** - Use defer for cleanup
4. **Choose right algorithm** - Fast algorithms for streaming
5. **Monitor memory usage** - Streams should use constant memory
6. **Test with large files** - Verify streaming behavior
7. **Consider network latency** - Use smaller buffers for real-time

### Common Patterns

```zig
// Standard streaming pattern
var compress_stream = try archive.CompressStream.init(allocator, reader, .lz4, 64 * 1024);
defer compress_stream.deinit();

var buffer: [8192]u8 = undefined;
const stream_reader = compress_stream.reader();

while (true) {
    const bytes_read = try stream_reader.read(&buffer);
    if (bytes_read == 0) break;
    
    // Process buffer[0..bytes_read]
}
```

## Next Steps

- Learn about [Compressor](./compressor.md) for advanced compression control
- Explore [Utils](./utils.md) for stream utilities
- Check [Constants](./constants.md) for stream constants
- See [Examples](../examples/streaming.md) for practical streaming usage