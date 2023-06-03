//
//  Created by Marc Hidalgo on 3/6/23.
//

import Foundation

enum FilmAPI: Endpoint {
    case films(page: Int)

    var path: String {
        switch self {
        case .films:
            return "discover/movie"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .films:
            return .GET
        }
    }
    
    var parameters: [String : Any]? {
        switch self {
        case .films(let page):
            return ["page": page]
        }
    }
}


