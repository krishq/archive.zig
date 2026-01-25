# Configuration API

The Configuration API provides flexible, client-side customization of compression settings through the builder pattern.

## CompressionConfig

```zig
pub const CompressionConfig = struct {
    algorithm: Algorithm,
    level: Level,
    custom_level: ?u8,
    zstd_level: ?c_int,
    lz4_level: ?c_int,
    buffer_size: usize,
    memory_level: u8,
    window_size: u32,
    strategy: Strategy,
    checksum: bool,
    keep_original: bool,
    recursive: bool,
    follow_symlinks: bool,
    max_depth: ?usize,
    min_file_size: ?usize,
    max_file_size: ?usize,
    include_patterns: []const FilterRule,
    exclude_patterns: []const FilterRule,
    dictionary: ?[]const u8,
    
    pub fn init(algorithm: Algorithm) CompressionConfig
    pub fn withLevel(self: CompressionConfig, level: Level) CompressionConfig
    pub fn withCustomLevel(self: CompressionConfig, level: u8) CompressionConfig
    pub fn withZstdLevel(self: CompressionConfig, level: c_int) CompressionConfig
    pub fn withLz4Level(self: CompressionConfig, level: c_int) CompressionConfig
    pub fn withBufferSize(self: CompressionConfig, size: usize) CompressionConfig
    pub fn withMemoryLevel(self: CompressionConfig, level: u8) CompressionConfig
    pub fn withWindowSize(self: CompressionConfig, size: u32) CompressionConfig
    pub fn withStrategy(self: CompressionConfig, strategy: Strategy) CompressionConfig
    pub fn withChecksum(self: CompressionConfig) CompressionConfig
    pub fn withKeepOriginal(self: CompressionConfig) CompressionConfig
    pub fn withRecursive(self: CompressionConfig, recursive: bool) CompressionConfig
    pub fn withFollowSymlinks(self: CompressionConfig) CompressionConfig
    pub fn withMaxDepth(self: CompressionConfig, depth: ?usize) CompressionConfig
    pub fn withSizeRange(self: CompressionConfig, min_size: ?usize, max_size: ?usize) CompressionConfig
    pub fn includeFiles(self: CompressionConfig, patterns: []const []const u8) CompressionConfig
    pub fn excludeFiles(self: CompressionConfig, patterns: []const []const u8) CompressionConfig
    pub fn includeDirectories(self: CompressionConfig, patterns: []const []const u8, recursive: bool) CompressionConfig
    pub fn excludeDirectories(self: CompressionConfig, patterns: []const []const u8, recursive: bool) CompressionConfig
    pub fn withIncludePatterns(self: CompressionConfig, rules: []const FilterRule) CompressionConfig
    pub fn withExcludePatterns(self: CompressionConfig, rules: []const FilterRule) CompressionConfig
    pub fn withDictionary(self: CompressionConfig, dictionary: []const u8) CompressionConfig
    pub fn shouldIncludePath(self: CompressionConfig, path: []const u8, is_directory: bool) bool
};
```

## Initialization

### Basic Initialization

```zig
// Initialize with algorithm
const config = archive.CompressionConfig.init(.zstd);
```

### Chained Configuration

```zig
const config = archive.CompressionConfig.init(.zstd)
    .withZstdLevel(15)
    .withChecksum()
    .withBufferSize(256 * 1024);
```

## Compression Levels

### Level Enum

```zig
pub const Level = enum {
    fastest,    // Level 1
    fast,       // Level 3
    default,    // Level 6
    best,       // Level 9
};
```

### Setting Levels

```zig
// Preset levels
const config = archive.CompressionConfig.init(.gzip)
    .withLevel(.best);

// Custom level (0-9 for most algorithms)
const config = archive.CompressionConfig.init(.gzip)
    .withCustomLevel(7);

// ZSTD-specific level (1-22)
const config = archive.CompressionConfig.init(.zstd)
    .withZstdLevel(19);

// LZ4-specific level (1-12)
const config = archive.CompressionConfig.init(.lz4)
    .withLz4Level(8);
```

## Performance Configuration

### Buffer Management

```zig
const config = archive.CompressionConfig.init(.gzip)
    .withBufferSize(128 * 1024)     // 128KB buffer
    .withMemoryLevel(8)             // Memory usage level (1-9)
    .withWindowSize(32768);         // Compression window size
```

### Compression Strategy

