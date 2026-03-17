import Foundation

final class UserDefaultsLastCustomSizeStore: LastCustomSizeStoring {
    static let widthKey = "lastCustomWidth"
    static let heightKey = "lastCustomHeight"

    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
    }

    func load() -> WindowSize? {
        guard
            let widthNumber = userDefaults.object(forKey: Self.widthKey) as? NSNumber,
            let heightNumber = userDefaults.object(forKey: Self.heightKey) as? NSNumber
        else {
            return nil
        }

        let width = widthNumber.intValue
        let height = heightNumber.intValue

        guard width > 0, height > 0 else {
            return nil
        }

        return WindowSize(width: width, height: height)
    }

    func save(_ size: WindowSize) {
        userDefaults.set(size.width, forKey: Self.widthKey)
        userDefaults.set(size.height, forKey: Self.heightKey)
    }
}
