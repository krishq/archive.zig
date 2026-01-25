# Errors API

The Errors API defines all error types, error handling utilities, and recovery strategies used throughout Archive.zig.

## Core Error Types

### CompressError

```zig
pub const CompressError = error{
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
    CompressionFailed,
    DecompressionFailed,
    BufferTooSmall,
    InvalidConfiguration,
    FileNotFound,
    AccessDenied,
    NoSpaceLeft,
    FileTooBig,
    InvalidPath,
    PermissionDenied,
    NetworkError,
    TimeoutError,
    ResourceExhausted,
};
```

## Error Categories

### Memory Errors

```zig
pub const MemoryError = error{
    OutOfMemory,
    BufferTooSmall,
    ResourceExhausted,
};
```

**Description**: Errors related to memory allocation and buffer management.

**Common Causes**:
- Insufficient system memory
- Buffer size too small for operation
- Memory fragmentation
- Resource limits exceeded

**Recovery Strategies**:
- Use smaller buffer sizes
- Try streaming operations
- Free unused memory
- Use memory-efficient algorithms

### Data Errors

```zig
pub const DataError = error{
    InvalidData,
    InvalidMagic,
    CorruptedStream,
    ChecksumMismatch,
    InvalidOffset,
};
```

**Description**: Errors related to data integrity and format validation.

**Common Causes**:
- Corrupted input data
- Wrong compression format
- Network transmission errors
- Incomplete data transfer

**Recovery Strategies**:
- Verify data integrity
- Try alternative algorithms
- Re-download or re-read data
- Use error correction if available

### Algorithm Errors

```zig
pub const AlgorithmError = error{
    UnsupportedAlgorithm,
    UnsupportedCompressionMethod,
    ZstdError,
    CompressionFailed,
    DecompressionFailed,
};
```

**Description**: Errors specific to compression algorithms.

**Common Causes**:
- Algorithm not available on platform
- Invalid algorithm parameters
- Algorithm-specific failures
- Unsupported compression method

**Recovery Strategies**:
- Try alternative algorithms
- Adjust algorithm parameters
- Check platform support
- Use fallback compression

### File System Errors

```zig
pub const FileSystemError = error{
    FileNotFound,
    AccessDenied,
    NoSpaceLeft,
    FileTooBig,
    InvalidPath,
    PermissionDenied,
};
```

**Description**: Errors related to file system operations.

**Common Causes**:
- Missing files or directories
- Insufficient permissions
- Disk space exhausted
- Invalid file paths

**Recovery Strategies**:
- Check file existence
- Verify permissions
- Free disk space
- Validate file paths

### Configuration Errors

```zig
pub const ConfigurationError = error{
    InvalidConfiguration,
    InvalidLevel,
    InvalidBufferSize,
    InvalidMemoryLevel,
    InvalidWindowSize,
    InvalidZstdLevel,
    InvalidLz4Level,
};
```

**Description**: Errors related to configuration validation.

**Common Causes**:
- Invalid parameter values
- Conflicting settings
- Out-of-range values
- Unsupported combinations

**Recovery Strategies**:
- Use default values
- Validate parameters
- Check supported ranges
- Use configuration presets

## Error Information

### ErrorInfo Structure

```zig
pub const ErrorInfo = struct {
    error_type: CompressError,
    message: []const u8,
    category: ErrorCategory,
    severity: ErrorSeverity,
    recoverable: bool,
    suggestion: ?[]const u8,
    
    pub fn init(err: CompressError) ErrorInfo
    pub fn withMessage(self: ErrorInfo, message: []const u8) ErrorInfo
    pub fn withSuggestion(self: ErrorInfo, suggestion: []const u8) ErrorInfo
};
```

### ErrorCategory Enum

```zig
pub const ErrorCategory = enum {
    memory,
    data,
    algorithm,
    filesystem,
    configuration,
    network,
    system,
    unknown,
    
    pub fn fromError(err: CompressError) ErrorCategory
    pub fn getDescription(self: ErrorCategory) []const u8
};
```

### ErrorSeverity Enum

```zig
pub const ErrorSeverity = enum {
    low,      // Warning, operation can continue
    medium,   // Error, but recoverable
    high,     // Serious error, operation failed
    critical, // Critical error, system unstable
    
    pub fn fromError(err: CompressError) ErrorSeverity
    pub fn getDescription(self: ErrorSeverity) []const u8
};
```

