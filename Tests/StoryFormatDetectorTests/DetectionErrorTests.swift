// DetectionErrorTests.swift
// Tests for DetectionError cases and Equatable conformance.
//
// Copyright (c) 2026 Andy Volk (https://andyvolk.com)
// SPDX-License-Identifier: MIT

import XCTest
@testable import StoryFormatDetector

final class DetectionErrorTests: XCTestCase {

    func testUnsupportedFormatCarriesTheFileExtension() {
        let err = DetectionError.unsupportedFormat(fileExtension: "mp3")
        guard case .unsupportedFormat(let ext) = err else {
            XCTFail("Wrong case")
            return
        }
        XCTAssertEqual(ext, "mp3")
    }

    func testUnreadableHasNoAssociatedValue() {
        let err = DetectionError.unreadable
        XCTAssertEqual(err, .unreadable)
    }

    func testSameUnsupportedFormatExtensionComparesEqual() {
        XCTAssertEqual(
            DetectionError.unsupportedFormat(fileExtension: "pdf"),
            DetectionError.unsupportedFormat(fileExtension: "pdf")
        )
    }

    func testDifferentExtensionsAreNotEqual() {
        XCTAssertNotEqual(
            DetectionError.unsupportedFormat(fileExtension: "pdf"),
            DetectionError.unsupportedFormat(fileExtension: "exe")
        )
    }

    func testDifferentCasesAreNotEqual() {
        XCTAssertNotEqual(
            DetectionError.unreadable,
            DetectionError.unsupportedFormat(fileExtension: "z5")
        )
    }

    func testUnsupportedFormatErrorDescriptionIncludesExtension() {
        let err = DetectionError.unsupportedFormat(fileExtension: "pdf")
        XCTAssertEqual(err.errorDescription, "The file format 'pdf' is not supported.")
    }

    func testUnreadableErrorDescription() {
        let err = DetectionError.unreadable
        XCTAssertEqual(err.errorDescription, "The file is too short to identify.")
    }
}
