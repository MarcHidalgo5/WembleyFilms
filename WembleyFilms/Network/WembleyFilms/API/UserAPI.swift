//
//  Created by Marc Hidalgo on 3/6/23.
//

import Foundation

enum UserAPI: Endpoint {
    case accountDetails(sessionID: String)

    var path: String {
        switch self {
        case .accountDetails:
            return "/account"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .accountDetails:
            return .GET
       
        }
    }
    
    var parameters: [String : Any]? {
        switch self {
        case .accountDetails(let sessionID):
            return ["session_id": sessionID]
        }
    }
}
