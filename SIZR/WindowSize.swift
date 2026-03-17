import Foundation

struct WindowSize: Equatable, Codable {
    let width: Int
    let height: Int

    static let hd = WindowSize(width: 1920, height: 1080)

    var dimensionsText: String {
        "\(width)\u{00D7}\(height)"
    }
}
