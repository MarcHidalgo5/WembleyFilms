//
//  Created by Marc Hidalgo on 3/6/23.
//

import UIKit
import AuthenticationServices

protocol AuthenticationDataSourceType {
    
    var userID: String? { get }
    var sessionID: String? { get }
    
    func login(fromVC: ASWebAuthenticationViewController)  async throws
}

extension AuthenticationDataSourceType {
    var containsValidSession: Bool {
        guard (userID != nil) && (sessionID != nil) else {
            return false
        }
        return true
    }
}

class AuthenticationDataSource: AuthenticationDataSourceType {

    init(apiClient: WembleyFilmsAPIClient) {
        self.apiClient = apiClient
        self.authStorage = AuthStorage()
        
        apiClient.userID = userID
        apiClient.userSessionID = sessionID
    }
    
    private let authStorage: AuthStorage
    private let apiClient: WembleyFilmsAPIClient
    
    public var userID: String? {
        get {
            return authStorage.userID
        } set {
            apiClient.userID = newValue
            authStorage.userID = newValue
        }
    }
    
    public var sessionID: String? {
        get {
            return authStorage.sessionID
        } set {
            apiClient.userSessionID = newValue
            authStorage.sessionID = newValue
        }
    }
    
    func login(fromVC: ASWebAuthenticationViewController) async throws {
        let result = try await self.apiClient.createRequestToken()
        
        let callbackURL = try await authenticateSession(fromVC: fromVC, requestToken: result.request_token)
        let queryItems = URLComponents(string: callbackURL.absoluteString)?.queryItems

        guard let requestToken = queryItems?.first(where: { $0.name == "request_token" })?.value else {
            throw NSError(domain: "Request Token Error", code: 3, userInfo: [NSLocalizedDescriptionKey: "Request token not found"])
        }
        let userSessionID = try await self.apiClient.createSession(requestToken: requestToken).session_id
        let account = try await self.apiClient.getAccountDetails(sessionId: userSessionID)
        self.userID = String(account.id)
        self.sessionID = userSessionID
        
    }
    
    @MainActor
    private func authenticateSession(fromVC: ASWebAuthenticationViewController, requestToken: String) async throws -> URL {
        let authURL = URL(string: "\(WembleyFilmsAPI.authenticationBaseURL)\(requestToken)?redirect_to=wembleyFilms://auth")!
        let callbackURLScheme = "wembleyFilms"
        return try await withCheckedThrowingContinuation { continuation in
            let authenticationSession = ASWebAuthenticationSession(url: authURL, callbackURLScheme: callbackURLScheme) { callbackURL, error in
                    
                if let error = error {
                    continuation.resume(throwing: NSError(domain: "Authentication Error", code: 1, userInfo: [NSLocalizedDescriptionKey: "Error authenticating: \(error.localizedDescription)"]))
                    return
                }
                    
                guard let callbackURL = callbackURL else {
                    continuation.resume(throwing: NSError(domain: "Invalid Callback URL", code: 2, userInfo: [NSLocalizedDescriptionKey: "No valid callback URL"]))
                    return
                }
                    
                continuation.resume(returning: callbackURL)
            }
            authenticationSession.presentationContextProvider = fromVC
            authenticationSession.start()
        }
    }
}
