//
//  Created by Marc Hidalgo on 3/6/23.
//

//
//  Created by Marc Hidalgo on 3/6/23.
//

import Foundation

enum FilmAPI: Endpoint {
    case films(page: Int)
    case searchFilms(text: String, page: Int)

    var path: String {
        switch self {
        case .films:
            return "discover/movie"
        case .searchFilms:
            return "search/movie"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .films, .searchFilms:
            return .GET
        }
    }
    
    var parameters: [String : Any]? {
        switch self {
        case .films(let page):
            return ["page": page]
        case .searchFilms(let text, let page):
            return ["query": text, "page": page]
        }
    }
}

