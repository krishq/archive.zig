# Archive API

The main Archive.zig API provides simple functions for compression and decompression.

## Core Functions

### `compress`

```zig
pub fn compress(allocator: Allocator, data: []const u8, algorithm: Algorithm) ![]u8
```

Compresses data using the specified algorithm.

**Parameters:**
- `allocator`: Memory allocator
- `data`: Input data to compress
- `algorithm`: Compression algorithm to use

**Returns:** Compressed data (caller owns memory)

**Example:**
```zig
const compressed = try archive.compress(allocator, "Hello, World!", .gzip);
defer allocator.free(compressed);
```

### `decompress`

```zig
pub fn decompress(allocator: Allocator, data: []const u8, algorithm: Algorithm) ![]u8
```

Decompresses data using the specified algorithm.

**Parameters:**
- `allocator`: Memory allocator
- `data`: Compressed data to decompress
- `algorithm`: Algorithm used for compression

**Returns:** Decompressed data (caller owns memory)

**Example:**
```zig
const decompressed = try archive.decompress(allocator, compressed_data, .gzip);
defer allocator.free(decompressed);
```

### `compressWithConfig`

```zig
pub fn compressWithConfig(allocator: Allocator, data: []const u8, config: CompressionConfig) ![]u8
```

Compresses data with custom configuration.

**Parameters:**
- `allocator`: Memory allocator
- `data`: Input data to compress
- `config`: Compression configuration

**Returns:** Compressed data (caller owns memory)

**Example:**
```zig
const config = archive.CompressionConfig.best();
const compressed = try archive.compressWithConfig(allocator, data, config);
defer allocator.free(compressed);
```

## Auto-Detection Functions

### `detectAlgorithm`

```zig
pub fn detectAlgorithm(data: []const u8) ?Algorithm
```

Automatically detects the compression algorithm from data headers.

**Parameters:**
- `data`: Compressed data

**Returns:** Detected algorithm or `null` if unknown

**Example:**
```zig
if (archive.detectAlgorithm(compressed_data)) |algo| {
    std.debug.print("Detected: {s}\n", .{@tagName(algo)});
}
```

### `autoDecompress`

```zig
pub fn autoDecompress(allocator: Allocator, data: []const u8) ![]u8
```

Automatically detects algorithm and decompresses data.

**Parameters:**
- `allocator`: Memory allocator
- `data`: Compressed data

**Returns:** Decompressed data (caller owns memory)

**Example:**
```zig
const decompressed = try archive.autoDecompress(allocator, compressed_data);
defer allocator.free(decompressed);
```

## Error Handling

All functions return errors for various failure conditions:

```zig
const CompressError = error{
    OutOfMemory,
    InvalidData,
    InvalidMagic,
    UnsupportedAlgorithm,
    CorruptedStream,
    ChecksumMismatch,
    InvalidOffset,
    InvalidTarArchive,
    ZstdError,
    UnsupportedCompressionMethod,
    ZipUncompressSizeMismatch,
    InvalidZipArchive,
};
```

**Example with error handling:**
```zig
const compressed = archive.compress(allocator, data, .gzip) catch |err| switch (err) {
    error.OutOfMemory => {
        std.debug.print("Not enough memory\n", .{});
        return;
    },
    error.InvalidData => {
        std.debug.print("Invalid input data\n", .{});
        return;
    },
    else => return err,
};
```