## Error Utilities

### Error Analysis

```zig
pub fn analyzeError(err: CompressError) ErrorInfo
pub fn getErrorMessage(err: CompressError) []const u8
pub fn getErrorCategory(err: CompressError) ErrorCategory
pub fn getErrorSeverity(err: CompressError) ErrorSeverity
pub fn isRecoverable(err: CompressError) bool
pub fn getSuggestion(err: CompressError) ?[]const u8
```

#### Error Analysis Example

```zig
const std = @import("std");
const archive = @import("archive");

pub fn errorAnalysisExample() !void {
    const test_errors = [_]archive.CompressError{
        error.OutOfMemory,
        error.InvalidData,
        error.FileNotFound,
        error.UnsupportedAlgorithm,
        error.CorruptedStream,
    };
    
    for (test_errors) |err| {
        const info = archive.errors.analyzeError(err);
        
        std.debug.print("Error: {}\n", .{err});
        std.debug.print("  Message: {s}\n", .{info.message});
        std.debug.print("  Category: {s}\n", .{@tagName(info.category)});
        std.debug.print("  Severity: {s}\n", .{@tagName(info.severity)});
        std.debug.print("  Recoverable: {}\n", .{info.recoverable});
        if (info.suggestion) |suggestion| {
            std.debug.print("  Suggestion: {s}\n", .{suggestion});
        }
        std.debug.print("\n", .{});
    }
}
```

### Error Context

```zig
pub const ErrorContext = struct {
    operation: []const u8,
    file_path: ?[]const u8,
    algorithm: ?archive.Algorithm,
    offset: ?usize,
    additional_info: ?[]const u8,
    
    pub fn init(operation: []const u8) ErrorContext
    pub fn withFile(self: ErrorContext, file_path: []const u8) ErrorContext
    pub fn withAlgorithm(self: ErrorContext, algorithm: archive.Algorithm) ErrorContext
    pub fn withOffset(self: ErrorContext, offset: usize) ErrorContext
    pub fn withInfo(self: ErrorContext, info: []const u8) ErrorContext
    pub fn format(self: ErrorContext, allocator: std.mem.Allocator, err: CompressError) ![]u8
};
```

#### Error Context Example

```zig
pub fn errorContextExample(allocator: std.mem.Allocator) !void {
    const context = archive.errors.ErrorContext.init("file compression")
        .withFile("large_file.txt")
        .withAlgorithm(.zstd)
        .withOffset(1024 * 1024)
        .withInfo("Processing 1MB chunk");
    
    const err = error.OutOfMemory;
    const formatted = try context.format(allocator, err);
    defer allocator.free(formatted);
    
    std.debug.print("Formatted error: {s}\n", .{formatted});
    // Output: "OutOfMemory during file compression of 'large_file.txt' using zstd at offset 1048576: Processing 1MB chunk"
}
```

## Error Recovery

### Recovery Strategies

```zig
pub const RecoveryStrategy = enum {
    retry,
    fallback_algorithm,
    reduce_memory,
    use_streaming,
    skip_file,
    abort_operation,
    
    pub fn fromError(err: CompressError, context: ErrorContext) RecoveryStrategy
    pub fn getDescription(self: RecoveryStrategy) []const u8
};

pub fn getRecoveryStrategy(err: CompressError, context: ErrorContext) RecoveryStrategy
pub fn executeRecovery(strategy: RecoveryStrategy, context: ErrorContext) !void
```

#### Recovery Strategy Example

```zig
pub fn recoveryStrategyExample(allocator: std.mem.Allocator) !void {
    const context = archive.errors.ErrorContext.init("compression")
        .withAlgorithm(.zstd);
    
    const err = error.OutOfMemory;
    const strategy = archive.errors.getRecoveryStrategy(err, context);
    
    std.debug.print("Error: {}\n", .{err});
    std.debug.print("Recommended strategy: {s}\n", .{@tagName(strategy)});
    std.debug.print("Description: {s}\n", .{strategy.getDescription()});
    
    // Execute recovery based on strategy
    switch (strategy) {
        .fallback_algorithm => {
            std.debug.print("Trying LZ4 as fallback...\n", .{});
            // Try compression with LZ4
        },
        .reduce_memory => {
            std.debug.print("Reducing buffer size...\n", .{});
            // Use smaller buffer
        },
        .use_streaming => {
            std.debug.print("Switching to streaming mode...\n", .{});
            // Use streaming compression
        },
        else => {
            std.debug.print("No automatic recovery available\n", .{});
        },
    }
}
```

