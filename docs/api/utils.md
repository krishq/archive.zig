# Utils API

The Utils API provides utility functions for path validation, compression estimation, glob matching, and other helper operations.

## Path Utilities

### Path Validation

```zig
pub fn validatePath(path: []const u8) bool
pub fn normalizePath(allocator: std.mem.Allocator, path: []const u8) ![]u8
pub fn isAbsolutePath(path: []const u8) bool
pub fn isRelativePath(path: []const u8) bool
pub fn sanitizePath(allocator: std.mem.Allocator, path: []const u8) ![]u8
```

#### Path Validation Examples

```zig
const std = @import("std");
const archive = @import("archive");

pub fn pathValidationExample() !void {
    // Validate paths
    const valid_path = "src/main.zig";
    const invalid_path = "../../../etc/passwd";
    
    if (archive.utils.validatePath(valid_path)) {
        std.debug.print("Path is valid: {s}\n", .{valid_path});
    }
    
    if (!archive.utils.validatePath(invalid_path)) {
        std.debug.print("Path is invalid: {s}\n", .{invalid_path});
    }
    
    // Check path types
    const abs_path = "/home/user/file.txt";
    const rel_path = "docs/readme.md";
    
    std.debug.print("Absolute path: {}\n", .{archive.utils.isAbsolutePath(abs_path)});
    std.debug.print("Relative path: {}\n", .{archive.utils.isRelativePath(rel_path)});
}
```

#### Path Normalization

```zig
pub fn pathNormalizationExample(allocator: std.mem.Allocator) !void {
    const messy_path = "src/../src/./main.zig";
    const normalized = try archive.utils.normalizePath(allocator, messy_path);
    defer allocator.free(normalized);
    
    std.debug.print("Original: {s}\n", .{messy_path});
    std.debug.print("Normalized: {s}\n", .{normalized});
    // Output: "src/main.zig"
}
```

#### Path Sanitization

```zig
pub fn pathSanitizationExample(allocator: std.mem.Allocator) !void {
    const unsafe_path = "../../sensitive/file.txt";
    const sanitized = try archive.utils.sanitizePath(allocator, unsafe_path);
    defer allocator.free(sanitized);
    
    std.debug.print("Unsafe: {s}\n", .{unsafe_path});
    std.debug.print("Sanitized: {s}\n", .{sanitized});
    // Output: "sensitive/file.txt" (removes directory traversal)
}
```

## Glob Matching

### Glob Pattern Matching

```zig
pub fn matchGlob(pattern: []const u8, text: []const u8, case_sensitive: bool) bool
pub fn matchGlobRecursive(pattern: []const u8, path: []const u8, case_sensitive: bool) bool
pub fn compileGlob(allocator: std.mem.Allocator, pattern: []const u8) !GlobMatcher
```

#### Basic Glob Matching

```zig
pub fn globMatchingExample() !void {
    const patterns = [_][]const u8{
        "*.txt",
        "src/**/*.zig",
        "test_*.zig",
        "**/*.md",
    };
    
    const files = [_][]const u8{
        "readme.txt",
        "src/main.zig",
        "src/utils/helper.zig",
        "test_main.zig",
        "docs/guide.md",
        "src/docs/api.md",
    };
    
    for (patterns) |pattern| {
        std.debug.print("Pattern: {s}\n", .{pattern});
        for (files) |file| {
            const matches = archive.utils.matchGlob(pattern, file, true);
            if (matches) {
                std.debug.print("  Matches: {s}\n", .{file});
            }
        }
        std.debug.print("\n", .{});
    }
}
```

#### Recursive Glob Matching

```zig
pub fn recursiveGlobExample() !void {
    const pattern = "src/**/*.zig";
    const paths = [_][]const u8{
        "src/main.zig",
        "src/utils/helper.zig",
        "src/algorithms/gzip.zig",
        "tests/main.zig",
        "docs/readme.md",
    };
    
    for (paths) |path| {
        const matches = archive.utils.matchGlobRecursive(pattern, path, true);
        std.debug.print("{s}: {}\n", .{ path, matches });
    }
}
```

### GlobMatcher

```zig
pub const GlobMatcher = struct {
    pattern: []const u8,
    compiled: CompiledPattern,
    case_sensitive: bool,
    
    pub fn init(allocator: std.mem.Allocator, pattern: []const u8, case_sensitive: bool) !GlobMatcher
    pub fn deinit(self: *GlobMatcher) void
    pub fn match(self: *GlobMatcher, text: []const u8) bool
    pub fn matchPath(self: *GlobMatcher, path: []const u8) bool
};
```

