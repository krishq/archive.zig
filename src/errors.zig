const std = @import("std");

pub const CompressError = error{
    UnsupportedAlgorithm,
    UnsupportedAlgorithmForDirectory,
    InvalidData,
    CorruptedStream,
    OutOfMemory,
    InternalFailure,
    ChecksumMismatch,
    OutputTooLarge,
    InvalidMagic,
    InvalidOffset,
    InvalidZipArchive,
    UnsupportedZipCompressionMethod,
    InvalidTarArchive,
    InvalidLzmaHeader,
    UnsupportedLzma2Chunk,
    ZstdError,
    FileNotFound,
    PermissionDenied,
    ExcludedByPattern,
    EmptyInput,
};

pub fn formatError(err: CompressError) []const u8 {
    return switch (err) {
        error.UnsupportedAlgorithm => "Unsupported compression algorithm",
        error.UnsupportedAlgorithmForDirectory => "Algorithm does not support directory compression",
        error.InvalidData => "Invalid or corrupted data",
        error.CorruptedStream => "Corrupted data stream",
        error.OutOfMemory => "Out of memory",
        error.InternalFailure => "Internal compression failure",
        error.ChecksumMismatch => "Checksum verification failed",
        error.OutputTooLarge => "Output size exceeds limit",
        error.InvalidMagic => "Invalid file magic number",
        error.InvalidOffset => "Invalid back-reference offset",
        error.InvalidZipArchive => "Invalid ZIP archive format",
        error.UnsupportedZipCompressionMethod => "Unsupported ZIP compression method",
        error.InvalidTarArchive => "Invalid TAR archive format",
        error.InvalidLzmaHeader => "Invalid LZMA header",
        error.UnsupportedLzma2Chunk => "Unsupported LZMA2 chunk type",
        error.ZstdError => "Zstandard compression error",
        error.FileNotFound => "File not found",
        error.PermissionDenied => "Permission denied",
        error.ExcludedByPattern => "Excluded by pattern",
        error.EmptyInput => "Empty input data",
    };
}

test "error formatting" {
    const testing = std.testing;
    const msg = formatError(error.InvalidData);
    try testing.expect(msg.len > 0);
}
