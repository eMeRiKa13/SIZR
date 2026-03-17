import AppKit

final class WorkspaceFrontmostApplicationTracker: FrontmostApplicationProviding {
    private let workspace: NSWorkspace
    private let notificationCenter: NotificationCenter
    private let selfBundleIdentifier = Bundle.main.bundleIdentifier
    private var lastExternalApplication: NSRunningApplication?
    private var activationObserver: NSObjectProtocol?

    init(workspace: NSWorkspace = .shared) {
        self.workspace = workspace
        notificationCenter = workspace.notificationCenter
        lastExternalApplication = workspace.frontmostApplication
        if let currentApplication = lastExternalApplication, isSelf(currentApplication) {
            lastExternalApplication = nil
        }
        startObserving()
    }

    deinit {
        if let activationObserver {
            notificationCenter.removeObserver(activationObserver)
        }
    }

    func targetApplication() -> NSRunningApplication? {
        if let currentApplication = workspace.frontmostApplication, !isSelf(currentApplication) {
            return currentApplication
        }
        return lastExternalApplication
    }

    private func startObserving() {
        activationObserver = notificationCenter.addObserver(
            forName: NSWorkspace.didActivateApplicationNotification,
            object: workspace,
            queue: .main
        ) { [weak self] notification in
            guard
                let self,
                let application = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication,
                !self.isSelf(application)
            else {
                return
            }

            // Keep targeting the last external app when the menu bar popup becomes active.
            self.lastExternalApplication = application
        }
    }

    private func isSelf(_ application: NSRunningApplication) -> Bool {
        application.bundleIdentifier == selfBundleIdentifier
    }
}
