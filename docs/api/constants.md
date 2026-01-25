# Constants API

The Constants API provides algorithm-specific constants, limits, and configuration values used throughout Archive.zig.

## Core Constants

### General Constants

```zig
pub const Constants = struct {
    pub const DEFAULT_BUFFER_SIZE: usize = 64 * 1024;
    pub const MIN_BUFFER_SIZE: usize = 1024;
    pub const MAX_BUFFER_SIZE: usize = 16 * 1024 * 1024;
    pub const DEFAULT_MEMORY_LEVEL: u8 = 6;
    pub const MIN_MEMORY_LEVEL: u8 = 1;
    pub const MAX_MEMORY_LEVEL: u8 = 9;
    pub const DEFAULT_WINDOW_SIZE: u32 = 32768;
    pub const MIN_WINDOW_SIZE: u32 = 256;
    pub const MAX_WINDOW_SIZE: u32 = 32768;
};
```

### Compression Level Constants

```zig
pub const LevelConstants = struct {
    pub const FASTEST_LEVEL: u8 = 1;
    pub const FAST_LEVEL: u8 = 3;
    pub const DEFAULT_LEVEL: u8 = 6;
    pub const BEST_LEVEL: u8 = 9;
    pub const MIN_LEVEL: u8 = 0;
    pub const MAX_LEVEL: u8 = 9;
};
```

## Algorithm-Specific Constants

### ZSTD Constants

```zig
pub const ZstdConstants = struct {
    pub const MIN_LEVEL: c_int = 1;
    pub const MAX_LEVEL: c_int = 22;
    pub const DEFAULT_LEVEL: c_int = 3;
    pub const ULTRA_MIN_LEVEL: c_int = 20;
    pub const ULTRA_MAX_LEVEL: c_int = 22;
    
    // Window log constants
    pub const MIN_WINDOW_LOG: c_int = 10;
    pub const MAX_WINDOW_LOG: c_int = 31;
    pub const DEFAULT_WINDOW_LOG: c_int = 22;
    
    // Hash log constants
    pub const MIN_HASH_LOG: c_int = 6;
    pub const MAX_HASH_LOG: c_int = 26;
    pub const DEFAULT_HASH_LOG: c_int = 20;
    
    // Chain log constants
    pub const MIN_CHAIN_LOG: c_int = 6;
    pub const MAX_CHAIN_LOG: c_int = 28;
    pub const DEFAULT_CHAIN_LOG: c_int = 16;
    
    // Search log constants
    pub const MIN_SEARCH_LOG: c_int = 1;
    pub const MAX_SEARCH_LOG: c_int = 26;
    pub const DEFAULT_SEARCH_LOG: c_int = 8;
    
    // Target length constants
    pub const MIN_TARGET_LENGTH: c_int = 4;
    pub const MAX_TARGET_LENGTH: c_int = 999;
    pub const DEFAULT_TARGET_LENGTH: c_int = 64;
    
    // LDM (Long Distance Matching) constants
    pub const LDM_MIN_MEMORY: c_int = 10;
    pub const LDM_MAX_MEMORY: c_int = 23;
    pub const LDM_DEFAULT_MEMORY: c_int = 20;
    
    pub const LDM_MIN_HASH_RATE_LOG: c_int = 0;
    pub const LDM_MAX_HASH_RATE_LOG: c_int = 16;
    pub const LDM_DEFAULT_HASH_RATE_LOG: c_int = 8;
    
    // Magic number
    pub const MAGIC_NUMBER: u32 = 0xFD2FB528;
    pub const MAGIC_BYTES: [4]u8 = [_]u8{ 0x28, 0xB5, 0x2F, 0xFD };
    
    // Frame constants
    pub const FRAME_HEADER_SIZE_MIN: usize = 6;
    pub const FRAME_HEADER_SIZE_MAX: usize = 18;
    pub const BLOCK_HEADER_SIZE: usize = 3;
    pub const BLOCK_SIZE_MAX: usize = 128 * 1024;
    
    // Dictionary constants
    pub const DICT_SIZE_MIN: usize = 256;
    pub const DICT_SIZE_MAX: usize = 2 * 1024 * 1024;
};
```

### LZ4 Constants

