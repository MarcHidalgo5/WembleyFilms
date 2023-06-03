//
//  Created by Marc Hidalgo on 3/6/23.
//

import Foundation

struct AuthenticationTokenResponse: Codable {
    let success: Bool
    let expires_at: String
    let request_token: String
}
