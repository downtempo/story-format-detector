// StoryFormatDetectorTests.swift
// Tests for magic byte detection, extension detection, and validated detection.
//
// Copyright (c) 2026 Andy Volk (https://andyvolk.com)
// SPDX-License-Identifier: MIT

import Foundation
import XCTest
@testable import StoryFormatDetector

final class StoryFormatDetectorMagicByteTests: XCTestCase {

    func testGlulxMagic() {
        let data = makeData(leading: [0x47, 0x6C, 0x75, 0x6C], total: 64)
        XCTAssertEqual(StoryFormatDetector.detect(data: data), .glulx)
    }

    func testZMachineV1() {
        let data = makeData(leading: [0x01], total: 64)
        XCTAssertEqual(StoryFormatDetector.detect(data: data), .zcode)
    }

    func testZMachineV3() {
        let data = makeData(leading: [0x03], total: 64)
        XCTAssertEqual(StoryFormatDetector.detect(data: data), .zcode)
    }

    func testZMachineV5() {
        let data = makeData(leading: [0x05], total: 64)
        XCTAssertEqual(StoryFormatDetector.detect(data: data), .zcode)
    }

    func testZMachineV8() {
        let data = makeData(leading: [0x08], total: 64)
        XCTAssertEqual(StoryFormatDetector.detect(data: data), .zcode)
    }

    func testZMachineVersion0() {
        let data = makeData(leading: [0x00], total: 64)
        XCTAssertNil(StoryFormatDetector.detect(data: data))
    }

    func testZMachineVersion9() {
        let data = makeData(leading: [0x09], total: 64)
        XCTAssertNil(StoryFormatDetector.detect(data: data))
    }

    func testZMachineTruncated() {
        let data = makeData(leading: [0x05], total: 32)
        XCTAssertNil(StoryFormatDetector.detect(data: data))
    }

    // FORM size 56 means the walker reaches the end of the declared FORM
    // inside the 64-byte buffer (8-byte header + 56 bytes of payload). No
    // GLUL is found, so the historical "no GLUL means Z-blorb" fallback
    // applies. This must pair with testBlorbPrefixTooShortForWalkReturnsNil:
    // a prefix that does NOT cover the full FORM returns nil instead.
    func testZBlorb() {
        var bytes = [UInt8](repeating: 0, count: 64)
        bytes[0] = 0x46; bytes[1] = 0x4F; bytes[2] = 0x52; bytes[3] = 0x4D
        bytes[4] = 0; bytes[5] = 0; bytes[6] = 0; bytes[7] = 56
        bytes[8] = 0x49; bytes[9] = 0x46; bytes[10] = 0x52; bytes[11] = 0x53
        XCTAssertEqual(StoryFormatDetector.detect(data: Data(bytes)), .zcode)
    }

    func testGBlorb() {
        var bytes = [UInt8](repeating: 0, count: 64)
        bytes[0] = 0x46; bytes[1] = 0x4F; bytes[2] = 0x52; bytes[3] = 0x4D
        bytes[4] = 0; bytes[5] = 0; bytes[6] = 0; bytes[7] = 56
        bytes[8] = 0x49; bytes[9] = 0x46; bytes[10] = 0x52; bytes[11] = 0x53
        bytes[20] = 0x47; bytes[21] = 0x4C; bytes[22] = 0x55; bytes[23] = 0x4C
        XCTAssertEqual(StoryFormatDetector.detect(data: Data(bytes)), .glulx)
    }

    func testEmptyData() {
        XCTAssertNil(StoryFormatDetector.detect(data: Data()))
    }

    func testShortData() {
        XCTAssertNil(StoryFormatDetector.detect(data: Data([0x47, 0x6C, 0x75])))
    }

    func testUnknownMagic() {
        let data = makeData(leading: [0xFF, 0xFE, 0xFD, 0xFC], total: 128)
        XCTAssertNil(StoryFormatDetector.detect(data: data))
    }