```zig
pub const Lz4Constants = struct {
    pub const MIN_LEVEL: c_int = 1;
    pub const MAX_LEVEL: c_int = 12;
    pub const DEFAULT_LEVEL: c_int = 1;
    pub const ACCELERATION_DEFAULT: c_int = 1;
    pub const ACCELERATION_MAX: c_int = 65537;
    
    // Magic number
    pub const MAGIC_NUMBER: u32 = 0x184D2204;
    pub const MAGIC_BYTES: [4]u8 = [_]u8{ 0x04, 0x22, 0x4D, 0x18 };
    
    // Frame constants
    pub const FRAME_HEADER_SIZE: usize = 7;
    pub const FRAME_HEADER_SIZE_MAX: usize = 19;
    pub const BLOCK_HEADER_SIZE: usize = 4;
    
    // Block size constants
    pub const BLOCK_SIZE_64KB: u32 = 64 * 1024;
    pub const BLOCK_SIZE_256KB: u32 = 256 * 1024;
    pub const BLOCK_SIZE_1MB: u32 = 1024 * 1024;
    pub const BLOCK_SIZE_4MB: u32 = 4 * 1024 * 1024;
    pub const BLOCK_SIZE_DEFAULT: u32 = BLOCK_SIZE_64KB;
    
    // Dictionary constants
    pub const DICT_SIZE_MIN: usize = 4;
    pub const DICT_SIZE_MAX: usize = 64 * 1024;
};
```

### Gzip Constants

```zig
pub const GzipConstants = struct {
    pub const MAGIC_BYTES: [2]u8 = [_]u8{ 0x1F, 0x8B };
    pub const HEADER_SIZE_MIN: usize = 10;
    pub const HEADER_SIZE_MAX: usize = 255;
    pub const FOOTER_SIZE: usize = 8;
    
    // Compression methods
    pub const METHOD_DEFLATE: u8 = 8;
    
    // Flags
    pub const FLAG_TEXT: u8 = 0x01;
    pub const FLAG_CRC: u8 = 0x02;
    pub const FLAG_EXTRA: u8 = 0x04;
    pub const FLAG_NAME: u8 = 0x08;
    pub const FLAG_COMMENT: u8 = 0x10;
    
    // Operating system constants
    pub const OS_FAT: u8 = 0;
    pub const OS_AMIGA: u8 = 1;
    pub const OS_VMS: u8 = 2;
    pub const OS_UNIX: u8 = 3;
    pub const OS_VM_CMS: u8 = 4;
    pub const OS_ATARI_TOS: u8 = 5;
    pub const OS_HPFS: u8 = 6;
    pub const OS_MACINTOSH: u8 = 7;
    pub const OS_Z_SYSTEM: u8 = 8;
    pub const OS_CP_M: u8 = 9;
    pub const OS_TOPS_20: u8 = 10;
    pub const OS_NTFS: u8 = 11;
    pub const OS_QDOS: u8 = 12;
    pub const OS_ACORN_RISCOS: u8 = 13;
    pub const OS_UNKNOWN: u8 = 255;
};
```

### Zlib Constants

```zig
pub const ZlibConstants = struct {
    pub const HEADER_SIZE: usize = 2;
    pub const FOOTER_SIZE: usize = 4;
    
    // Compression methods
    pub const METHOD_DEFLATE: u8 = 8;
    
    // Compression info (window size)
    pub const CINFO_32K: u8 = 7; // 2^(7+8) = 32KB window
    
    // Flags
    pub const FCHECK_MASK: u8 = 0x1F;
    pub const FDICT_FLAG: u8 = 0x20;
    pub const FLEVEL_MASK: u8 = 0xC0;
    pub const FLEVEL_FASTEST: u8 = 0x00;
    pub const FLEVEL_FAST: u8 = 0x40;
    pub const FLEVEL_DEFAULT: u8 = 0x80;
    pub const FLEVEL_SLOWEST: u8 = 0xC0;
    
    // Dictionary constants
    pub const DICT_ID_SIZE: usize = 4;
};
```

### Deflate Constants

