import AppKit
import ApplicationServices

final class AccessibilityWindowResizer: WindowResizing {
    private let permissionProvider: AccessibilityPermissionProviding
    private let frontmostApplicationProvider: FrontmostApplicationProviding

    init(
        permissionProvider: AccessibilityPermissionProviding,
        frontmostApplicationProvider: FrontmostApplicationProviding
    ) {
        self.permissionProvider = permissionProvider
        self.frontmostApplicationProvider = frontmostApplicationProvider
    }

    func resizeFrontmostWindow(to size: WindowSize) async -> ResizeResult {
        guard size.width > 0, size.height > 0 else {
            return .invalidInput(WindowSizeValidationError.nonPositive.message)
        }

        guard permissionProvider.isTrusted() else {
            return .permissionRequired
        }

        guard let application = frontmostApplicationProvider.targetApplication() else {
            return .noFrontmostApplication
        }

        let applicationElement = AXUIElementCreateApplication(application.processIdentifier)

        guard let window = targetWindow(in: applicationElement) else {
            return .noCompatibleWindow
        }

        guard isSizeAttributeSettable(on: window) else {
            return .windowNotResizable
        }

        return set(size: size, on: window)
    }

    private func targetWindow(in applicationElement: AXUIElement) -> AXUIElement? {
        window(for: kAXFocusedWindowAttribute as CFString, in: applicationElement)
            ?? window(for: kAXMainWindowAttribute as CFString, in: applicationElement)
    }

    private func window(for attribute: CFString, in element: AXUIElement) -> AXUIElement? {
        var value: CFTypeRef?
        let error = AXUIElementCopyAttributeValue(element, attribute, &value)

        guard error == .success, let value else {
            return nil
        }

        guard CFGetTypeID(value) == AXUIElementGetTypeID() else {
            return nil
        }

        return unsafeBitCast(value, to: AXUIElement.self)
    }

    private func isSizeAttributeSettable(on window: AXUIElement) -> Bool {
        var isSettable = DarwinBoolean(false)
        let error = AXUIElementIsAttributeSettable(window, kAXSizeAttribute as CFString, &isSettable)
        return error == .success && isSettable.boolValue
    }

    private func set(size: WindowSize, on window: AXUIElement) -> ResizeResult {
        var cgSize = CGSize(width: size.width, height: size.height)

        guard let axSize = AXValueCreate(.cgSize, &cgSize) else {
            return .failure("SIZR could not prepare the requested window size.")
        }

        let error = AXUIElementSetAttributeValue(window, kAXSizeAttribute as CFString, axSize)

        switch error {
        case .success:
            return .success(size)
        case .apiDisabled:
            return .permissionRequired
        case .attributeUnsupported, .cannotComplete, .failure, .illegalArgument, .noValue, .notEnoughPrecision:
            return .windowNotResizable
        default:
            return .failure("SIZR could not resize the front window.")
        }
    }
}
