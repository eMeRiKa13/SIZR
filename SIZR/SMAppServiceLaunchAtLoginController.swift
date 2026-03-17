import ServiceManagement

final class SMAppServiceLaunchAtLoginController: LaunchAtLoginControlling {
    func status() -> LaunchAtLoginStatus {
        switch SMAppService.mainApp.status {
        case .enabled:
            return .enabled
        case .requiresApproval:
            return .requiresApproval
        default:
            return .disabled
        }
    }

    func setEnabled(_ enabled: Bool) throws -> LaunchAtLoginStatus {
        let currentStatus = status()

        if enabled {
            if currentStatus == .disabled {
                try SMAppService.mainApp.register()
            }
        } else if currentStatus != .disabled {
            try SMAppService.mainApp.unregister()
        }

        return status()
    }
}