```zig
pub const DeflateConstants = struct {
    // Window size constants
    pub const MIN_WINDOW_BITS: u8 = 8;
    pub const MAX_WINDOW_BITS: u8 = 15;
    pub const DEFAULT_WINDOW_BITS: u8 = 15;
    
    // Memory level constants
    pub const MIN_MEM_LEVEL: u8 = 1;
    pub const MAX_MEM_LEVEL: u8 = 9;
    pub const DEFAULT_MEM_LEVEL: u8 = 8;
    
    // Strategy constants
    pub const STRATEGY_DEFAULT: u8 = 0;
    pub const STRATEGY_FILTERED: u8 = 1;
    pub const STRATEGY_HUFFMAN_ONLY: u8 = 2;
    pub const STRATEGY_RLE: u8 = 3;
    pub const STRATEGY_FIXED: u8 = 4;
    
    // Block type constants
    pub const BLOCK_TYPE_STORED: u8 = 0;
    pub const BLOCK_TYPE_FIXED: u8 = 1;
    pub const BLOCK_TYPE_DYNAMIC: u8 = 2;
    
    // Length codes
    pub const LENGTH_CODES: usize = 29;
    pub const LITERALS: usize = 256;
    pub const L_CODES: usize = LITERALS + 1 + LENGTH_CODES;
    pub const D_CODES: usize = 30;
    pub const BL_CODES: usize = 19;
    pub const HEAP_SIZE: usize = 2 * L_CODES + 1;
    pub const MAX_BITS: usize = 15;
};
```

### LZMA Constants

```zig
pub const LzmaConstants = struct {
    pub const MAGIC_BYTES: [3]u8 = [_]u8{ 0x5D, 0x00, 0x00 };
    pub const HEADER_SIZE: usize = 13;
    
    // Dictionary size constants
    pub const DICT_SIZE_MIN: u32 = 4096;
    pub const DICT_SIZE_MAX: u32 = 1 << 27; // 128MB
    pub const DICT_SIZE_DEFAULT: u32 = 1 << 24; // 16MB
    
    // Properties constants
    pub const LC_DEFAULT: u8 = 3; // Literal context bits
    pub const LP_DEFAULT: u8 = 0; // Literal position bits
    pub const PB_DEFAULT: u8 = 2; // Position bits
    
    pub const LC_MAX: u8 = 8;
    pub const LP_MAX: u8 = 4;
    pub const PB_MAX: u8 = 4;
    
    // Match finder constants
    pub const MF_BT2: u8 = 0;
    pub const MF_BT3: u8 = 1;
    pub const MF_BT4: u8 = 2;
    pub const MF_HC4: u8 = 3;
    pub const MF_DEFAULT: u8 = MF_BT4;
    
    // Number of fast bytes
    pub const NUM_FAST_BYTES_MIN: u32 = 5;
    pub const NUM_FAST_BYTES_MAX: u32 = 273;
    pub const NUM_FAST_BYTES_DEFAULT: u32 = 32;
};
```

### XZ Constants

```zig
pub const XzConstants = struct {
    pub const MAGIC_BYTES: [6]u8 = [_]u8{ 0xFD, 0x37, 0x7A, 0x58, 0x5A, 0x00 };
    pub const HEADER_SIZE: usize = 12;
    pub const FOOTER_SIZE: usize = 12;
    
    // Stream flags
    pub const STREAM_HEADER_SIZE: usize = 12;
    pub const STREAM_FOOTER_SIZE: usize = 12;
    pub const BLOCK_HEADER_SIZE_MIN: usize = 8;
    pub const BLOCK_HEADER_SIZE_MAX: usize = 1024;
    
    // Check types
    pub const CHECK_NONE: u8 = 0;
    pub const CHECK_CRC32: u8 = 1;
    pub const CHECK_CRC64: u8 = 4;
    pub const CHECK_SHA256: u8 = 10;
    
    // Filter IDs
    pub const FILTER_LZMA2: u64 = 0x21;
    pub const FILTER_X86: u64 = 0x04;
    pub const FILTER_POWERPC: u64 = 0x05;
    pub const FILTER_IA64: u64 = 0x06;
    pub const FILTER_ARM: u64 = 0x07;
    pub const FILTER_ARMTHUMB: u64 = 0x08;
    pub const FILTER_SPARC: u64 = 0x09;
    
    // Dictionary size constants
    pub const DICT_SIZE_MIN: u32 = 4096;
    pub const DICT_SIZE_MAX: u32 = 1 << 30; // 1GB
    pub const DICT_SIZE_DEFAULT: u32 = 1 << 23; // 8MB
};
```

