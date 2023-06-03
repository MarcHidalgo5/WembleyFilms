//
//  Created by Marc Hidalgo on 3/6/23.
//

import Foundation

public class AuthStorage {
    public static let defaultStorage = AuthStorage()

    private let userDefaultsStorage: UserDefaultsStorage
    
    public init() {
        self.userDefaultsStorage = UserDefaultsStorage()
    }

    public var userID: String? {
        get { return userDefaultsStorage.get(Keys.UserID) }
        set { userDefaultsStorage.set(Keys.UserID, value: newValue ?? "") }
    }
    
    public var sessionID: String? {
        get { return userDefaultsStorage.get(Keys.SessionID) }
        set { userDefaultsStorage.set(Keys.SessionID, value: newValue ?? "") }
    }

    public func clearUserDefaults() {
        self.userID = nil
        self.sessionID = nil
    }
}

private struct Keys {
    static let UserID = "UserID"
    static let SessionID = "SessionID"
}


class UserDefaultsStorage {
    private let defaults = UserDefaults.standard

    func set(_ key: String, value: String) {
        defaults.set(value, forKey: key)
    }

    func get(_ key: String) -> String? {
        return defaults.string(forKey: key)
    }
}

