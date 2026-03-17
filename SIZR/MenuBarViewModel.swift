import Combine
import Foundation

@MainActor
final class MenuBarViewModel: ObservableObject {
    @Published var customWidthText: String
    @Published var customHeightText: String
    @Published var isShowingCustomSizeControls = false
    @Published private(set) var status: StatusPresentation?
    @Published private(set) var isAccessibilityTrusted: Bool
    @Published private(set) var launchAtLoginStatus: LaunchAtLoginStatus

    private let resizeService: WindowResizing
    private let permissionProvider: AccessibilityPermissionProviding
    private let launchAtLoginController: LaunchAtLoginControlling
    private let lastCustomSizeStore: LastCustomSizeStoring

    init(
        resizeService: WindowResizing,
        permissionProvider: AccessibilityPermissionProviding,
        launchAtLoginController: LaunchAtLoginControlling,
        lastCustomSizeStore: LastCustomSizeStoring
    ) {
        self.resizeService = resizeService
        self.permissionProvider = permissionProvider
        self.launchAtLoginController = launchAtLoginController
        self.lastCustomSizeStore = lastCustomSizeStore

        let initialCustomSize = lastCustomSizeStore.load() ?? .hd
        customWidthText = String(initialCustomSize.width)
        customHeightText = String(initialCustomSize.height)
        isAccessibilityTrusted = permissionProvider.isTrusted()
        launchAtLoginStatus = launchAtLoginController.status()
    }

    var canApplyCustomSize: Bool {
        if case .success = WindowSizeParser.parse(widthText: customWidthText, heightText: customHeightText) {
            return true
        }
        return false
    }

    var customValidationMessage: String? {
        switch WindowSizeParser.parse(widthText: customWidthText, heightText: customHeightText) {
        case .success:
            return nil
        case .failure(let error):
            return error.message
        }
    }

    var isLaunchAtLoginEnabled: Bool {
        launchAtLoginStatus != .disabled
    }

    func prepareForDisplay() {
        status = nil
        refreshSystemState()
    }

    func revealCustomSizeControls() {
        isShowingCustomSizeControls = true
        status = nil
    }

    func resizeToHD() async {
        await performResize(to: .hd, rememberCustomSize: false)
    }

    func applyCustomSize() async {
        switch WindowSizeParser.parse(widthText: customWidthText, heightText: customHeightText) {
        case .failure(let error):
            status = StatusPresentation(tone: .error, message: error.message)
        case .success(let size):
            await performResize(to: size, rememberCustomSize: true)
        }
    }

    func requestAccessibilityAccess() {
        permissionProvider.requestPromptIfNeeded()
        isAccessibilityTrusted = permissionProvider.isTrusted()
        status = StatusPresentation(
            tone: .info,
            message: "Follow the system prompt to grant Accessibility access."
        )
    }

    func setLaunchAtLoginEnabled(_ enabled: Bool) {
        do {
            launchAtLoginStatus = try launchAtLoginController.setEnabled(enabled)
            switch launchAtLoginStatus {
            case .enabled:
                status = StatusPresentation(tone: .success, message: "Launch at login is on.")
            case .disabled:
                status = StatusPresentation(tone: .success, message: "Launch at login is off.")
            case .requiresApproval:
                status = StatusPresentation(
                    tone: .info,
                    message: "Launch at login needs approval in System Settings."
                )
            }
        } catch {
            launchAtLoginStatus = launchAtLoginController.status()
            status = StatusPresentation(
                tone: .error,
                message: "SIZR could not update launch at login."
            )
        }
    }

    private func performResize(to size: WindowSize, rememberCustomSize: Bool) async {
        status = nil
        let result = await resizeService.resizeFrontmostWindow(to: size)
        status = result.statusPresentation

        if case .success = result, rememberCustomSize {
            lastCustomSizeStore.save(size)
            customWidthText = String(size.width)
            customHeightText = String(size.height)
        }

        refreshSystemState()
    }

    private func refreshSystemState() {
        isAccessibilityTrusted = permissionProvider.isTrusted()
        launchAtLoginStatus = launchAtLoginController.status()
    }
}
