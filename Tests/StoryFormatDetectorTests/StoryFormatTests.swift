// StoryFormatTests.swift
// Tests for StoryFormat enum raw values and Codable round-tripping.
//
// Copyright (c) 2026 Andy Volk (https://andyvolk.com)
// SPDX-License-Identifier: MIT

import XCTest
@testable import StoryFormatDetector

final class StoryFormatTests: XCTestCase {

    func testRawValuesAreStable() {
        XCTAssertEqual(StoryFormat.zcode.rawValue, "zcode")
        XCTAssertEqual(StoryFormat.glulx.rawValue, "glulx")
        XCTAssertEqual(StoryFormat.blorb.rawValue, "blorb")
        XCTAssertEqual(StoryFormat.hugo.rawValue, "hugo")
        XCTAssertEqual(StoryFormat.alan.rawValue, "alan")
        XCTAssertEqual(StoryFormat.adrift.rawValue, "adrift")
        XCTAssertEqual(StoryFormat.tads2.rawValue, "tads2")
        XCTAssertEqual(StoryFormat.tads3.rawValue, "tads3")
        XCTAssertEqual(StoryFormat.adventuron.rawValue, "adventuron")
        XCTAssertEqual(StoryFormat.web.rawValue, "web")
        XCTAssertEqual(StoryFormat.twineSource.rawValue, "twineSource")
    }

    func testRoundTripsThroughRawValue() {
        for format in [StoryFormat.zcode, .glulx, .blorb, .hugo, .alan, .adrift, .tads2, .tads3, .adventuron, .web, .twineSource] {
            XCTAssertEqual(StoryFormat(rawValue: format.rawValue), format)
        }
    }

    func testAllCasesContainsAllElevenFormats() {
        XCTAssertEqual(StoryFormat.allCases.count, 11)
        XCTAssertTrue(StoryFormat.allCases.contains(.zcode))
        XCTAssertTrue(StoryFormat.allCases.contains(.glulx))
        XCTAssertTrue(StoryFormat.allCases.contains(.blorb))
        XCTAssertTrue(StoryFormat.allCases.contains(.hugo))
        XCTAssertTrue(StoryFormat.allCases.contains(.alan))
        XCTAssertTrue(StoryFormat.allCases.contains(.adrift))
        XCTAssertTrue(StoryFormat.allCases.contains(.tads2))
        XCTAssertTrue(StoryFormat.allCases.contains(.tads3))
        XCTAssertTrue(StoryFormat.allCases.contains(.adventuron))
        XCTAssertTrue(StoryFormat.allCases.contains(.web))
        XCTAssertTrue(StoryFormat.allCases.contains(.twineSource))
    }
}
