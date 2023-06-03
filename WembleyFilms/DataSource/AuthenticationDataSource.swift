//
//  Created by Marc Hidalgo on 3/6/23.
//

import UIKit
import AuthenticationServices

protocol AuthenticationDataSourceType {
    func login(fromVC: ASWebAuthenticationViewController)  async throws
}

class AuthenticationDataSource: AuthenticationDataSourceType {

    init(apiClient: WembleyFilmsAPIClient) {
        self.apiClient = apiClient
    }
    
    let apiClient: WembleyFilmsAPIClient
    
    func login(fromVC: ASWebAuthenticationViewController) async throws {
        let result = try await apiClient.createRequestToken()
        
        let callbackURL = try await authenticateSession(fromVC: fromVC, requestToken: result.request_token)
        let queryItems = URLComponents(string: callbackURL.absoluteString)?.queryItems

        guard let requestToken = queryItems?.first(where: { $0.name == "request_token" })?.value else {
            throw NSError(domain: "Request Token Error", code: 3, userInfo: [NSLocalizedDescriptionKey: "Request token not found"])
        }
        print(requestToken)
        
    }
    
    @MainActor
    func authenticateSession(fromVC: ASWebAuthenticationViewController, requestToken: String) async throws -> URL {
        let authURL = URL(string: "https://www.themoviedb.org/authenticate/\(requestToken)?redirect_to=wembleyFilms://auth")!
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
