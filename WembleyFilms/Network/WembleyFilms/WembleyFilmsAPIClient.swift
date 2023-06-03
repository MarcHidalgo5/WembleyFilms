//
//  Created by Marc Hidalgo on 2/6/23.
//

import Foundation

class WembleyFilmsAPIClient {
    
    init() { }
    
    var userSessionID: String?
    var userID: String?
    
    func createRequestToken() async throws -> AuthenticationTokenResponse {
        let endpoint = AuthAPI.createToken
        return try await fetch(from: endpoint)
    }
}
