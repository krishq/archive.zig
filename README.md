# Archive.zig

<div align="center">
  <img src="https://github.com/user-attachments/assets/565fc3dc-dd2c-47a6-bab6-2f545c551f26" alt="archive.zig logo" width="400" />
  
  <a href="https://muhammad-fiaz.github.io/archive.zig/"><img src="https://img.shields.io/badge/docs-muhammad--fiaz.github.io-blue" alt="Documentation"></a>
  <a href="https://ziglang.org/"><img src="https://img.shields.io/badge/Zig-0.15.2-orange.svg?logo=zig" alt="Zig Version"></a>
  <a href="https://github.com/muhammad-fiaz/archive.zig"><img src="https://img.shields.io/github/stars/muhammad-fiaz/archive.zig" alt="GitHub stars"></a>
  <a href="https://github.com/muhammad-fiaz/archive.zig/issues"><img src="https://img.shields.io/github/issues/muhammad-fiaz/archive.zig" alt="GitHub issues"></a>
  <a href="https://github.com/muhammad-fiaz/archive.zig/pulls"><img src="https://img.shields.io/github/issues-pr/muhammad-fiaz/archive.zig" alt="GitHub pull requests"></a>
  <a href="https://github.com/muhammad-fiaz/archive.zig"><img src="https://img.shields.io/github/last-commit/muhammad-fiaz/archive.zig" alt="GitHub last commit"></a>
  <a href="https://github.com/muhammad-fiaz/archive.zig"><img src="https://img.shields.io/github/license/muhammad-fiaz/archive.zig" alt="License"></a>
  <a href="https://github.com/muhammad-fiaz/archive.zig/actions/workflows/ci.yml"><img src="https://github.com/muhammad-fiaz/archive.zig/actions/workflows/ci.yml/badge.svg" alt="CI"></a>
  <img src="https://img.shields.io/badge/platforms-linux%20%7C%20windows%20%7C%20macos-blue" alt="Supported Platforms">
  <a href="https://github.com/muhammad-fiaz/archive.zig/actions/workflows/github-code-scanning/codeql"><img src="https://github.com/muhammad-fiaz/archive.zig/actions/workflows/github-code-scanning/codeql/badge.svg" alt="CodeQL"></a>
  <a href="https://github.com/muhammad-fiaz/archive.zig/actions/workflows/release.yml"><img src="https://github.com/muhammad-fiaz/archive.zig/actions/workflows/release.yml/badge.svg" alt="Release"></a>
  <a href="https://github.com/muhammad-fiaz/archive.zig/releases/latest"><img src="https://img.shields.io/github/v/release/muhammad-fiaz/archive.zig?label=Latest%20Release&style=flat-square" alt="Latest Release"></a>
  <a href="https://pay.muhammadfiaz.com"><img src="https://img.shields.io/badge/Sponsor-pay.muhammadfiaz.com-ff69b4?style=flat&logo=heart" alt="Sponsor"></a>
  <a href="https://github.com/sponsors/muhammad-fiaz"><img src="https://img.shields.io/badge/Sponsor-💖-pink?style=social&logo=github" alt="GitHub Sponsors"></a>
  <a href="https://hits.sh/muhammad-fiaz/archive.zig/"><img src="https://hits.sh/muhammad-fiaz/archive.zig.svg?label=Visitors&extraCount=0&color=green" alt="Repo Visitors"></a>

  <p><em>A comprehensive, high-performance archive and compression library for Zig.</em></p>

  <b>
    <a href="https://muhammad-fiaz.github.io/archive.zig/">Documentation</a> |
    <a href="https://muhammad-fiaz.github.io/archive.zig/api/archive">API Reference</a> |
    <a href="https://muhammad-fiaz.github.io/archive.zig/guide/quick-start">Quick Start</a> |
    <a href="CONTRIBUTING.md">Contributing</a>
  </b>
</div>

A production-grade, high-performance archive and compression library for Zig, supporting multiple compression algorithms and archive formats with a clean, intuitive API.

> [!NOTE]
> This project aims to be production ready with comprehensive compression algorithm support and efficient implementations optimized for Zig 0.15+.

**⭐️ If you love `archive.zig`, make sure to give it a star! ⭐️**

---

<details>
<summary><strong>Table of Contents</strong> (click to expand)</summary>