#### Compiled Glob Example

```zig
pub fn compiledGlobExample(allocator: std.mem.Allocator) !void {
    // Compile glob pattern for reuse
    var matcher = try archive.utils.compileGlob(allocator, "src/**/*.zig");
    defer matcher.deinit();
    
    const test_paths = [_][]const u8{
        "src/main.zig",
        "src/utils/helper.zig",
        "src/algorithms/gzip.zig",
        "tests/test.zig",
        "docs/readme.md",
    };
    
    for (test_paths) |path| {
        const matches = matcher.matchPath(path);
        std.debug.print("{s}: {}\n", .{ path, matches });
    }
}
```

## Compression Estimation

### Size Estimation

```zig
pub fn estimateCompressedSize(data: []const u8, algorithm: Algorithm) usize
pub fn estimateCompressionRatio(data: []const u8, algorithm: Algorithm) f64
pub fn analyzeCompressibility(data: []const u8) CompressibilityAnalysis
```

#### Compression Estimation Examples

```zig
pub fn compressionEstimationExample() !void {
    const test_data = "This is test data for compression estimation " ** 100;
    
    const algorithms = [_]archive.Algorithm{ .lz4, .gzip, .zstd, .lzma };
    
    std.debug.print("Original size: {d} bytes\n", .{test_data.len});
    std.debug.print("Algorithm | Estimated Size | Estimated Ratio\n");
    std.debug.print("----------|----------------|----------------\n");
    
    for (algorithms) |algo| {
        const estimated_size = archive.utils.estimateCompressedSize(test_data, algo);
        const estimated_ratio = archive.utils.estimateCompressionRatio(test_data, algo);
        
        std.debug.print("{s:>9} | {d:>14} | {d:>14.1}%\n", 
                       .{ @tagName(algo), estimated_size, estimated_ratio * 100 });
    }
}
```

### CompressibilityAnalysis

```zig
pub const CompressibilityAnalysis = struct {
    entropy: f64,
    repetition_ratio: f64,
    pattern_score: f64,
    recommended_algorithm: Algorithm,
    estimated_ratio: f64,
    
    pub fn isHighlyCompressible(self: CompressibilityAnalysis) bool
    pub fn isRandomData(self: CompressibilityAnalysis) bool
    pub fn getBestAlgorithm(self: CompressibilityAnalysis) Algorithm
};
```

#### Compressibility Analysis Example

```zig
pub fn compressibilityAnalysisExample() !void {
    const test_cases = [_]struct { name: []const u8, data: []const u8 }{
        .{ .name = "Repetitive", .data = "AAAAAAAAAA" ** 1000 },
        .{ .name = "Text", .data = "The quick brown fox jumps over the lazy dog. " ** 100 },
        .{ .name = "Random", .data = &[_]u8{0x12, 0x34, 0x56, 0x78, 0x9A, 0xBC, 0xDE, 0xF0} ** 1000 },
    };
    
    for (test_cases) |test_case| {
        const analysis = archive.utils.analyzeCompressibility(test_case.data);
        
        std.debug.print("Data: {s}\n", .{test_case.name});
        std.debug.print("  Entropy: {d:.3}\n", .{analysis.entropy});
        std.debug.print("  Repetition ratio: {d:.3}\n", .{analysis.repetition_ratio});
        std.debug.print("  Pattern score: {d:.3}\n", .{analysis.pattern_score});
        std.debug.print("  Recommended: {s}\n", .{@tagName(analysis.recommended_algorithm)});
        std.debug.print("  Estimated ratio: {d:.1}%\n", .{analysis.estimated_ratio * 100});
        std.debug.print("  Highly compressible: {}\n", .{analysis.isHighlyCompressible()});
        std.debug.print("  Random data: {}\n", .{analysis.isRandomData()});
        std.debug.print("\n", .{});
    }
}
```

## File System Utilities

### Directory Operations

```zig
pub fn walkDirectory(allocator: std.mem.Allocator, path: []const u8, config: WalkConfig) ![][]const u8
pub fn filterPaths(allocator: std.mem.Allocator, paths: []const []const u8, rules: []const FilterRule) ![][]const u8
pub fn getFileSize(path: []const u8) !usize
pub fn getFileInfo(path: []const u8) !FileInfo
```

