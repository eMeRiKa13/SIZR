import Foundation
@testable import SIZR

final class MockResizeService: WindowResizing {
    var nextResult: ResizeResult = .success(.hd)
    private(set) var requestedSizes: [WindowSize] = []

    func resizeFrontmostWindow(to size: WindowSize) async -> ResizeResult {
        requestedSizes.append(size)
        return nextResult
    }
}

final class MockPermissionProvider: AccessibilityPermissionProviding {
    var trusted: Bool
    private(set) var promptCount = 0

    init(trusted: Bool = false) {
        self.trusted = trusted
    }

    func isTrusted() -> Bool {
        trusted
    }

    func requestPromptIfNeeded() {
        promptCount += 1
    }
}

final class MockLaunchAtLoginController: LaunchAtLoginControlling {
    var currentStatus: LaunchAtLoginStatus
    var statusToReturnOnSet: LaunchAtLoginStatus?
    var nextError: Error?
    private(set) var setEnabledCalls: [Bool] = []

    init(status: LaunchAtLoginStatus = .disabled) {
        currentStatus = status
    }

    func status() -> LaunchAtLoginStatus {
        currentStatus
    }

    func setEnabled(_ enabled: Bool) throws -> LaunchAtLoginStatus {
        setEnabledCalls.append(enabled)

        if let nextError {
            throw nextError
        }

        currentStatus = statusToReturnOnSet ?? (enabled ? .enabled : .disabled)
        return currentStatus
    }
}

final class InMemoryLastCustomSizeStore: LastCustomSizeStoring {
    var storedSize: WindowSize?

    func load() -> WindowSize? {
        storedSize
    }

    func save(_ size: WindowSize) {
        storedSize = size
    }
}

struct MockError: Error {}
