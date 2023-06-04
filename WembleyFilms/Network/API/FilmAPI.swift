//
//  Created by Marc Hidalgo on 3/6/23.
//

import Foundation

enum FilmAPI: Endpoint {
    case films(page: Int)
    case searchFilms(text: String, page: Int)
    case details(filmID: String)
    case favouriteFilms(accountId: String, sessionId: String)
    case setFavorite(userID: String, sessionId: String, mediaId: Int, isFavourite: Bool)

    var path: String {
        switch self {
        case .films:
            return "discover/movie"
        case .searchFilms:
            return "search/movie"
        case .details(let filmID):
            return "movie/\(filmID)"
        case .favouriteFilms(let userID, _):
            return "account/\(userID)/favorite/movies"
        case .setFavorite(let userID, _, _, _):
            return "account/\(userID)/favorite"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .films, .searchFilms, .details, .favouriteFilms:
            return .GET
        case .setFavorite:
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
        case .favouriteFilms(_, let sessionId):
            return ["session_id": sessionId]
        case .setFavorite(_, let sessionId, let mediaId, let isFavourite):
            return [
                "session_id": sessionId,
                "media_type": "movie",
                "media_id": mediaId,
                "favorite": isFavourite
            ]
        }
    }
}