- [Prerequisites](#prerequisites)
- [Supported Platforms](#supported-platforms)
- [Supported Algorithms](#supported-algorithms)
- [Installation](#installation)
  - [Method 1: Zig Fetch (Recommended)](#method-1-zig-fetch-recommended)
  - [Method 2: Manual Configuration](#method-2-manual-configuration)
  - [Method 3: Building from Source](#method-3-building-from-source)
- [Quick Start](#quick-start)
- [Usage Examples](#usage-examples)
  - [Basic Compression](#basic-compression)
  - [Configuration Presets](#configuration-presets)
  - [Builder Pattern](#builder-pattern)
  - [Auto-Detection](#auto-detection)
  - [File Operations](#file-operations)
  - [Streaming Interface](#streaming-interface)
- [Configuration](#configuration)
- [API Reference](#api-reference)
- [Building](#building)
- [Documentation](#documentation)
- [Contributing](#contributing)
- [License](#license)
- [Links](#links)

</details>

---

<details>
<summary><strong>Features of Archive.zig</strong> (click to expand)</summary>

| Feature | Description | Documentation |
|---------|-------------|---------------|
| **Multiple Algorithms** | Support for 9 compression algorithms: gzip, zlib, deflate, zstd, lz4, lzma, xz, tar.gz, zip | [Docs](https://muhammad-fiaz.github.io/archive.zig/guide/algorithms) |
| **Simple & Clean API** | User-friendly compression interface (`archive.compress()`, `archive.decompress()`, etc.) | [Docs](https://muhammad-fiaz.github.io/archive.zig/guide/getting-started) |
| **Configuration Presets** | Pre-configured settings for fast, balanced, best compression, and production use | [Docs](https://muhammad-fiaz.github.io/archive.zig/guide/configuration) |
| **Builder Pattern** | Fluent API for configuring compression with method chaining | [Docs](https://muhammad-fiaz.github.io/archive.zig/guide/builder) |
| **Auto-Detection** | Automatic algorithm detection from compressed data headers | [Docs](https://muhammad-fiaz.github.io/archive.zig/guide/auto-detection) |
| **Streaming Interface** | Memory-efficient streaming compression and decompression | [Docs](https://muhammad-fiaz.github.io/archive.zig/guide/streaming) |
| **File Operations** | Direct file compression and decompression with proper error handling | [Docs](https://muhammad-fiaz.github.io/archive.zig/guide/file-operations) |
| **Cross-Platform** | Works on Windows, Linux, macOS, and bare metal targets | [Docs](https://muhammad-fiaz.github.io/archive.zig/guide/platforms) |
| **Thread-Safe** | Safe concurrent compression from multiple threads | [Docs](https://muhammad-fiaz.github.io/archive.zig/guide/threading) |
| **Memory Efficient** | Optimized memory usage with configurable buffer sizes | [Docs](https://muhammad-fiaz.github.io/archive.zig/guide/memory) |
| **Error Handling** | Comprehensive error types and proper error propagation | [Docs](https://muhammad-fiaz.github.io/archive.zig/guide/errors) |
| **Utility Functions** | Helper functions for size formatting, CRC calculation, and more | [Docs](https://muhammad-fiaz.github.io/archive.zig/api/utils) |

</details>

---

<details>
<summary><strong>Prerequisites & Supported Platforms</strong> (click to expand)</summary>

## Prerequisites

Before installing Archive.zig, ensure you have the following:

| Requirement | Version | Notes |
|-------------|---------|-------|
| **Zig** | 0.15.0+ | Download from [ziglang.org](https://ziglang.org/download/) |
| **Operating System** | Windows 10+, Linux, macOS | Cross-platform support |
| **Memory** | 64MB+ available | For compression operations |

> Verify your Zig installation by running `zig version` in your terminal.

---

## Supported Platforms

Archive.zig supports a wide range of platforms and architectures:

| Platform | Architectures | Status |
|----------|---------------|--------|
| **Windows** | x86_64, x86 | Full support |
| **Linux** | x86_64, x86, aarch64 | Full support |
| **macOS** | x86_64, aarch64 (Apple Silicon) | Full support |
| **Bare Metal / Freestanding** | x86_64, aarch64, arm, riscv64 | Full support |

---

## Supported Algorithms

| Algorithm | Extension | Description | Performance |
|-----------|-----------|-------------|-------------|
| **gzip** | `.gz` | GNU zip compression with CRC32 | Fast |
| **zlib** | `.zlib` | Deflate with Adler32 checksum | Fast |
| **deflate** | `.deflate` | Raw deflate compression | Fastest |
| **zstd** | `.zst` | Zstandard - modern, fast compression | Very Fast |
| **lz4** | `.lz4` | Ultra-fast compression | Fastest |
| **lzma** | `.lzma` | High compression ratio | Slow |
| **xz** | `.xz` | LZMA2-based compression | Slow |
| **tar.gz** | `.tar.gz` | TAR archive with gzip compression | Fast |
| **zip** | `.zip` | ZIP archive format | Fast |

</details>

---

## Installation

### Method 1: Zig Fetch (Recommended)

The easiest way to add Archive.zig to your project:

```bash
zig fetch --save https://github.com/muhammad-fiaz/archive.zig/archive/refs/tags/v1.0.0.tar.gz
```

This automatically adds the dependency with the correct hash to your `build.zig.zon`.

### Method 2: Manual Configuration

Add to your `build.zig.zon`:

```zig
.dependencies = .{
    .archive = .{
        .url = "https://github.com/muhammad-fiaz/archive.zig/archive/refs/tags/v1.0.0.tar.gz",
        .hash = "...", // Run zig fetch to get the hash
    },
},
```

Then in your `build.zig`:

```zig
const archive = b.dependency("archive", .{
    .target = target,
    .optimize = optimize,
});

exe.root_module.addImport("archive", archive.module("archive"));
```

### Method 3: Building from Source

Clone the repository and build Archive.zig:

```bash
git clone https://github.com/muhammad-fiaz/archive.zig.git
cd archive.zig
zig build
```

## Quick Start

```zig
const std = @import("std");
const archive = @import("archive");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // Basic compression
    const input = "Hello, World! This is a test of the archive library.";
    
    // Compress with different algorithms
    const gzip_compressed = try archive.compress(allocator, input, .gzip);
    defer allocator.free(gzip_compressed);
    
    const zstd_compressed = try archive.compress(allocator, input, .zstd);
    defer allocator.free(zstd_compressed);
    
    // Decompress
    const decompressed = try archive.decompress(allocator, gzip_compressed, .gzip);
    defer allocator.free(decompressed);
    
    std.debug.print("Original: {s}\n", .{input});
    std.debug.print("Decompressed: {s}\n", .{decompressed});
    std.debug.print("Compression ratio: {d:.1}%\n", .{
        @as(f64, @floatFromInt(gzip_compressed.len)) / @as(f64, @floatFromInt(input.len)) * 100
    });
}
```

## Usage Examples

### Basic Compression

```zig
const std = @import("std");
const archive = @import("archive");

pub fn basicCompression(allocator: std.mem.Allocator) !void {
    const input = "Hello, World! This is a test of compression.";
    
    // Try different algorithms
    const algorithms = [_]archive.Algorithm{
        .gzip, .zlib, .deflate, .zstd, .lz4, .lzma, .xz, .tar_gz, .zip
    };
    
    for (algorithms) |algo| {
        const compressed = try archive.compress(allocator, input, algo);
        defer allocator.free(compressed);
        
        const decompressed = try archive.decompress(allocator, compressed, algo);
        defer allocator.free(decompressed);
        
        const ratio = @as(f64, @floatFromInt(compressed.len)) / @as(f64, @floatFromInt(input.len)) * 100;
        std.debug.print("{s}: {d} bytes ({d:.1}%)\n", .{ @tagName(algo), compressed.len, ratio });
    }
}
```

### Configuration Presets

```zig
pub fn configurationPresets(allocator: std.mem.Allocator) !void {
    const input = "Configuration preset test data for compression.";
    
    // Use different presets
    const presets = [_]archive.CompressionConfig{
        archive.CompressionConfig.fast(),
        archive.CompressionConfig.balanced(),
        archive.CompressionConfig.best(),
        archive.CompressionConfig.zstd(),
        archive.CompressionConfig.production(),
    };
    
    for (presets) |preset| {
        const compressed = try archive.compressWithConfig(allocator, input, preset);
        defer allocator.free(compressed);
        
        std.debug.print("Preset: {d} bytes\n", .{compressed.len});
    }
}
```

### Builder Pattern

```zig
pub fn builderPattern(allocator: std.mem.Allocator) !void {
    const input = "Builder pattern example data.";
    
    // Configure compression with builder pattern
    const compressor = archive.Compressor.init(allocator, .gzip)
        .withLevel(6)
        .withChecksum();
    
    const compressed = try compressor.compress_data(input);
    defer allocator.free(compressed);
    
    const decompressed = try compressor.decompress_data(compressed);
    defer allocator.free(decompressed);
    
    std.debug.print("Builder pattern: {d} bytes\n", .{compressed.len});
}
```

### Auto-Detection

```zig
pub fn autoDetection(allocator: std.mem.Allocator) !void {
    const input = "Auto-detection test data.";
    
    // Compress with gzip
    const compressed = try archive.compress(allocator, input, .gzip);
    defer allocator.free(compressed);
    
    // Auto-detect algorithm and decompress
    const detected = archive.detectAlgorithm(compressed);
    const auto_decomp = try archive.autoDecompress(allocator, compressed);
    defer allocator.free(auto_decomp);
    
    std.debug.print("Detected algorithm: {?}\n", .{detected});
    std.debug.print("Auto-decompressed: {s}\n", .{auto_decomp});
}
```

### File Operations

```zig
pub fn fileOperations(allocator: std.mem.Allocator) !void {
    const test_data = "This is test data for file operations.";
    
    // Write test file
    try std.fs.cwd().writeFile(.{ .sub_path = "test.txt", .data = test_data });
    
    // Compress to file
    const compressed = try archive.compress(allocator, test_data, .gzip);
    defer allocator.free(compressed);
    
    try std.fs.cwd().writeFile(.{ .sub_path = "test.gz", .data = compressed });
    
    // Read and decompress
    const read_compressed = try std.fs.cwd().readFileAlloc(allocator, "test.gz", 1024 * 1024);
    defer allocator.free(read_compressed);
    
    const decompressed = try archive.decompress(allocator, read_compressed, .gzip);
    defer allocator.free(decompressed);
    
    std.debug.print("File operations successful: {}\n", .{std.mem.eql(u8, test_data, decompressed)});
    
    // Cleanup
    std.fs.cwd().deleteFile("test.txt") catch {};
    std.fs.cwd().deleteFile("test.gz") catch {};
}
```

### Streaming Interface

```zig
pub fn streamingInterface(allocator: std.mem.Allocator) !void {
    const input = "Large data for streaming compression...";
    
    // Create streaming compressor
    var compressor = try archive.StreamingCompressor.init(allocator, .gzip);
    defer compressor.deinit();
    
    // Compress in chunks
    try compressor.write(input[0..10]);
    try compressor.write(input[10..]);
    const compressed = try compressor.finish();
    defer allocator.free(compressed);
    
    // Create streaming decompressor
    var decompressor = try archive.StreamingDecompressor.init(allocator, .gzip);
    defer decompressor.deinit();
    
    const decompressed = try decompressor.decompress(compressed);
    defer allocator.free(decompressed);
    
    std.debug.print("Streaming: {s}\n", .{decompressed});
}
```

## Configuration

```zig
// Basic configuration
var config = archive.CompressionConfig.default();
config.level = 6;
config.checksum = true;

// Use configuration
const compressed = try archive.compressWithConfig(allocator, data, config);

// Preset configurations
const fast_config = archive.CompressionConfig.fast();
const best_config = archive.CompressionConfig.best();
const production_config = archive.CompressionConfig.production();

// Algorithm-specific configurations
const zstd_config = archive.CompressionConfig.zstdWithLevel(15);
const lz4_config = archive.CompressionConfig.lz4Fast();
```

## API Reference

### Core Functions

```zig
// Basic compression/decompression
pub fn compress(allocator: Allocator, data: []const u8, algorithm: Algorithm) ![]u8
pub fn decompress(allocator: Allocator, data: []const u8, algorithm: Algorithm) ![]u8

// With configuration
pub fn compressWithConfig(allocator: Allocator, data: []const u8, config: CompressionConfig) ![]u8

// Auto-detection
pub fn detectAlgorithm(data: []const u8) ?Algorithm
pub fn autoDecompress(allocator: Allocator, data: []const u8) ![]u8
```

### Algorithms

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
    
    pub fn extension(self: Algorithm) []const u8
};
```

### Configuration

```zig
pub const CompressionConfig = struct {
    algorithm: Algorithm,
    level: ?u8,
    checksum: bool,
    include_patterns: []const []const u8,
    exclude_patterns: []const []const u8,
    
    pub fn fast() CompressionConfig
    pub fn balanced() CompressionConfig
    pub fn best() CompressionConfig
    pub fn zstd() CompressionConfig
    pub fn production() CompressionConfig
};
```

## Building

```bash
# Run tests
zig build test

# Build library
zig build

# Run examples
zig build run

# Build documentation
zig build docs
```

## Documentation

### Online Documentation

Full documentation is available at: https://muhammad-fiaz.github.io/archive.zig

### Generating Local Documentation

To generate documentation locally:

```bash
zig build docs
```

This will generate HTML documentation in the `zig-out/docs/` directory.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

MIT License - see [LICENSE](LICENSE) for details.

## Links

- **Documentation**: https://muhammad-fiaz.github.io/archive.zig
- **Repository**: https://github.com/muhammad-fiaz/archive.zig
- **Issues**: https://github.com/muhammad-fiaz/archive.zig/issues
- **Releases**: https://github.com/muhammad-fiaz/archive.zig/releases