### ZIP Constants

```zig
pub const ZipConstants = struct {
    // Signatures
    pub const LOCAL_FILE_HEADER_SIGNATURE: u32 = 0x04034b50;
    pub const CENTRAL_DIRECTORY_HEADER_SIGNATURE: u32 = 0x02014b50;
    pub const END_OF_CENTRAL_DIRECTORY_SIGNATURE: u32 = 0x06054b50;
    pub const DATA_DESCRIPTOR_SIGNATURE: u32 = 0x08074b50;
    
    // Header sizes
    pub const LOCAL_FILE_HEADER_SIZE: usize = 30;
    pub const CENTRAL_DIRECTORY_HEADER_SIZE: usize = 46;
    pub const END_OF_CENTRAL_DIRECTORY_SIZE: usize = 22;
    pub const DATA_DESCRIPTOR_SIZE: usize = 16;
    
    // Compression methods
    pub const METHOD_STORED: u16 = 0;
    pub const METHOD_SHRUNK: u16 = 1;
    pub const METHOD_REDUCED_1: u16 = 2;
    pub const METHOD_REDUCED_2: u16 = 3;
    pub const METHOD_REDUCED_3: u16 = 4;
    pub const METHOD_REDUCED_4: u16 = 5;
    pub const METHOD_IMPLODED: u16 = 6;
    pub const METHOD_DEFLATED: u16 = 8;
    pub const METHOD_DEFLATE64: u16 = 9;
    pub const METHOD_BZIP2: u16 = 12;
    pub const METHOD_LZMA: u16 = 14;
    pub const METHOD_PPMD: u16 = 98;
    
    // General purpose bit flags
    pub const FLAG_ENCRYPTED: u16 = 0x0001;
    pub const FLAG_DATA_DESCRIPTOR: u16 = 0x0008;
    pub const FLAG_UTF8: u16 = 0x0800;
    
    // Version constants
    pub const VERSION_MADE_BY: u16 = 0x031E; // Version 3.1, Unix
    pub const VERSION_NEEDED: u16 = 0x0014;  // Version 2.0
    
    // Limits
    pub const MAX_COMMENT_SIZE: usize = 65535;
    pub const MAX_FILENAME_SIZE: usize = 65535;
    pub const MAX_EXTRA_SIZE: usize = 65535;
};
```

### TAR Constants

```zig
pub const TarConstants = struct {
    pub const BLOCK_SIZE: usize = 512;
    pub const NAME_SIZE: usize = 100;
    pub const MODE_SIZE: usize = 8;
    pub const UID_SIZE: usize = 8;
    pub const GID_SIZE: usize = 8;
    pub const SIZE_SIZE: usize = 12;
    pub const MTIME_SIZE: usize = 12;
    pub const CHECKSUM_SIZE: usize = 8;
    pub const LINKNAME_SIZE: usize = 100;
    pub const MAGIC_SIZE: usize = 6;
    pub const VERSION_SIZE: usize = 2;
    pub const UNAME_SIZE: usize = 32;
    pub const GNAME_SIZE: usize = 32;
    pub const DEVMAJOR_SIZE: usize = 8;
    pub const DEVMINOR_SIZE: usize = 8;
    pub const PREFIX_SIZE: usize = 155;
    
    // Magic values
    pub const MAGIC_USTAR: [6]u8 = [_]u8{ 'u', 's', 't', 'a', 'r', 0 };
    pub const VERSION_USTAR: [2]u8 = [_]u8{ '0', '0' };
    
    // File types
    pub const TYPE_REGULAR: u8 = '0';
    pub const TYPE_REGULAR_ALT: u8 = 0;
    pub const TYPE_LINK: u8 = '1';
    pub const TYPE_SYMLINK: u8 = '2';
    pub const TYPE_CHAR: u8 = '3';
    pub const TYPE_BLOCK: u8 = '4';
    pub const TYPE_DIRECTORY: u8 = '5';
    pub const TYPE_FIFO: u8 = '6';
    pub const TYPE_CONTIGUOUS: u8 = '7';
    pub const TYPE_GNU_LONGNAME: u8 = 'L';
    pub const TYPE_GNU_LONGLINK: u8 = 'K';
};
```