### Automatic Recovery

```zig
pub const RecoveryConfig = struct {
    max_retries: u32 = 3,
    retry_delay_ms: u32 = 100,
    enable_fallback: bool = true,
    enable_streaming: bool = true,
    enable_memory_reduction: bool = true,
    
    pub fn default() RecoveryConfig
    pub fn conservative() RecoveryConfig
    pub fn aggressive() RecoveryConfig
};

pub fn attemptRecovery(
    allocator: std.mem.Allocator,
    operation: anytype,
    context: ErrorContext,
    config: RecoveryConfig
) !@TypeOf(operation())
```

#### Automatic Recovery Example

```zig
pub fn automaticRecoveryExample(allocator: std.mem.Allocator, data: []const u8) ![]u8 {
    const context = archive.errors.ErrorContext.init("data compression")
        .withAlgorithm(.zstd);
    
    const config = archive.errors.RecoveryConfig{
        .max_retries = 3,
        .enable_fallback = true,
        .enable_streaming = true,
    };
    
    // Define the operation to retry
    const Operation = struct {
        data: []const u8,
        allocator: std.mem.Allocator,
        algorithm: archive.Algorithm,
        
        pub fn call(self: @This()) ![]u8 {
            return archive.compress(self.allocator, self.data, self.algorithm);
        }
    };
    
    var operation = Operation{
        .data = data,
        .allocator = allocator,
        .algorithm = .zstd,
    };
    
    return archive.errors.attemptRecovery(allocator, operation.call, context, config);
}
```

## Error Reporting

### Error Reporter

```zig
pub const ErrorReporter = struct {
    allocator: std.mem.Allocator,
    log_file: ?std.fs.File,
    console_output: bool,
    detailed_logging: bool,
    
    pub fn init(allocator: std.mem.Allocator, log_path: ?[]const u8) !ErrorReporter
    pub fn deinit(self: *ErrorReporter) void
    pub fn reportError(self: *ErrorReporter, err: CompressError, context: ErrorContext) !void
    pub fn reportWarning(self: *ErrorReporter, message: []const u8, context: ErrorContext) !void
    pub fn reportInfo(self: *ErrorReporter, message: []const u8) !void
    pub fn getErrorCount(self: *ErrorReporter) usize
    pub fn getWarningCount(self: *ErrorReporter) usize
};
```

#### Error Reporter Example

```zig
pub fn errorReporterExample(allocator: std.mem.Allocator) !void {
    var reporter = try archive.errors.ErrorReporter.init(allocator, "compression.log");
    defer reporter.deinit();
    
    // Report various types of issues
    const context1 = archive.errors.ErrorContext.init("file compression")
        .withFile("test.txt")
        .withAlgorithm(.gzip);
    
    try reporter.reportError(error.FileNotFound, context1);
    
    const context2 = archive.errors.ErrorContext.init("memory allocation")
        .withInfo("Large buffer requested");
    
    try reporter.reportWarning("Memory usage is high", context2);
    
    try reporter.reportInfo("Compression operation completed");
    
    std.debug.print("Errors: {d}, Warnings: {d}\n", .{ 
        reporter.getErrorCount(), 
        reporter.getWarningCount() 
    });
}
```

## Error Handling Patterns

### Basic Error Handling

```zig
pub fn basicErrorHandling(allocator: std.mem.Allocator, data: []const u8) ![]u8 {
    return archive.compress(allocator, data, .gzip) catch |err| switch (err) {
        error.OutOfMemory => {
            std.debug.print("Not enough memory for compression\n", .{});
            return err;
        },
        error.InvalidData => {
            std.debug.print("Input data is invalid\n", .{});
            return err;
        },
        error.UnsupportedAlgorithm => {
            std.debug.print("Gzip not supported on this platform\n", .{});
            return err;
        },
        else => {
            std.debug.print("Unexpected error: {}\n", .{err});
            return err;
        },
    };
}
```

