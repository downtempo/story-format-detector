// DetectionError.swift
// Error types for story file format detection failures.
//
// Copyright (c) 2026 Andy Volk (https://andyvolk.com)
// SPDX-License-Identifier: MIT

import Foundation

/// Errors thrown when story file format detection fails.
@frozen
public enum DetectionError: Error, Equatable, Sendable {
    /// Neither magic bytes nor file extension identify a known format.
    case unsupportedFormat(fileExtension: String)
    /// The file data is too short to identify safely.
    case unreadable
}

extension DetectionError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .unsupportedFormat(let ext):
            "The file format '\(ext)' is not supported."
        case .unreadable:
            "The file is too short to identify."
        }
    }
}
