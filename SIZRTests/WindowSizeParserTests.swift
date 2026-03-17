import XCTest
@testable import SIZR

final class WindowSizeParserTests: XCTestCase {
    func testParseReturnsWindowSizeForPositiveIntegers() throws {
        let size = try WindowSizeParser.parse(widthText: "1440", heightText: "900").get()
        XCTAssertEqual(size, WindowSize(width: 1440, height: 900))
    }

    func testParseRejectsMissingValues() {
        XCTAssertEqual(
            WindowSizeParser.parse(widthText: "", heightText: "900"),
            .failure(.missingValue)
        )
    }

    func testParseRejectsNonWholeNumbers() {
        XCTAssertEqual(
            WindowSizeParser.parse(widthText: "1440.5", heightText: "900"),
            .failure(.notWholeNumber)
        )
    }

    func testParseRejectsNonPositiveValues() {
        XCTAssertEqual(
            WindowSizeParser.parse(widthText: "0", heightText: "900"),
            .failure(.nonPositive)
        )
    }
}