### Comprehensive Error Handling

```zig
pub fn comprehensiveErrorHandling(allocator: std.mem.Allocator, data: []const u8, algorithm: archive.Algorithm) ![]u8 {
    const context = archive.errors.ErrorContext.init("data compression")
        .withAlgorithm(algorithm);
    
    return archive.compress(allocator, data, algorithm) catch |err| {
        const info = archive.errors.analyzeError(err);
        const strategy = archive.errors.getRecoveryStrategy(err, context);
        
        std.debug.print("Error occurred: {}\n", .{err});
        std.debug.print("Category: {s}\n", .{@tagName(info.category)});
        std.debug.print("Severity: {s}\n", .{@tagName(info.severity)});
        std.debug.print("Recoverable: {}\n", .{info.recoverable});
        
        if (info.suggestion) |suggestion| {
            std.debug.print("Suggestion: {s}\n", .{suggestion});
        }
        
        // Attempt recovery based on strategy
        switch (strategy) {
            .fallback_algorithm => {
                std.debug.print("Trying fallback algorithm (LZ4)...\n", .{});
                return archive.compress(allocator, data, .lz4) catch |fallback_err| {
                    std.debug.print("Fallback also failed: {}\n", .{fallback_err});
                    return fallback_err;
                };
            },
            .reduce_memory => {
                std.debug.print("Trying with reduced memory usage...\n", .{});
                const config = archive.CompressionConfig.init(algorithm)
                    .withBufferSize(16 * 1024)  // Smaller buffer
                    .withMemoryLevel(4);        // Lower memory level
                
                return archive.compressWithConfig(allocator, data, config) catch |reduced_err| {
                    std.debug.print("Reduced memory approach failed: {}\n", .{reduced_err});
                    return reduced_err;
                };
            },
            .use_streaming => {
                std.debug.print("Trying streaming compression...\n", .{});
                // Implement streaming fallback
                return error.StreamingNotImplemented;
            },
            else => {
                std.debug.print("No recovery strategy available\n", .{});
                return err;
            },
        }
    };
}
```

### Error Aggregation

```zig
pub const ErrorAggregator = struct {
    errors: std.ArrayList(ErrorEntry),
    allocator: std.mem.Allocator,
    
    const ErrorEntry = struct {
        error_type: CompressError,
        context: ErrorContext,
        timestamp: i64,
        count: usize,
    };
    
    pub fn init(allocator: std.mem.Allocator) ErrorAggregator
    pub fn deinit(self: *ErrorAggregator) void
    pub fn addError(self: *ErrorAggregator, err: CompressError, context: ErrorContext) !void
    pub fn getErrorSummary(self: *ErrorAggregator) ErrorSummary
    pub fn getMostCommonError(self: *ErrorAggregator) ?ErrorEntry
    pub fn clear(self: *ErrorAggregator) void
};

pub const ErrorSummary = struct {
    total_errors: usize,
    unique_errors: usize,
    most_common: ?CompressError,
    error_rate: f64,
    categories: std.HashMap(ErrorCategory, usize, std.hash_map.AutoContext(ErrorCategory), std.hash_map.default_max_load_percentage),
};
```

#### Error Aggregation Example

```zig
pub fn errorAggregationExample(allocator: std.mem.Allocator) !void {
    var aggregator = archive.errors.ErrorAggregator.init(allocator);
    defer aggregator.deinit();
    
    // Simulate multiple errors
    const errors = [_]struct { err: archive.CompressError, file: []const u8 }{
        .{ .err = error.OutOfMemory, .file = "large1.txt" },
        .{ .err = error.FileNotFound, .file = "missing.txt" },
        .{ .err = error.OutOfMemory, .file = "large2.txt" },
        .{ .err = error.InvalidData, .file = "corrupt.txt" },
        .{ .err = error.OutOfMemory, .file = "large3.txt" },
    };
    
    for (errors) |error_info| {
        const context = archive.errors.ErrorContext.init("batch compression")
            .withFile(error_info.file);
        
        try aggregator.addError(error_info.err, context);
    }
    
    const summary = aggregator.getErrorSummary();
    
    std.debug.print("Error Summary:\n", .{});
    std.debug.print("  Total errors: {d}\n", .{summary.total_errors});
    std.debug.print("  Unique errors: {d}\n", .{summary.unique_errors});
    if (summary.most_common) |most_common| {
        std.debug.print("  Most common: {}\n", .{most_common});
    }
    std.debug.print("  Error rate: {d:.2}%\n", .{summary.error_rate * 100});
    
    if (aggregator.getMostCommonError()) |common| {
        std.debug.print("  Most frequent error occurred {d} times\n", .{common.count});
    }
}
```