#### Directory Walking

```zig
pub const WalkConfig = struct {
    recursive: bool = true,
    follow_symlinks: bool = false,
    max_depth: ?usize = null,
    include_directories: bool = false,
    include_hidden: bool = false,
};

pub fn directoryWalkExample(allocator: std.mem.Allocator) !void {
    const config = archive.utils.WalkConfig{
        .recursive = true,
        .max_depth = 3,
        .include_directories = false,
        .include_hidden = false,
    };
    
    const files = try archive.utils.walkDirectory(allocator, "src", config);
    defer {
        for (files) |file| {
            allocator.free(file);
        }
        allocator.free(files);
    }
    
    std.debug.print("Found {d} files:\n", .{files.len});
    for (files) |file| {
        std.debug.print("  {s}\n", .{file});
    }
}
```

#### Path Filtering

```zig
pub fn pathFilteringExample(allocator: std.mem.Allocator) !void {
    const all_paths = [_][]const u8{
        "src/main.zig",
        "src/utils.zig",
        "tests/test.zig",
        "build.zig",
        "temp.tmp",
        "cache.cache",
        "docs/readme.md",
    };
    
    const filter_rules = [_]archive.FilterRule{
        .{ .pattern = "*.zig", .is_directory = false, .case_sensitive = true, .is_recursive = false },
        .{ .pattern = "*.md", .is_directory = false, .case_sensitive = true, .is_recursive = false },
    };
    
    // Convert to owned strings for filtering
    var owned_paths = try allocator.alloc([]const u8, all_paths.len);
    defer allocator.free(owned_paths);
    
    for (all_paths, 0..) |path, i| {
        owned_paths[i] = try allocator.dupe(u8, path);
    }
    defer {
        for (owned_paths) |path| {
            allocator.free(path);
        }
    }
    
    const filtered = try archive.utils.filterPaths(allocator, owned_paths, &filter_rules);
    defer {
        for (filtered) |path| {
            allocator.free(path);
        }
        allocator.free(filtered);
    }
    
    std.debug.print("Filtered paths:\n", .{});
    for (filtered) |path| {
        std.debug.print("  {s}\n", .{path});
    }
}
```

### FileInfo

```zig
pub const FileInfo = struct {
    size: usize,
    is_directory: bool,
    is_symlink: bool,
    modified_time: i64,
    permissions: u32,
    
    pub fn isReadable(self: FileInfo) bool
    pub fn isWritable(self: FileInfo) bool
    pub fn isExecutable(self: FileInfo) bool
};
```

#### File Information Example

```zig
pub fn fileInfoExample() !void {
    const files = [_][]const u8{ "src/main.zig", "build.zig", "README.md" };
    
    for (files) |file_path| {
        if (archive.utils.getFileInfo(file_path)) |info| {
            std.debug.print("File: {s}\n", .{file_path});
            std.debug.print("  Size: {d} bytes\n", .{info.size});
            std.debug.print("  Directory: {}\n", .{info.is_directory});
            std.debug.print("  Symlink: {}\n", .{info.is_symlink});
            std.debug.print("  Readable: {}\n", .{info.isReadable()});
            std.debug.print("  Writable: {}\n", .{info.isWritable()});
            std.debug.print("\n", .{});
        } else |err| {
            std.debug.print("Error getting info for {s}: {}\n", .{ file_path, err });
        }
    }
}
```

## Data Analysis Utilities

### Entropy Calculation

```zig
pub fn calculateEntropy(data: []const u8) f64
pub fn calculateByteFrequency(data: []const u8) [256]f64
pub fn detectPatterns(data: []const u8) PatternAnalysis
```

#### Entropy Analysis

```zig
pub fn entropyAnalysisExample() !void {
    const test_cases = [_]struct { name: []const u8, data: []const u8 }{
        .{ .name = "All zeros", .data = &([_]u8{0} ** 1000) },
        .{ .name = "Alternating", .data = &([_]u8{ 0, 1 } ** 500) },
        .{ .name = "Random", .data = "abcdefghijklmnopqrstuvwxyz" ** 40 },
        .{ .name = "Text", .data = "The quick brown fox jumps over the lazy dog. " ** 20 },
    };
    
    for (test_cases) |test_case| {
        const entropy = archive.utils.calculateEntropy(test_case.data);
        std.debug.print("{s}: entropy = {d:.3}\n", .{ test_case.name, entropy });
    }
}
```