```zig
pub const Strategy = enum {
    default,
    filtered,
    huffman_only,
    rle,
    fixed,
};

const config = archive.CompressionConfig.init(.gzip)
    .withStrategy(.huffman_only);   // Huffman-only compression
```

## File Filtering

### FilterRule Structure

```zig
pub const FilterRule = struct {
    pattern: []const u8,
    is_directory: bool,
    case_sensitive: bool,
    is_recursive: bool,
};
```

### Simple File Patterns

```zig
const config = archive.CompressionConfig.init(.gzip)
    .includeFiles(&[_][]const u8{ "*.zig", "*.md", "*.json" })
    .excludeFiles(&[_][]const u8{ "*.tmp", "*.log", "*.cache" });
```

### Directory Patterns

```zig
const config = archive.CompressionConfig.init(.gzip)
    .includeDirectories(&[_][]const u8{ "src/**", "docs/**" }, true)
    .excludeDirectories(&[_][]const u8{ ".git/**", "node_modules/**" }, true);
```

### Advanced Filter Rules

```zig
const include_rules = [_]archive.FilterRule{
    .{ .pattern = "src/**", .is_directory = true, .case_sensitive = true, .is_recursive = true },
    .{ .pattern = "*.zig", .is_directory = false, .case_sensitive = true, .is_recursive = false },
};

const exclude_rules = [_]archive.FilterRule{
    .{ .pattern = "*.tmp", .is_directory = false, .case_sensitive = false, .is_recursive = false },
    .{ .pattern = "build/**", .is_directory = true, .case_sensitive = true, .is_recursive = true },
};

const config = archive.CompressionConfig.init(.zstd)
    .withIncludePatterns(&include_rules)
    .withExcludePatterns(&exclude_rules);
```

## Directory Traversal

### Traversal Options

```zig
const config = archive.CompressionConfig.init(.gzip)
    .withRecursive(true)            // Enable recursive traversal
    .withFollowSymlinks()           // Follow symbolic links
    .withMaxDepth(5)                // Limit traversal depth
    .withSizeRange(1024, 10 * 1024 * 1024); // File size range (1KB to 10MB)
```

## Quality Options

### Integrity and Preservation

```zig
const config = archive.CompressionConfig.init(.zstd)
    .withChecksum()                 // Enable checksum verification
    .withKeepOriginal();            // Keep original files after compression
```

### Dictionary Compression

```zig
const dictionary = "common words and phrases used in the data";
const config = archive.CompressionConfig.init(.zstd)
    .withDictionary(dictionary);
```

## Configuration Examples

### Development Configuration

```zig
pub fn developmentConfig() archive.CompressionConfig {
    return archive.CompressionConfig.init(.lz4)
        .withLevel(.fastest)
        .excludeFiles(&[_][]const u8{ "*.tmp", "*.log", "*.obj", "*.exe" })
        .excludeDirectories(&[_][]const u8{ ".git/**", "zig-cache/**", "zig-out/**" }, true)
        .withRecursive(true)
        .withMaxDepth(10)
        .withBufferSize(64 * 1024);
}
```

### Production Configuration

```zig
pub fn productionConfig() archive.CompressionConfig {
    return archive.CompressionConfig.init(.zstd)
        .withZstdLevel(15)
        .withChecksum()
        .withKeepOriginal()
        .excludeDirectories(&[_][]const u8{ ".git/**", "node_modules/**", "target/**" }, true)
        .withSizeRange(1, null)      // Exclude empty files
        .withRecursive(true)
        .withBufferSize(512 * 1024)
        .withMemoryLevel(9);
}
```

### Archive Configuration

```zig
pub fn archiveConfig() archive.CompressionConfig {
    return archive.CompressionConfig.init(.lzma)
        .withLevel(.best)
        .withChecksum()
        .withFollowSymlinks()
        .withSizeRange(0, null)      // No size limits
        .withMaxDepth(null)          // No depth limits
        .withBufferSize(1024 * 1024)
        .withMemoryLevel(9);
}
```

### Memory-Efficient Configuration

```zig
pub fn memoryEfficientConfig() archive.CompressionConfig {
    return archive.CompressionConfig.init(.lz4)
        .withLevel(.fastest)
        .withBufferSize(32 * 1024)   // Small buffer
        .withMemoryLevel(4)          // Low memory usage
        .withRecursive(false);       // Avoid deep recursion
}
```

## Path Filtering Methods

### shouldIncludePath

