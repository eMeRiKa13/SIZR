import XCTest
@testable import SIZR

final class ResizeResultTests: XCTestCase {
    func testSuccessStatusPresentationUsesRequestedSize() {
        let status = ResizeResult.success(WindowSize(width: 1600, height: 900)).statusPresentation
        XCTAssertEqual(
            status,
            StatusPresentation(tone: .success, message: "Resized the front window to 1600\u{00D7}900.")
        )
    }

    func testPermissionStatusPresentationIsActionable() {
        XCTAssertEqual(
            ResizeResult.permissionRequired.statusPresentation,
            StatusPresentation(tone: .error, message: "Allow Accessibility access to resize other apps.")
        )
    }

    func testNoCompatibleWindowStatusPresentationIsFriendly() {
        XCTAssertEqual(
            ResizeResult.noCompatibleWindow.statusPresentation,
            StatusPresentation(tone: .error, message: "No compatible front window was found.")
        )
    }

    func testInvalidInputStatusPresentationUsesProvidedMessage() {
        XCTAssertEqual(
            ResizeResult.invalidInput("Enter both width and height.").statusPresentation,
            StatusPresentation(tone: .error, message: "Enter both width and height.")
        )
    }
}
