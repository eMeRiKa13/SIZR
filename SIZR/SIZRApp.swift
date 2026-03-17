import SwiftUI

@main
struct SIZRApp: App {
    @StateObject private var viewModel: MenuBarViewModel

    init() {
        let permissionProvider = SystemAccessibilityPermissionProvider()
        let frontmostApplicationTracker = WorkspaceFrontmostApplicationTracker()
        let resizeService = AccessibilityWindowResizer(
            permissionProvider: permissionProvider,
            frontmostApplicationProvider: frontmostApplicationTracker
        )
        let launchAtLoginController = SMAppServiceLaunchAtLoginController()
        let lastCustomSizeStore = UserDefaultsLastCustomSizeStore(userDefaults: .standard)

        _viewModel = StateObject(
            wrappedValue: MenuBarViewModel(
                resizeService: resizeService,
                permissionProvider: permissionProvider,
                launchAtLoginController: launchAtLoginController,
                lastCustomSizeStore: lastCustomSizeStore
            )
        )
    }

    var body: some Scene {
        MenuBarExtra("SIZR", systemImage: "rectangle.dashed") {
            MenuBarContentView(viewModel: viewModel)
        }
        .menuBarExtraStyle(.window)
    }
}