    func testGBlorbLargeResourceIndex() {
        var bytes = [UInt8](repeating: 0, count: 1040)
        bytes[0] = 0x46; bytes[1] = 0x4F; bytes[2] = 0x52; bytes[3] = 0x4D
        bytes[4] = 0x00; bytes[5] = 0x00; bytes[6] = 0x04; bytes[7] = 0x08
        bytes[8] = 0x49; bytes[9] = 0x46; bytes[10] = 0x52; bytes[11] = 0x53
        bytes[12] = 0x52; bytes[13] = 0x49; bytes[14] = 0x44; bytes[15] = 0x58
        bytes[16] = 0x00; bytes[17] = 0x00; bytes[18] = 0x03; bytes[19] = 0xE8
        bytes[1020] = 0x47; bytes[1021] = 0x4C; bytes[1022] = 0x55; bytes[1023] = 0x4C
        bytes[1024] = 0x00; bytes[1025] = 0x00; bytes[1026] = 0x00; bytes[1027] = 0x10
        XCTAssertEqual(StoryFormatDetector.detect(data: Data(bytes)), .glulx)
    }

    /// Regression: a short prefix of a Glulx Blorb with a large resource
    /// index must return `nil`, not `.zcode`. This reproduces the City of
    /// Secrets bug where a 64-byte prefix caused the walker to advance past
    /// its own buffer and silently fall through to the Z-blorb default.
    /// Shape: FORM size 0x00812234 (~8 MB), RIdx size 0x1F0 (496 bytes),
    /// GLUL chunk logically at offset 0x204 — not in the 64-byte prefix.
    func testBlorbPrefixTooShortForWalkReturnsNil() {
        var bytes = [UInt8](repeating: 0, count: 64)
        // FORM <size> IFRS
        bytes[0] = 0x46; bytes[1] = 0x4F; bytes[2] = 0x52; bytes[3] = 0x4D
        bytes[4] = 0x00; bytes[5] = 0x81; bytes[6] = 0x22; bytes[7] = 0x34
        bytes[8] = 0x49; bytes[9] = 0x46; bytes[10] = 0x52; bytes[11] = 0x53
        // RIdx chunk header, size 0x000001F0 — body extends past 64 bytes
        bytes[12] = 0x52; bytes[13] = 0x49; bytes[14] = 0x64; bytes[15] = 0x78
        bytes[16] = 0x00; bytes[17] = 0x00; bytes[18] = 0x01; bytes[19] = 0xF0
        XCTAssertNil(StoryFormatDetector.detect(data: Data(bytes)))
    }

    func testBlorbRejectsFormSizeTooSmallForTypeTag() {
        var bytes = [UInt8](repeating: 0, count: 64)
        bytes[0] = 0x46; bytes[1] = 0x4F; bytes[2] = 0x52; bytes[3] = 0x4D
        bytes[4] = 0x00; bytes[5] = 0x00; bytes[6] = 0x00; bytes[7] = 0x03
        bytes[8] = 0x49; bytes[9] = 0x46; bytes[10] = 0x52; bytes[11] = 0x53
        XCTAssertNil(StoryFormatDetector.detect(data: Data(bytes)))
    }

    func testBlorbDoesNotUseGLULChunkOutsideDeclaredForm() {
        var bytes = [UInt8](repeating: 0, count: 64)
        bytes[0] = 0x46; bytes[1] = 0x4F; bytes[2] = 0x52; bytes[3] = 0x4D
        bytes[4] = 0x00; bytes[5] = 0x00; bytes[6] = 0x00; bytes[7] = 0x04
        bytes[8] = 0x49; bytes[9] = 0x46; bytes[10] = 0x52; bytes[11] = 0x53
        bytes[20] = 0x47; bytes[21] = 0x4C; bytes[22] = 0x55; bytes[23] = 0x4C
        XCTAssertEqual(StoryFormatDetector.detect(data: Data(bytes)), .zcode)
    }

    func testDataSlice() {
        var big = Data(repeating: 0, count: 100)
        big[50] = 0x47; big[51] = 0x6C; big[52] = 0x75; big[53] = 0x6C
        let slice = big[50...]
        XCTAssertEqual(StoryFormatDetector.detect(data: slice), .glulx)
    }
}

final class StoryFormatDetectorExtensionTests: XCTestCase {

    func testZcodeExtensions() {
        for ext in ["z1", "z2", "z3", "z4", "z5", "z6", "z7", "z8", "zblorb", "Z5", "ZBLORB"] {
            XCTAssertEqual(StoryFormatDetector.detect(fileExtension: ext), .zcode, "Failed for \(ext)")
        }
    }

    func testGlulxExtensions() {
        for ext in ["ulx", "gblorb", "ULX"] {
            XCTAssertEqual(StoryFormatDetector.detect(fileExtension: ext), .glulx, "Failed for \(ext)")
        }
    }

    func testGenericBlorbExtension() {
        XCTAssertEqual(StoryFormatDetector.detect(fileExtension: "blorb"), .blorb)
        XCTAssertEqual(StoryFormatDetector.detect(fileExtension: "BLORB"), .blorb)
    }