## Testing Error Conditions

### Error Injection

```zig
pub const ErrorInjector = struct {
    enabled: bool,
    error_rate: f64,
    target_errors: []const CompressError,
    random: std.rand.Random,
    
    pub fn init(random: std.rand.Random, error_rate: f64) ErrorInjector
    pub fn shouldInjectError(self: *ErrorInjector) bool
    pub fn getRandomError(self: *ErrorInjector) CompressError
    pub fn injectError(self: *ErrorInjector, operation: anytype) !@TypeOf(operation())
};
```

#### Error Injection Example

```zig
pub fn errorInjectionExample(allocator: std.mem.Allocator) !void {
    var prng = std.rand.DefaultPrng.init(12345);
    const random = prng.random();
    
    var injector = archive.errors.ErrorInjector.init(random, 0.1); // 10% error rate
    injector.target_errors = &[_]archive.CompressError{ error.OutOfMemory, error.InvalidData };
    injector.enabled = true;
    
    const test_data = "Test data for error injection";
    
    for (0..10) |i| {
        std.debug.print("Attempt {d}: ", .{i + 1});
        
        const result = injector.injectError(struct {
            data: []const u8,
            alloc: std.mem.Allocator,
            
            pub fn call(self: @This()) ![]u8 {
                return archive.compress(self.alloc, self.data, .lz4);
            }
        }{ .data = test_data, .alloc = allocator }.call);
        
        if (result) |compressed| {
            defer allocator.free(compressed);
            std.debug.print("Success ({d} bytes)\n", .{compressed.len});
        } else |err| {
            std.debug.print("Error injected: {}\n", .{err});
        }
    }
}
```

## Best Practices

### Error Handling Guidelines

1. **Handle errors explicitly** - Don't ignore potential failures
2. **Provide context** - Include relevant information with errors
3. **Use appropriate recovery** - Choose recovery strategies based on error type
4. **Log errors properly** - Maintain error logs for debugging
5. **Test error conditions** - Verify error handling works correctly
6. **Fail gracefully** - Provide meaningful error messages to users
7. **Monitor error rates** - Track error patterns in production

### Common Error Patterns

```zig
// Pattern 1: Simple error handling with context
const compressed = archive.compress(allocator, data, .gzip) catch |err| {
    const context = archive.errors.ErrorContext.init("compression").withAlgorithm(.gzip);
    const info = archive.errors.analyzeError(err);
    std.debug.print("Compression failed: {s}\n", .{info.message});
    return err;
};

// Pattern 2: Error handling with recovery
const compressed = archive.compress(allocator, data, .zstd) catch |err| switch (err) {
    error.OutOfMemory => {
        // Try with less memory-intensive algorithm
        return archive.compress(allocator, data, .lz4);
    },
    error.UnsupportedAlgorithm => {
        // Fall back to widely supported algorithm
        return archive.compress(allocator, data, .gzip);
    },
    else => return err,
};

// Pattern 3: Comprehensive error handling with reporting
var reporter = try archive.errors.ErrorReporter.init(allocator, "errors.log");
defer reporter.deinit();

const compressed = archive.compress(allocator, data, .zstd) catch |err| {
    const context = archive.errors.ErrorContext.init("batch processing")
        .withAlgorithm(.zstd)
        .withInfo("Processing user data");
    
    try reporter.reportError(err, context);
    
    const strategy = archive.errors.getRecoveryStrategy(err, context);
    // Execute recovery strategy...
    
    return err;
};
```

## Next Steps

- Learn about [Utils](./utils.md) for error utility functions
- Explore [Constants](./constants.md) for error constants
- Check [Archive](./archive.md) for main API error handling
- See [Examples](../examples/basic.md) for practical error handling patterns