```zig
pub fn shouldIncludePath(self: CompressionConfig, path: []const u8, is_directory: bool) bool
```

Determines whether a path should be included based on the configuration rules.

**Example**:
```zig
const config = archive.CompressionConfig.init(.gzip)
    .includeFiles(&[_][]const u8{ "*.zig" })
    .excludeFiles(&[_][]const u8{ "*.tmp" });

const should_include = config.shouldIncludePath("src/main.zig", false);
// Returns true

const should_exclude = config.shouldIncludePath("temp.tmp", false);
// Returns false
```

## Pattern Matching

### Supported Patterns

- `*` - Match any characters
- `**` - Match any characters including path separators (recursive)
- `?` - Match single character
- `[abc]` - Match any character in brackets
- `[!abc]` - Match any character not in brackets

### Pattern Examples

```zig
const patterns = [_][]const u8{
    "*.txt",           // All .txt files
    "src/**/*.zig",    // All .zig files in src and subdirectories
    "test_*.zig",      // Files starting with "test_"
    "**/*.md",         // All .md files anywhere
    "build/**",        // Everything in build directory
};
```

## Validation

### Configuration Validation

```zig
pub fn validateConfig(config: archive.CompressionConfig) !void {
    // Validate buffer size
    if (config.buffer_size < 1024) {
        return error.BufferTooSmall;
    }
    
    // Validate ZSTD level
    if (config.algorithm == .zstd) {
        if (config.zstd_level) |level| {
            if (level < 1 or level > 22) {
                return error.InvalidZstdLevel;
            }
        }
    }
    
    // Validate LZ4 level
    if (config.algorithm == .lz4) {
        if (config.lz4_level) |level| {
            if (level < 1 or level > 12) {
                return error.InvalidLz4Level;
            }
        }
    }
    
    // Validate memory level
    if (config.memory_level < 1 or config.memory_level > 9) {
        return error.InvalidMemoryLevel;
    }
}
```

## Configuration Utilities

### Configuration Merging

```zig
pub fn mergeConfigs(base: archive.CompressionConfig, override: archive.CompressionConfig) archive.CompressionConfig {
    var result = base;
    
    // Override non-default values
    if (override.level != .default) result.level = override.level;
    if (override.custom_level != null) result.custom_level = override.custom_level;
    if (override.zstd_level != null) result.zstd_level = override.zstd_level;
    if (override.lz4_level != null) result.lz4_level = override.lz4_level;
    if (override.buffer_size != 0) result.buffer_size = override.buffer_size;
    if (override.checksum) result.checksum = true;
    if (override.keep_original) result.keep_original = true;
    
    return result;
}
```

### Configuration Serialization

```zig
pub fn configToJson(allocator: std.mem.Allocator, config: archive.CompressionConfig) ![]u8 {
    return std.json.stringifyAlloc(allocator, config, .{});
}

pub fn configFromJson(allocator: std.mem.Allocator, json: []const u8) !archive.CompressionConfig {
    const parsed = try std.json.parseFromSlice(archive.CompressionConfig, allocator, json, .{});
    defer parsed.deinit();
    return parsed.value;
}
```

## Best Practices

### Configuration Guidelines

1. **Start with algorithm selection** - Choose based on your use case
2. **Set appropriate levels** - Balance compression vs speed
3. **Configure buffers wisely** - Larger buffers = better compression, more memory
4. **Use filtering effectively** - Exclude unnecessary files early
5. **Test configurations** - Benchmark on representative data
6. **Document configurations** - Make settings clear for team members
7. **Validate inputs** - Check configuration validity before use

### Common Configurations

```zig
// Fast compression for development
const fast_config = archive.CompressionConfig.init(.lz4)
    .withLevel(.fastest);

// Balanced compression for general use
const balanced_config = archive.CompressionConfig.init(.zstd)
    .withZstdLevel(6);

// Maximum compression for archival
const max_config = archive.CompressionConfig.init(.lzma)
    .withLevel(.best);

// Web-optimized compression
const web_config = archive.CompressionConfig.init(.gzip)
    .withLevel(.default)
    .withStrategy(.huffman_only);
```

## Next Steps

- Learn about [Algorithm](./algorithm.md) for algorithm-specific details
- Explore [Compressor](./compressor.md) for advanced compression control
- Check [Utils](./utils.md) for configuration utilities
- See [Examples](../examples/configuration.md) for practical configuration usage