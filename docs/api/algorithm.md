# Algorithm API

The Algorithm enum defines all supported compression algorithms in Archive.zig.

## Algorithm Enum

```zig
pub const Algorithm = enum {
    gzip,
    zlib,
    deflate,
    zstd,
    lz4,
    lzma,
    xz,
    tar_gz,
    zip,
    
    pub fn getDefaultLevel(self: Algorithm) Level
    pub fn getMaxLevel(self: Algorithm) u8
    pub fn getMinLevel(self: Algorithm) u8
    pub fn getExtension(self: Algorithm) []const u8
    pub fn getMagicBytes(self: Algorithm) ?[]const u8
};
```

## Algorithm Details

### Gzip

**Format**: GNU zip with CRC32 checksum  
**Extension**: `.gz`  
**Magic Bytes**: `1F 8B`  
**Levels**: 1-9 (default: 6)

```zig
const compressed = try archive.compress(allocator, data, .gzip);
```

**Characteristics**:
- Good compression ratio
- Fast compression and decompression
- Widely supported
- Includes integrity checking

### Zlib

**Format**: Deflate with Adler32 checksum  
**Extension**: `.zlib`  
**Magic Bytes**: `78 XX` (XX varies)  
**Levels**: 1-9 (default: 6)

```zig
const compressed = try archive.compress(allocator, data, .zlib);
```

**Characteristics**:
- Similar to gzip but with Adler32 checksum
- Faster checksum calculation than CRC32
- Used in PNG images and many protocols
- Compact header format

### Deflate

**Format**: Raw deflate compression  
**Extension**: `.deflate`  
**Magic Bytes**: None (raw data)  
**Levels**: 1-9 (default: 6)

```zig
const compressed = try archive.compress(allocator, data, .deflate);
```

**Characteristics**:
- No headers or checksums
- Fastest of the deflate family
- Used in HTTP compression
- Minimal overhead

### Zstd

**Format**: Zstandard compression  
**Extension**: `.zst`  
**Magic Bytes**: `28 B5 2F FD`  
**Levels**: 1-22 (default: 3)

```zig
const compressed = try archive.compress(allocator, data, .zstd);
```

**Characteristics**:
- Excellent compression ratio and speed
- Modern algorithm with active development
- Dictionary support
- Wide level range for different use cases

### LZ4

**Format**: LZ4 frame format  
**Extension**: `.lz4`  
**Magic Bytes**: `04 22 4D 18`  
**Levels**: 1-12 (default: 1)

```zig
const compressed = try archive.compress(allocator, data, .lz4);
```

**Characteristics**:
- Extremely fast compression and decompression
- Lower compression ratio
- Ideal for real-time applications
- Minimal CPU usage

### LZMA

**Format**: LZMA compression  
**Extension**: `.lzma`  
**Magic Bytes**: `5D 00 00`  
**Levels**: 1-9 (default: 6)

```zig
const compressed = try archive.compress(allocator, data, .lzma);
```

**Characteristics**:
- Very high compression ratio
- Slow compression and decompression
- Good for archival storage
- Used in 7-Zip format

### XZ

**Format**: XZ compression (LZMA2)  
**Extension**: `.xz`  
**Magic Bytes**: `FD 37 7A 58 5A 00`  
**Levels**: 1-9 (default: 6)

```zig
const compressed = try archive.compress(allocator, data, .xz);
```

**Characteristics**:
- Based on LZMA2 algorithm
- Very high compression ratio
- Better than LZMA for certain data types
- Used by Linux distributions

### TAR.GZ

**Format**: TAR archive with gzip compression  
**Extension**: `.tar.gz`, `.tgz`  
**Magic Bytes**: `1F 8B` (gzip header)  
**Levels**: 1-9 (default: 6)

```zig
const compressed = try archive.compress(allocator, data, .tar_gz);
```

**Characteristics**:
- Combines archiving with compression
- Preserves file metadata
- Standard Unix archive format
- Good for multiple files

### ZIP

**Format**: ZIP archive format  
**Extension**: `.zip`  
**Magic Bytes**: `50 4B 03 04`  
**Levels**: 1-9 (default: 6)

```zig
const compressed = try archive.compress(allocator, data, .zip);
```

**Characteristics**:
- Universal archive format
- Cross-platform compatibility
- Supports multiple compression methods
- Built-in directory structure

## Algorithm Methods

### getDefaultLevel

```zig
pub fn getDefaultLevel(self: Algorithm) Level
```

Returns the default compression level for the algorithm.

**Example**:
```zig
const default_level = archive.Algorithm.zstd.getDefaultLevel();
// Returns Level.default (equivalent to level 3 for ZSTD)
```

