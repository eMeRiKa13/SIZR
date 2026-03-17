import AppKit

protocol WindowResizing {
    func resizeFrontmostWindow(to size: WindowSize) async -> ResizeResult
}

protocol AccessibilityPermissionProviding {
    func isTrusted() -> Bool
    func requestPromptIfNeeded()
}

enum LaunchAtLoginStatus: Equatable {
    case disabled
    case enabled
    case requiresApproval
}

protocol LaunchAtLoginControlling {
    func status() -> LaunchAtLoginStatus
    func setEnabled(_ enabled: Bool) throws -> LaunchAtLoginStatus
}

protocol LastCustomSizeStoring {
    func load() -> WindowSize?
    func save(_ size: WindowSize)
}

protocol FrontmostApplicationProviding {
    func targetApplication() -> NSRunningApplication?
}