## Magic Byte Detection

### Magic Byte Constants

```zig
pub const MagicBytes = struct {
    pub const GZIP: [2]u8 = GzipConstants.MAGIC_BYTES;
    pub const ZSTD: [4]u8 = ZstdConstants.MAGIC_BYTES;
    pub const LZ4: [4]u8 = Lz4Constants.MAGIC_BYTES;
    pub const LZMA: [3]u8 = LzmaConstants.MAGIC_BYTES;
    pub const XZ: [6]u8 = XzConstants.MAGIC_BYTES;
    pub const ZIP: [4]u8 = [_]u8{ 0x50, 0x4B, 0x03, 0x04 };
    
    // Zlib magic bytes (variable second byte)
    pub const ZLIB_78_01: [2]u8 = [_]u8{ 0x78, 0x01 };
    pub const ZLIB_78_5E: [2]u8 = [_]u8{ 0x78, 0x5E };
    pub const ZLIB_78_9C: [2]u8 = [_]u8{ 0x78, 0x9C };
    pub const ZLIB_78_DA: [2]u8 = [_]u8{ 0x78, 0xDA };
};
```

## Error Constants

### Error Code Constants

```zig
pub const ErrorConstants = struct {
    pub const SUCCESS: i32 = 0;
    pub const ERROR_GENERIC: i32 = -1;
    pub const ERROR_OUT_OF_MEMORY: i32 = -2;
    pub const ERROR_INVALID_DATA: i32 = -3;
    pub const ERROR_CORRUPTED_STREAM: i32 = -4;
    pub const ERROR_CHECKSUM_MISMATCH: i32 = -5;
    pub const ERROR_UNSUPPORTED_ALGORITHM: i32 = -6;
    pub const ERROR_INVALID_MAGIC: i32 = -7;
    pub const ERROR_BUFFER_TOO_SMALL: i32 = -8;
    pub const ERROR_COMPRESSION_FAILED: i32 = -9;
    pub const ERROR_DECOMPRESSION_FAILED: i32 = -10;
};
```

## Platform Constants

### Platform-Specific Constants

```zig
pub const PlatformConstants = struct {
    pub const PAGE_SIZE_DEFAULT: usize = 4096;
    pub const PAGE_SIZE_LARGE: usize = 2 * 1024 * 1024; // 2MB
    pub const CACHE_LINE_SIZE: usize = 64;
    
    // Windows-specific
    pub const WINDOWS_MAX_PATH: usize = 260;
    pub const WINDOWS_LONG_PATH_PREFIX: []const u8 = "\\\\?\\";
    
    // Unix-specific
    pub const UNIX_MAX_PATH: usize = 4096;
    pub const UNIX_PATH_SEPARATOR: u8 = '/';
    
    // Cross-platform
    pub const MAX_FILENAME_LENGTH: usize = 255;
};
```

## Usage Examples

### Using Constants in Configuration

```zig
const std = @import("std");
const archive = @import("archive");

pub fn constantsExample() !void {
    // Use ZSTD constants for configuration
    const zstd_config = archive.CompressionConfig.init(.zstd)
        .withZstdLevel(archive.Constants.ZstdConstants.DEFAULT_LEVEL)
        .withBufferSize(archive.Constants.DEFAULT_BUFFER_SIZE);
    
    // Use LZ4 constants
    const lz4_config = archive.CompressionConfig.init(.lz4)
        .withLz4Level(archive.Constants.Lz4Constants.DEFAULT_LEVEL)
        .withBufferSize(archive.Constants.Lz4Constants.BLOCK_SIZE_64KB);
    
    // Use general constants
    const buffer_size = std.math.clamp(
        128 * 1024,
        archive.Constants.MIN_BUFFER_SIZE,
        archive.Constants.MAX_BUFFER_SIZE
    );
    
    std.debug.print("ZSTD default level: {d}\n", .{archive.Constants.ZstdConstants.DEFAULT_LEVEL});
    std.debug.print("LZ4 default level: {d}\n", .{archive.Constants.Lz4Constants.DEFAULT_LEVEL});
    std.debug.print("Clamped buffer size: {d}\n", .{buffer_size});
}
```