    func testHugoExtensions() {
        XCTAssertEqual(StoryFormatDetector.detect(fileExtension: "hex"), .hugo)
        XCTAssertEqual(StoryFormatDetector.detect(fileExtension: "HDX"), .hugo)
    }

    func testAlanExtension() {
        XCTAssertEqual(StoryFormatDetector.detect(fileExtension: "acd"), .alan)
        XCTAssertEqual(StoryFormatDetector.detect(fileExtension: "ACD"), .alan)
    }

    func testAdriftExtension() {
        XCTAssertEqual(StoryFormatDetector.detect(fileExtension: "taf"), .adrift)
        XCTAssertEqual(StoryFormatDetector.detect(fileExtension: "TAF"), .adrift)
    }

    func testTads2Extension() {
        XCTAssertEqual(StoryFormatDetector.detect(fileExtension: "gam"), .tads2)
        XCTAssertEqual(StoryFormatDetector.detect(fileExtension: "GAM"), .tads2)
    }

    func testTads3Extension() {
        XCTAssertEqual(StoryFormatDetector.detect(fileExtension: "t3"), .tads3)
    }

    func testAdventuronExtension() {
        XCTAssertEqual(StoryFormatDetector.detect(fileExtension: "aastory"), .adventuron)
        XCTAssertEqual(StoryFormatDetector.detect(fileExtension: "AASTORY"), .adventuron)
    }

    func testWebExtensions() {
        XCTAssertEqual(StoryFormatDetector.detect(fileExtension: "html"), .web)
        XCTAssertEqual(StoryFormatDetector.detect(fileExtension: "htm"), .web)
        XCTAssertEqual(StoryFormatDetector.detect(fileExtension: "HTML"), .web)
    }

    func testTwineSourceExtensions() {
        XCTAssertEqual(StoryFormatDetector.detect(fileExtension: "twee"), .twineSource)
        XCTAssertEqual(StoryFormatDetector.detect(fileExtension: "tw2"), .twineSource)
        XCTAssertEqual(StoryFormatDetector.detect(fileExtension: "TW3"), .twineSource)
    }

    func testUnknownExtension() {
        XCTAssertNil(StoryFormatDetector.detect(fileExtension: "pdf"))
        XCTAssertNil(StoryFormatDetector.detect(fileExtension: ""))
        XCTAssertNil(StoryFormatDetector.detect(fileExtension: "exe"))
    }
}

final class StoryFormatDetectorValidateTests: XCTestCase {

    func testEmptyDataThrowsUnreadable() {
        XCTAssertThrowsError(try StoryFormatDetector.validate(data: Data(), fileExtension: "z5")) { error in
            XCTAssertEqual(error as? DetectionError, .unreadable)
        }
    }

    func testShortDataThrowsUnreadable() {
        let data = Data([UInt8](repeating: 0x05, count: 32))
        XCTAssertThrowsError(try StoryFormatDetector.validate(data: data, fileExtension: "z5")) { error in
            XCTAssertEqual(error as? DetectionError, .unreadable)
        }
    }

    func testUnknownFormatThrowsUnsupportedFormat() {
        let data = Data([UInt8](repeating: 0xFF, count: 64))
        XCTAssertThrowsError(try StoryFormatDetector.validate(data: data, fileExtension: "pdf")) { error in
            XCTAssertEqual(error as? DetectionError, .unsupportedFormat(fileExtension: "pdf"))
        }
    }

    func testUnknownShortFormatThrowsUnreadable() {
        let data = Data([UInt8](repeating: 0xFF, count: 32))
        XCTAssertThrowsError(try StoryFormatDetector.validate(data: data, fileExtension: "pdf")) { error in
            XCTAssertEqual(error as? DetectionError, .unreadable)
        }
    }