### getMaxLevel

```zig
pub fn getMaxLevel(self: Algorithm) u8
```

Returns the maximum compression level supported by the algorithm.

**Example**:
```zig
const max_level = archive.Algorithm.zstd.getMaxLevel();
// Returns 22 for ZSTD
```

### getMinLevel

```zig
pub fn getMinLevel(self: Algorithm) u8
```

Returns the minimum compression level supported by the algorithm.

**Example**:
```zig
const min_level = archive.Algorithm.lz4.getMinLevel();
// Returns 1 for LZ4
```

### getExtension

```zig
pub fn getExtension(self: Algorithm) []const u8
```

Returns the standard file extension for the algorithm.

**Example**:
```zig
const ext = archive.Algorithm.gzip.getExtension();
// Returns ".gz"
```

### getMagicBytes

```zig
pub fn getMagicBytes(self: Algorithm) ?[]const u8
```

Returns the magic bytes used to identify the format, or null if none.

**Example**:
```zig
if (archive.Algorithm.gzip.getMagicBytes()) |magic| {
    // magic contains [0x1F, 0x8B]
}
```

## Algorithm Comparison

### Performance Characteristics

| Algorithm | Speed | Ratio | Memory | Use Case |
|-----------|-------|-------|--------|----------|
| LZ4 | Fastest | Low | Low | Real-time |
| Deflate | Fast | Medium | Low | Web/HTTP |
| Gzip | Fast | Medium | Low | General |
| Zlib | Fast | Medium | Low | Protocols |
| Zstd | Very Fast | High | Medium | Modern apps |
| LZMA | Slow | Very High | High | Archival |
| XZ | Slow | Very High | High | Distribution |
| TAR.GZ | Fast | Medium | Low | Unix archives |
| ZIP | Fast | Medium | Medium | Cross-platform |

### Choosing an Algorithm

**For Speed**:
```zig
// Fastest compression
const compressed = try archive.compress(allocator, data, .lz4);

// Fast with good compression
const compressed = try archive.compress(allocator, data, .zstd);
```

**For Size**:
```zig
// Maximum compression
const compressed = try archive.compress(allocator, data, .lzma);

// Good compression, reasonable speed
const compressed = try archive.compress(allocator, data, .zstd);
```

**For Compatibility**:
```zig
// Universal compatibility
const compressed = try archive.compress(allocator, data, .gzip);

// Cross-platform archives
const compressed = try archive.compress(allocator, data, .zip);
```

## Algorithm-Specific Configuration

### ZSTD Configuration

```zig
const config = archive.CompressionConfig.init(.zstd)
    .withZstdLevel(15)  // Level 1-22
    .withChecksum()
    .withBufferSize(256 * 1024);
```

### LZ4 Configuration

```zig
const config = archive.CompressionConfig.init(.lz4)
    .withLz4Level(8)    // Level 1-12
    .withChecksum();
```

### Gzip Configuration

```zig
const config = archive.CompressionConfig.init(.gzip)
    .withLevel(.best)   // Level 1-9
    .withStrategy(.huffman_only)
    .withWindowSize(32768);
```

## Error Handling

### Algorithm-Specific Errors

```zig
const compressed = archive.compress(allocator, data, .zstd) catch |err| switch (err) {
    error.ZstdError => {
        std.debug.print("ZSTD-specific error occurred\n", .{});
        return err;
    },
    error.UnsupportedAlgorithm => {
        std.debug.print("Algorithm not supported on this platform\n", .{});
        return err;
    },
    else => return err,
};
```

## Best Practices

### Algorithm Selection Guidelines

1. **Real-time applications**: Use LZ4 for minimal latency
2. **Web applications**: Use Gzip for HTTP compatibility
3. **Modern applications**: Use Zstd for best balance
4. **Archival storage**: Use LZMA or XZ for maximum compression
5. **Cross-platform**: Use Gzip or ZIP for compatibility
6. **Embedded systems**: Use LZ4 or Deflate for low memory usage

### Performance Tips

```zig
// For repeated operations with same algorithm
const algorithm = .zstd;
const config = archive.CompressionConfig.init(algorithm)
    .withZstdLevel(10);

// Reuse configuration
const compressed1 = try archive.compressWithConfig(allocator, data1, config);
const compressed2 = try archive.compressWithConfig(allocator, data2, config);
```

## Next Steps

- Learn about [Configuration](./config.md) for algorithm-specific settings
- Explore [Compressor](./compressor.md) for advanced compression control
- Check [Constants](./constants.md) for algorithm-specific constants
- See [Examples](../examples/basic.md) for practical algorithm usage