#### Byte Frequency Analysis

```zig
pub fn byteFrequencyExample() !void {
    const text = "Hello, World! This is a test string for frequency analysis.";
    const frequencies = archive.utils.calculateByteFrequency(text);
    
    std.debug.print("Byte frequency analysis:\n", .{});
    for (frequencies, 0..) |freq, byte| {
        if (freq > 0.0) {
            const char = if (byte >= 32 and byte <= 126) @as(u8, @intCast(byte)) else '?';
            std.debug.print("  '{c}' (0x{X:0>2}): {d:.3}\n", .{ char, byte, freq });
        }
    }
}
```

### PatternAnalysis

```zig
pub const PatternAnalysis = struct {
    repetition_count: usize,
    longest_run: usize,
    pattern_length: usize,
    complexity_score: f64,
    
    pub fn hasRepeatingPatterns(self: PatternAnalysis) bool
    pub fn isHighlyStructured(self: PatternAnalysis) bool
    pub fn getComplexityLevel(self: PatternAnalysis) ComplexityLevel
};

pub const ComplexityLevel = enum {
    very_low,
    low,
    medium,
    high,
    very_high,
};
```

#### Pattern Detection Example

```zig
pub fn patternDetectionExample() !void {
    const test_cases = [_]struct { name: []const u8, data: []const u8 }{
        .{ .name = "Repeating pattern", .data = "ABCABC" ** 100 },
        .{ .name = "Long runs", .data = "A" ** 500 ++ "B" ** 500 },
        .{ .name = "Complex text", .data = "The quick brown fox jumps over the lazy dog. " ** 10 },
        .{ .name = "Binary data", .data = &[_]u8{ 0x00, 0xFF, 0x55, 0xAA } ** 250 },
    };
    
    for (test_cases) |test_case| {
        const analysis = archive.utils.detectPatterns(test_case.data);
        
        std.debug.print("{s}:\n", .{test_case.name});
        std.debug.print("  Repetition count: {d}\n", .{analysis.repetition_count});
        std.debug.print("  Longest run: {d}\n", .{analysis.longest_run});
        std.debug.print("  Pattern length: {d}\n", .{analysis.pattern_length});
        std.debug.print("  Complexity: {d:.3} ({})\n", .{ analysis.complexity_score, analysis.getComplexityLevel() });
        std.debug.print("  Has patterns: {}\n", .{analysis.hasRepeatingPatterns()});
        std.debug.print("  Highly structured: {}\n", .{analysis.isHighlyStructured()});
        std.debug.print("\n", .{});
    }
}
```

## Memory Utilities

### Memory Management Helpers

```zig
pub fn alignedAlloc(allocator: std.mem.Allocator, size: usize, alignment: usize) ![]u8
pub fn alignedFree(allocator: std.mem.Allocator, memory: []u8) void
pub fn getMemoryUsage() usize
pub fn getPageSize() usize
```

#### Aligned Memory Example

```zig
pub fn alignedMemoryExample(allocator: std.mem.Allocator) !void {
    const page_size = archive.utils.getPageSize();
    std.debug.print("System page size: {d} bytes\n", .{page_size});
    
    // Allocate page-aligned memory
    const aligned_memory = try archive.utils.alignedAlloc(allocator, 64 * 1024, page_size);
    defer archive.utils.alignedFree(allocator, aligned_memory);
    
    std.debug.print("Allocated {d} bytes aligned to {d} bytes\n", .{ aligned_memory.len, page_size });
    std.debug.print("Memory address: 0x{X}\n", .{@intFromPtr(aligned_memory.ptr)});
    std.debug.print("Aligned: {}\n", .{@intFromPtr(aligned_memory.ptr) % page_size == 0});
}
```

## String Utilities

### String Processing

```zig
pub fn escapeString(allocator: std.mem.Allocator, input: []const u8) ![]u8
pub fn unescapeString(allocator: std.mem.Allocator, input: []const u8) ![]u8
pub fn formatBytes(allocator: std.mem.Allocator, bytes: usize) ![]u8
pub fn parseSize(input: []const u8) !usize
```

#### String Utility Examples

