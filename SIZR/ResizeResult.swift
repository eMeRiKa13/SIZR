import Foundation

enum StatusTone: Equatable {
    case success
    case error
    case info
}

struct StatusPresentation: Equatable {
    let tone: StatusTone
    let message: String
}

enum ResizeResult: Equatable {
    case success(WindowSize)
    case permissionRequired
    case noFrontmostApplication
    case noCompatibleWindow
    case windowNotResizable
    case invalidInput(String)
    case failure(String)

    var statusPresentation: StatusPresentation {
        switch self {
        case .success(let size):
            return StatusPresentation(
                tone: .success,
                message: "Resized the front window to \(size.dimensionsText)."
            )
        case .permissionRequired:
            return StatusPresentation(
                tone: .error,
                message: "Allow Accessibility access to resize windows."
            )
        case .noFrontmostApplication:
            return StatusPresentation(
                tone: .error,
                message: "No frontmost app is available to resize."
            )
        case .noCompatibleWindow:
            return StatusPresentation(
                tone: .error,
                message: "No compatible front window was found."
            )
        case .windowNotResizable:
            return StatusPresentation(
                tone: .error,
                message: "The front window cannot be resized right now."
            )
        case .invalidInput(let message):
            return StatusPresentation(tone: .error, message: message)
        case .failure(let message):
            return StatusPresentation(tone: .error, message: message)
        }
    }
}
