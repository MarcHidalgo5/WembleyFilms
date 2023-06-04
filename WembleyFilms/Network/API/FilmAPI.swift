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
    case details(filmID: String)
    case favorite(accountId: String, sessionId: String, mediaId: Int, isFavourite: Bool)

    var path: String {
        switch self {
        case .films:
            return "discover/movie"
        case .searchFilms:
            return "search/movie"
        case .details(let filmID):
            return "movie/\(filmID)"
        case .favorite(let accountId, _, _, _):
            return "account/\(accountId)/favorite"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .films, .searchFilms, .details:
            return .GET
        case .favorite:
            return .POST
        }
    }
    
    var parameters: [String : Any]? {
        switch self {
        case .films(let page):
            return ["page": page]
        case .searchFilms(let text, let page):
            return [
                "query": text,
                "page": page
            ]
        case .details:
            return [:]
        case .favorite(_, let sessionId, let mediaId, let isFavourite):
            return [
                "session_id": sessionId,
                "media_type": "movie",
                "media_id": mediaId,
                "favorite": isFavourite
            ]
        }
    }
}

