import Foundation

enum WindowSizeValidationError: Error, Equatable {
    case missingValue
    case notWholeNumber
    case nonPositive

    var message: String {
        switch self {
        case .missingValue:
            return "Enter both width and height."
        case .notWholeNumber:
            return "Width and height must be whole numbers."
        case .nonPositive:
            return "Width and height must be greater than 0."
        }
    }
}

enum WindowSizeParser {
    static func parse(widthText: String, heightText: String) -> Result<WindowSize, WindowSizeValidationError> {
        let trimmedWidth = widthText.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedHeight = heightText.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedWidth.isEmpty, !trimmedHeight.isEmpty else {
            return .failure(.missingValue)
        }

        guard let width = Int(trimmedWidth), let height = Int(trimmedHeight) else {
            return .failure(.notWholeNumber)
        }

        guard width > 0, height > 0 else {
            return .failure(.nonPositive)
        }

        return .success(WindowSize(width: width, height: height))
    }
}
