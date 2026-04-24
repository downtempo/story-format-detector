// StoryFormatDetector.swift
// Identifies story file formats from magic bytes or file extensions.
//
// Copyright (c) 2026 Andy Volk (https://andyvolk.com)
// SPDX-License-Identifier: MIT

import Foundation

/// Detects the format of an interactive fiction story file from its
/// leading bytes or file extension.
public enum StoryFormatDetector {

    // MARK: - Magic byte signatures

    private static let glulxMagic = Data([0x47, 0x6C, 0x75, 0x6C])  // "Glul"
    private static let iffFormTag = Data("FORM".utf8)
    private static let ifrsTag = Data("IFRS".utf8)
    private static let glulChunkTag = Data("GLUL".utf8)

    // MARK: - Magic byte detection

    /// Detect the story format from the first bytes of the file data.
    ///
    /// Requires at least 12 bytes to attempt any identification. Z-machine
    /// detection additionally requires 64 bytes to avoid false positives.
    ///
    /// - Parameter data: The raw bytes of the story file (or a prefix of it).
    /// - Returns: The detected format, or `nil` if unrecognised.
    public static func detect(data: Data) -> StoryFormat? {
        // Rebase so subscripts start at 0 (handles Data slices safely).
        let data = data.startIndex == 0 ? data : Data(data)
        guard data.count >= 12 else { return nil }

        // Glulx: "Glul" at offset 0
        if data[0..<4] == glulxMagic {
            return .glulx
        }

        // IFF Blorb: "FORM" at offset 0, "IFRS" at offset 8.
        // Walk the top-level IFF chunk structure to find the story type.
        // A GLUL chunk means Glulx-blorb; a cleanly walked FORM with no GLUL
        // is assumed to be Z-blorb; a prefix that ends mid-walk returns nil.
        if data[0..<4] == iffFormTag, data[8..<12] == ifrsTag {
            return detectBlorbFormat(data: data)
        }

        // Z-machine: version byte 1-8 at offset 0.
        // Require at least 64 bytes to avoid false positives on tiny files.
        let version = data[0]
        if version >= 1 && version <= 8 && data.count >= 64 {
            return .zcode
        }

        return nil
    }

    /// Walk the IFF top-level chunk list inside a confirmed Blorb file and
    /// return the format of the embedded story.
    ///
    /// IFF chunks are laid out as: 4-byte tag + 4-byte big-endian data size
    /// + data (padded to an even byte boundary). Walking the structure — rather
    /// than scanning a fixed byte window — correctly handles Blorbs whose story
    /// chunk is preceded by a large resource index (RIdx), which can push the
    /// GLUL chunk well past the first 512 bytes.
    ///
    /// Returns `nil` when the supplied buffer is a prefix that ends before the
    /// walker reaches the end of the FORM, because in that case we cannot
    /// distinguish "no GLUL anywhere, must be Z-blorb" from "GLUL is somewhere
    /// we haven't read yet". Callers that need a definitive answer must pass
    /// the full file. In practice Blorbs with more than ~6 resources already
    /// push the story chunk past offset 128, so a fixed 64- or 512-byte prefix
    /// is never enough for a principled walk.
    private static func detectBlorbFormat(data: Data) -> StoryFormat? {
        // FORM size lives at bytes 4-7, big-endian. End of FORM = 8 + formSize.
        // We use this only for the post-loop disambiguation: the walk itself
        // still runs against data.count so we tolerate malformed/zero size
        // fields without losing the chance to find a well-placed GLUL chunk.
        let formSize =
            Int(data[4]) << 24
            | Int(data[5]) << 16
            | Int(data[6]) << 8
            | Int(data[7])
        guard formSize >= 4 else { return nil }

        let declaredEnd = 8 + formSize
        var offset = 12  // skip FORM (4) + size (4) + IFRS (4)
        let walkLimit = min(data.count, declaredEnd)
        while offset + 8 <= walkLimit {
            let tag = data[offset..<offset + 4]
            let chunkSize =
                Int(data[offset + 4]) << 24
                | Int(data[offset + 5]) << 16
                | Int(data[offset + 6]) << 8
                | Int(data[offset + 7])
            if tag == glulChunkTag { return .glulx }
            // Advance past header (8) + data, rounded up to even byte boundary.
            offset += 8 + chunkSize + (chunkSize & 1)
        }

        // The loop exited either because we walked to the end of the buffer
        // or because the next chunk header wouldn't fit. If the declared
        // FORM extends past the buffer, our walk was truncated mid-FORM and
        // we cannot apply the "no GLUL means Z-blorb" fallback with any
        // confidence — return nil so callers know the answer is unknown.
        if declaredEnd > data.count { return nil }
        return .zcode
    }

    // MARK: - Validated detection

    /// Minimum byte count a valid story file must have (Z-machine header size).
    public static let minimumFileSize = 64

    /// Returns the story format, or throws a ``DetectionError`` if the format
    /// cannot be determined.
    ///
    /// Magic bytes take priority over extension; extension is the fallback
    /// when magic bytes are unrecognised (e.g. TADS, Hugo, Alan, ADRIFT,
    /// Adventuron, Twine source files, and HTML packages have no simple magic
    /// signature for this detector).
    ///
    /// - Throws: ``DetectionError/unreadable`` if the file is too short for a
    ///   format that requires minimum-size validation.
    /// - Throws: ``DetectionError/unsupportedFormat(fileExtension:)`` if
    ///   neither magic bytes nor extension identify a known format.
    public static func validate(
        data: Data,
        fileExtension: String
    ) throws -> StoryFormat {
        if let format = detect(data: data) { return format }
        if let format = detect(fileExtension: fileExtension) {
            if requiresMinimumFileSize(format), data.count < minimumFileSize {
                throw DetectionError.unreadable
            }
            return format
        }
        if data.count < minimumFileSize { throw DetectionError.unreadable }
        throw DetectionError.unsupportedFormat(fileExtension: fileExtension)
    }

    private static func requiresMinimumFileSize(_ format: StoryFormat) -> Bool {
        switch format {
        case .zcode, .glulx:
            return true
        case .blorb, .hugo, .alan, .adrift, .tads2, .tads3, .adventuron, .web, .twineSource:
            return false
        }
    }

    // MARK: - Extension-based detection

    /// Detect the story format from a file extension.
    ///
    /// - Parameter ext: The file extension without a leading dot, case-insensitive
    ///   (e.g. `"z5"`, `"ULX"`).
    /// - Returns: The detected format, or `nil` if the extension is unknown.
    public static func detect(fileExtension ext: String) -> StoryFormat? {
        switch ext.lowercased() {
        case "z1", "z2", "z3", "z4", "z5", "z6", "z7", "z8", "zblorb":
            return .zcode
        case "ulx", "gblorb":
            return .glulx
        case "blorb":
            return .blorb
        case "hex", "hdx":
            return .hugo
        case "acd":
            return .alan
        case "taf":
            return .adrift
        case "gam":
            return .tads2
        case "t3":
            return .tads3
        case "aastory":
            return .adventuron
        case "html", "htm":
            return .web
        case "twee", "tw2", "tw3":
            return .twineSource
        default:
            return nil
        }
    }
}
