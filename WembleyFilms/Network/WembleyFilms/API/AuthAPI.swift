//
//  Created by Marc Hidalgo on 3/6/23.
//

import Foundation

enum AuthAPI: Endpoint {
    case createToken
    case createSession(requestToken: String)
    case authorizeRequestToken(requestToken: String)

    var path: String {
        switch self {
        case .createToken:
            return "/authentication/token/new"
        case .createSession:
            return "authentication/session/new"
        case .authorizeRequestToken(let requestToken):
            return "/authenticate/\(requestToken)?redirect_to=wembleyFilms://auth"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .createToken, .authorizeRequestToken:
            return .GET
        case .createSession:
            return .POST
        }
    }
    
    var parameters: [String : Any]? {
        switch self {
        case .createToken:
            return [:]
        case .createSession(let requestToken):
            return ["request_token": requestToken]
        case .authorizeRequestToken:
            return [:]
            return ["redirect_to": "wembleyFilms://auth"]
        }
    }
}
