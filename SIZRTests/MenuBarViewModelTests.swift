import XCTest
@testable import SIZR

@MainActor
final class MenuBarViewModelTests: XCTestCase {
    func testInitUsesSavedCustomSizeWhenAvailable() {
        let dependencies = makeDependencies(savedSize: WindowSize(width: 1512, height: 982))
        let viewModel = makeViewModel(dependencies: dependencies)

        XCTAssertEqual(viewModel.customWidthText, "1512")
        XCTAssertEqual(viewModel.customHeightText, "982")
    }

    func testInitFallsBackToHDSizeOnFirstRun() {
        let viewModel = makeViewModel()

        XCTAssertEqual(viewModel.customWidthText, "1920")
        XCTAssertEqual(viewModel.customHeightText, "1080")
    }

    func testApplyCustomSizeShowsValidationErrorWithoutCallingResize() async {
        let dependencies = makeDependencies()
        let viewModel = makeViewModel(dependencies: dependencies)
        viewModel.customWidthText = "0"
        viewModel.customHeightText = "800"

        await viewModel.applyCustomSize()

        XCTAssertTrue(dependencies.resizeService.requestedSizes.isEmpty)
        XCTAssertEqual(
            viewModel.status,
            StatusPresentation(tone: .error, message: "Width and height must be greater than 0.")
        )
    }

    func testApplyCustomSizePersistsSuccessfulResize() async {
        let dependencies = makeDependencies()
        dependencies.resizeService.nextResult = .success(WindowSize(width: 1664, height: 936))
        let viewModel = makeViewModel(dependencies: dependencies)
        viewModel.customWidthText = "1664"
        viewModel.customHeightText = "936"

        await viewModel.applyCustomSize()

        XCTAssertEqual(dependencies.resizeService.requestedSizes, [WindowSize(width: 1664, height: 936)])
        XCTAssertEqual(dependencies.sizeStore.storedSize, WindowSize(width: 1664, height: 936))
        XCTAssertEqual(
            viewModel.status,
            StatusPresentation(tone: .success, message: "Resized the front window to 1664\u{00D7}936.")
        )
    }

    func testResizeToHDDoesNotOverwriteSavedCustomSize() async {
        let dependencies = makeDependencies(savedSize: WindowSize(width: 1512, height: 982))
        dependencies.resizeService.nextResult = .success(.hd)
        let viewModel = makeViewModel(dependencies: dependencies)

        await viewModel.resizeToHD()

        XCTAssertEqual(dependencies.sizeStore.storedSize, WindowSize(width: 1512, height: 982))
    }

    func testPrepareForDisplayRefreshesPermissionAndLaunchAtLoginState() {
        let dependencies = makeDependencies()
        let viewModel = makeViewModel(dependencies: dependencies)

        dependencies.permissionProvider.trusted = true
        dependencies.launchAtLoginController.currentStatus = .enabled
        viewModel.prepareForDisplay()

        XCTAssertTrue(viewModel.isAccessibilityTrusted)
        XCTAssertTrue(viewModel.isLaunchAtLoginEnabled)
    }

    func testRequestAccessibilityAccessPromptsSystem() {
        let dependencies = makeDependencies()
        let viewModel = makeViewModel(dependencies: dependencies)

        viewModel.requestAccessibilityAccess()

        XCTAssertEqual(dependencies.permissionProvider.promptCount, 1)
        XCTAssertEqual(
            viewModel.status,
            StatusPresentation(
                tone: .info,
                message: "Follow the system prompt to grant Accessibility access."
            )
        )
    }

    func testSetLaunchAtLoginEnabledUpdatesStatus() {
        let dependencies = makeDependencies()
        let viewModel = makeViewModel(dependencies: dependencies)

        viewModel.setLaunchAtLoginEnabled(true)

        XCTAssertEqual(dependencies.launchAtLoginController.setEnabledCalls, [true])
        XCTAssertTrue(viewModel.isLaunchAtLoginEnabled)
        XCTAssertEqual(
            viewModel.status,
            StatusPresentation(tone: .success, message: "Launch at login is on.")
        )
    }

    func testSetLaunchAtLoginEnabledHandlesApprovalState() {
        let dependencies = makeDependencies()
        dependencies.launchAtLoginController.statusToReturnOnSet = .requiresApproval
        let viewModel = makeViewModel(dependencies: dependencies)

        viewModel.setLaunchAtLoginEnabled(true)

        XCTAssertTrue(viewModel.isLaunchAtLoginEnabled)
        XCTAssertEqual(
            viewModel.status,
            StatusPresentation(
                tone: .info,
                message: "Launch at login needs approval in System Settings."
            )
        )
    }

    func testSetLaunchAtLoginEnabledHandlesErrors() {
        let dependencies = makeDependencies()
        dependencies.launchAtLoginController.nextError = MockError()
        let viewModel = makeViewModel(dependencies: dependencies)

        viewModel.setLaunchAtLoginEnabled(true)

        XCTAssertFalse(viewModel.isLaunchAtLoginEnabled)
        XCTAssertEqual(
            viewModel.status,
            StatusPresentation(tone: .error, message: "SIZR could not update launch at login.")
        )
    }

    private func makeViewModel(dependencies: Dependencies? = nil) -> MenuBarViewModel {
        let resolvedDependencies = dependencies ?? makeDependencies()
        return MenuBarViewModel(
            resizeService: resolvedDependencies.resizeService,
            permissionProvider: resolvedDependencies.permissionProvider,
            launchAtLoginController: resolvedDependencies.launchAtLoginController,
            lastCustomSizeStore: resolvedDependencies.sizeStore
        )
    }

    private func makeDependencies(savedSize: WindowSize? = nil) -> Dependencies {
        let resizeService = MockResizeService()
        let permissionProvider = MockPermissionProvider()
        let launchAtLoginController = MockLaunchAtLoginController()
        let sizeStore = InMemoryLastCustomSizeStore()
        sizeStore.storedSize = savedSize
        return Dependencies(
            resizeService: resizeService,
            permissionProvider: permissionProvider,
            launchAtLoginController: launchAtLoginController,
            sizeStore: sizeStore
        )
    }

    private struct Dependencies {
        let resizeService: MockResizeService
        let permissionProvider: MockPermissionProvider
        let launchAtLoginController: MockLaunchAtLoginController
        let sizeStore: InMemoryLastCustomSizeStore
    }
}
