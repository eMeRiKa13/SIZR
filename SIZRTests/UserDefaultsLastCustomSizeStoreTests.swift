import XCTest
@testable import SIZR

final class UserDefaultsLastCustomSizeStoreTests: XCTestCase {
    private var userDefaults: UserDefaults!

    override func setUp() {
        super.setUp()
        userDefaults = UserDefaults(suiteName: "UserDefaultsLastCustomSizeStoreTests")
        userDefaults.removePersistentDomain(forName: "UserDefaultsLastCustomSizeStoreTests")
    }

    override func tearDown() {
        userDefaults.removePersistentDomain(forName: "UserDefaultsLastCustomSizeStoreTests")
        userDefaults = nil
        super.tearDown()
    }

    func testLoadReturnsNilOnFirstRun() {
        let store = UserDefaultsLastCustomSizeStore(userDefaults: userDefaults)
        XCTAssertNil(store.load())
    }

    func testSavePersistsAndLoadReturnsWindowSize() {
        let store = UserDefaultsLastCustomSizeStore(userDefaults: userDefaults)
        let size = WindowSize(width: 1728, height: 1117)

        store.save(size)

        XCTAssertEqual(store.load(), size)
    }

    func testLoadIgnoresInvalidPersistedValues() {
        userDefaults.set(0, forKey: UserDefaultsLastCustomSizeStore.widthKey)
        userDefaults.set(1117, forKey: UserDefaultsLastCustomSizeStore.heightKey)

        let store = UserDefaultsLastCustomSizeStore(userDefaults: userDefaults)

        XCTAssertNil(store.load())
    }
}
