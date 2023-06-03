//
//  Created by Marc Hidalgo on 3/6/23.
//

import Foundation

public class AuthStorage {
    public static let defaultStorage = AuthStorage()

    private let keychain: Keychain
    
    public init() {
        self.keychain = Keychain(service: Bundle.main.bundleIdentifier!)
    }

    public var userID: String? {
        get { return keychain.get(Keys.UserID) }
        set { keychain.set(Keys.UserID, value: newValue ?? "") }
    }
    
    public var sessionID: String? {
        get { return keychain.get(Keys.SessionID) }
        set { keychain.set(Keys.SessionID, value: newValue ?? "") }
    }

    public func clearKeychain() {
        self.userID = nil
        self.sessionID = nil
    }
}

private struct Keys {
    static let UserID = "UserID"
    static let SessionID = "SessionID"
}


import Security

class Keychain {
    private let service: String

    init(service: String) {
        self.service = service
    }
    
    func set(_ key: String, value: String) {
        if let data = value.data(using: .utf8) {
            let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                        kSecAttrService as String: service,
                                        kSecAttrAccount as String: key,
                                        kSecValueData as String: data]
            SecItemDelete(query as CFDictionary)
            SecItemAdd(query as CFDictionary, nil)
        }
    }

    func get(_ key: String) -> String? {
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrService as String: service,
                                    kSecAttrAccount as String: key,
                                    kSecReturnData as String: kCFBooleanTrue!,
                                    kSecMatchLimit as String: kSecMatchLimitOne]
        var dataTypeRef: AnyObject?
        let status: OSStatus = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        if status == noErr {
            if let data = dataTypeRef as? Data {
                return String(data: data, encoding: .utf8)
            }
        }
        return nil
    }
}