```zig
pub fn stringUtilityExample(allocator: std.mem.Allocator) !void {
    // Format bytes
    const sizes = [_]usize{ 1024, 1048576, 1073741824, 1099511627776 };
    
    for (sizes) |size| {
        const formatted = try archive.utils.formatBytes(allocator, size);
        defer allocator.free(formatted);
        std.debug.print("{d} bytes = {s}\n", .{ size, formatted });
    }
    
    // Parse sizes
    const size_strings = [_][]const u8{ "1KB", "1MB", "1GB", "1TB" };
    
    for (size_strings) |size_str| {
        if (archive.utils.parseSize(size_str)) |parsed| {
            std.debug.print("{s} = {d} bytes\n", .{ size_str, parsed });
        } else |err| {
            std.debug.print("Failed to parse {s}: {}\n", .{ size_str, err });
        }
    }
}
```

## Checksum Utilities

### Checksum Calculation

```zig
pub fn calculateCRC32(data: []const u8) u32
pub fn calculateAdler32(data: []const u8) u32
pub fn calculateMD5(data: []const u8) [16]u8
pub fn calculateSHA256(data: []const u8) [32]u8
pub fn verifyChecksum(data: []const u8, expected: []const u8, algorithm: ChecksumAlgorithm) bool
```

#### Checksum Examples

```zig
pub fn checksumExample() !void {
    const test_data = "Hello, Archive.zig! This is test data for checksum calculation.";
    
    const crc32 = archive.utils.calculateCRC32(test_data);
    const adler32 = archive.utils.calculateAdler32(test_data);
    const md5 = archive.utils.calculateMD5(test_data);
    const sha256 = archive.utils.calculateSHA256(test_data);
    
    std.debug.print("Checksums for: {s}\n", .{test_data});
    std.debug.print("CRC32: 0x{X:0>8}\n", .{crc32});
    std.debug.print("Adler32: 0x{X:0>8}\n", .{adler32});
    
    std.debug.print("MD5: ", .{});
    for (md5) |byte| {
        std.debug.print("{X:0>2}", .{byte});
    }
    std.debug.print("\n", .{});
    
    std.debug.print("SHA256: ", .{});
    for (sha256) |byte| {
        std.debug.print("{X:0>2}", .{byte});
    }
    std.debug.print("\n", .{});
}
```

## Error Utilities

### Error Handling Helpers

```zig
pub fn errorToString(err: anyerror) []const u8
pub fn isRecoverableError(err: anyerror) bool
pub fn suggestSolution(err: anyerror) ?[]const u8
```

#### Error Utility Example

```zig
pub fn errorUtilityExample() !void {
    const errors = [_]anyerror{
        error.OutOfMemory,
        error.FileNotFound,
        error.AccessDenied,
        error.CorruptedStream,
        error.UnsupportedAlgorithm,
    };
    
    for (errors) |err| {
        const error_str = archive.utils.errorToString(err);
        const recoverable = archive.utils.isRecoverableError(err);
        const solution = archive.utils.suggestSolution(err);
        
        std.debug.print("Error: {s}\n", .{error_str});
        std.debug.print("  Recoverable: {}\n", .{recoverable});
        if (solution) |sol| {
            std.debug.print("  Suggestion: {s}\n", .{sol});
        }
        std.debug.print("\n", .{});
    }
}
```

## Best Practices

### Utility Guidelines

1. **Validate inputs early** - Use path validation before operations
2. **Analyze data first** - Use compressibility analysis to choose algorithms
3. **Use appropriate patterns** - Compile globs for repeated matching
4. **Handle errors gracefully** - Use error utilities for better messages
5. **Monitor memory usage** - Use memory utilities for optimization
6. **Verify data integrity** - Use checksum utilities for validation
7. **Optimize for platform** - Use aligned memory and page sizes

### Common Utility Patterns

```zig
// Validate and normalize path before use
const normalized_path = if (archive.utils.validatePath(input_path))
    try archive.utils.normalizePath(allocator, input_path)
else
    return error.InvalidPath;
defer allocator.free(normalized_path);

// Analyze data before compression
const analysis = archive.utils.analyzeCompressibility(data);
const algorithm = analysis.getBestAlgorithm();
const config = archive.CompressionConfig.init(algorithm);

// Use compiled glob for multiple matches
var matcher = try archive.utils.compileGlob(allocator, "*.zig");
defer matcher.deinit();

for (file_list) |file| {
    if (matcher.matchPath(file)) {
        // Process matching file
    }
}
```

## Next Steps

- Learn about [Constants](./constants.md) for utility constants
- Explore [Errors](./errors.md) for error handling utilities
- Check [Archive](./archive.md) for main API functions
- See [Examples](../examples/basic.md) for practical utility usage