    func testUnsupportedFormatCarriesExtension() {
        let data = Data([UInt8](repeating: 0xFF, count: 64))
        do {
            _ = try StoryFormatDetector.validate(data: data, fileExtension: "xyz")
            XCTFail("Expected validate to throw")
        } catch DetectionError.unsupportedFormat(let ext) {
            XCTAssertEqual(ext, "xyz")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testZMagicSucceeds() throws {
        var bytes = [UInt8](repeating: 0, count: 64)
        bytes[0] = 0x05
        let format = try StoryFormatDetector.validate(data: Data(bytes), fileExtension: "bin")
        XCTAssertEqual(format, .zcode)
    }

    func testExtensionFallback() throws {
        let data = Data([UInt8](repeating: 0xFF, count: 64))
        let format = try StoryFormatDetector.validate(data: data, fileExtension: "ulx")
        XCTAssertEqual(format, .glulx)
    }

    func testShortTads2ExtensionFallbackSucceeds() throws {
        let data = Data([0x00])
        let format = try StoryFormatDetector.validate(data: data, fileExtension: "gam")
        XCTAssertEqual(format, .tads2)
    }

    func testShortTads3ExtensionFallbackSucceeds() throws {
        let data = Data([0x00])
        let format = try StoryFormatDetector.validate(data: data, fileExtension: "t3")
        XCTAssertEqual(format, .tads3)
    }

    func testAdventuronExtensionFallback() throws {
        let data = Data([UInt8](repeating: 0xFF, count: 64))
        let format = try StoryFormatDetector.validate(data: data, fileExtension: "aastory")
        XCTAssertEqual(format, .adventuron)
    }

    func testGenericBlorbExtensionFallback() throws {
        let data = Data([UInt8](repeating: 0xFF, count: 64))
        let format = try StoryFormatDetector.validate(data: data, fileExtension: "blorb")
        XCTAssertEqual(format, .blorb)
    }

    func testHugoExtensionFallback() throws {
        let data = Data([UInt8](repeating: 0xFF, count: 64))
        let format = try StoryFormatDetector.validate(data: data, fileExtension: "hex")
        XCTAssertEqual(format, .hugo)
    }

    func testAlanExtensionFallback() throws {
        let data = Data([UInt8](repeating: 0xFF, count: 64))
        let format = try StoryFormatDetector.validate(data: data, fileExtension: "acd")
        XCTAssertEqual(format, .alan)
    }

    func testAdriftExtensionFallback() throws {
        let data = Data([UInt8](repeating: 0xFF, count: 64))
        let format = try StoryFormatDetector.validate(data: data, fileExtension: "taf")
        XCTAssertEqual(format, .adrift)
    }

    func testWebExtensionFallback() throws {
        let data = Data([UInt8](repeating: 0xFF, count: 64))
        let format = try StoryFormatDetector.validate(data: data, fileExtension: "html")
        XCTAssertEqual(format, .web)
    }

    func testTwineSourceExtensionFallback() throws {
        let data = Data([UInt8](repeating: 0xFF, count: 64))
        let format = try StoryFormatDetector.validate(data: data, fileExtension: "twee")
        XCTAssertEqual(format, .twineSource)
    }

    func testShortWebExtensionFallbackSucceeds() throws {
        let data = Data("<".utf8)
        let format = try StoryFormatDetector.validate(data: data, fileExtension: "html")
        XCTAssertEqual(format, .web)
    }

    func testShortTwineSourceExtensionFallbackSucceeds() throws {
        let data = Data(":".utf8)
        let format = try StoryFormatDetector.validate(data: data, fileExtension: "twee")
        XCTAssertEqual(format, .twineSource)
    }

    func testShortGenericBlorbExtensionFallbackSucceeds() throws {
        let data = Data([0x00])
        let format = try StoryFormatDetector.validate(data: data, fileExtension: "blorb")
        XCTAssertEqual(format, .blorb)
    }

    func testBoundaryBelow64Throws() {
        let data = Data([UInt8](repeating: 0x05, count: 63))
        XCTAssertThrowsError(try StoryFormatDetector.validate(data: data, fileExtension: "z5")) { error in
            XCTAssertEqual(error as? DetectionError, .unreadable)
        }
    }

    func testBoundaryBelow64GlulxThrows() {
        let data = Data([UInt8](repeating: 0xFF, count: 63))
        XCTAssertThrowsError(try StoryFormatDetector.validate(data: data, fileExtension: "ulx")) { error in
            XCTAssertEqual(error as? DetectionError, .unreadable)
        }
    }

    func testValidateWithDataSlice() throws {
        var big = Data(repeating: 0, count: 150)
        big[50] = 0x05
        let slice = big[50...]
        let format = try StoryFormatDetector.validate(data: slice, fileExtension: "bin")
        XCTAssertEqual(format, .zcode)
    }
}

private func makeData(leading: [UInt8], total: Int) -> Data {
    var bytes = leading
    bytes.append(contentsOf: [UInt8](repeating: 0, count: max(0, total - leading.count)))
    return Data(bytes)
}