### Magic Byte Detection

```zig
pub fn magicByteExample(data: []const u8) !void {
    if (data.len < 2) return;
    
    // Check for gzip
    if (std.mem.eql(u8, data[0..2], &archive.Constants.MagicBytes.GZIP)) {
        std.debug.print("Detected: Gzip\n", .{});
        return;
    }
    
    // Check for ZSTD
    if (data.len >= 4 and std.mem.eql(u8, data[0..4], &archive.Constants.MagicBytes.ZSTD)) {
        std.debug.print("Detected: ZSTD\n", .{});
        return;
    }
    
    // Check for LZ4
    if (data.len >= 4 and std.mem.eql(u8, data[0..4], &archive.Constants.MagicBytes.LZ4)) {
        std.debug.print("Detected: LZ4\n", .{});
        return;
    }
    
    // Check for zlib (multiple possible second bytes)
    if (data[0] == 0x78) {
        const second_byte = data[1];
        if (second_byte == 0x01 or second_byte == 0x5E or second_byte == 0x9C or second_byte == 0xDA) {
            std.debug.print("Detected: Zlib\n", .{});
            return;
        }
    }
    
    std.debug.print("Unknown format\n", .{});
}
```

### Validation Using Constants

```zig
pub fn validateConfiguration(config: archive.CompressionConfig) !void {
    // Validate buffer size
    if (config.buffer_size < archive.Constants.MIN_BUFFER_SIZE or 
        config.buffer_size > archive.Constants.MAX_BUFFER_SIZE) {
        return error.InvalidBufferSize;
    }
    
    // Validate memory level
    if (config.memory_level < archive.Constants.MIN_MEMORY_LEVEL or 
        config.memory_level > archive.Constants.MAX_MEMORY_LEVEL) {
        return error.InvalidMemoryLevel;
    }
    
    // Validate algorithm-specific settings
    switch (config.algorithm) {
        .zstd => {
            if (config.zstd_level) |level| {
                if (level < archive.Constants.ZstdConstants.MIN_LEVEL or 
                    level > archive.Constants.ZstdConstants.MAX_LEVEL) {
                    return error.InvalidZstdLevel;
                }
            }
        },
        .lz4 => {
            if (config.lz4_level) |level| {
                if (level < archive.Constants.Lz4Constants.MIN_LEVEL or 
                    level > archive.Constants.Lz4Constants.MAX_LEVEL) {
                    return error.InvalidLz4Level;
                }
            }
        },
        else => {},
    }
    
    std.debug.print("Configuration is valid\n", .{});
}
```

## Best Practices

### Constants Guidelines

1. **Use constants for validation** - Validate inputs against defined limits
2. **Reference algorithm constants** - Use algorithm-specific constants for configuration
3. **Check magic bytes** - Use magic byte constants for format detection
4. **Respect platform limits** - Use platform constants for cross-platform compatibility
5. **Validate ranges** - Use min/max constants to validate user inputs
6. **Use default values** - Reference default constants for sensible defaults
7. **Document limits** - Constants serve as documentation for API limits

### Common Patterns

```zig
// Clamp values to valid ranges
const level = std.math.clamp(
    user_level,
    archive.Constants.ZstdConstants.MIN_LEVEL,
    archive.Constants.ZstdConstants.MAX_LEVEL
);

// Use defaults when values are not specified
const buffer_size = user_buffer_size orelse archive.Constants.DEFAULT_BUFFER_SIZE;

// Validate against constants
if (window_size < archive.Constants.MIN_WINDOW_SIZE) {
    return error.WindowSizeTooSmall;
}

// Format detection using magic bytes
const magic = data[0..4];
if (std.mem.eql(u8, magic, &archive.Constants.MagicBytes.ZSTD)) {
    return .zstd;
}
```

## Next Steps

- Learn about [Errors](./errors.md) for error constants and handling
- Explore [Algorithm](./algorithm.md) for algorithm-specific usage
- Check [Config](./config.md) for configuration with constants
- See [Examples](../examples/basic.md) for practical constant usage