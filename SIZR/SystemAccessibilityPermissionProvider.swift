import ApplicationServices

final class SystemAccessibilityPermissionProvider: AccessibilityPermissionProviding {
    func isTrusted() -> Bool {
        AXIsProcessTrusted()
    }

    func requestPromptIfNeeded() {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
        _ = AXIsProcessTrustedWithOptions(options)
    }
}
