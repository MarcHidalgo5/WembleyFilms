//
//  Created by Marc Hidalgo on 3/6/23.
//

import Foundation

enum FilmAPI: Endpoint {
    case films(page: Int)
    case searchFilms(text: String, page: Int)
    case details(filmID: String)
    case favouriteFilms(accountId: String, sessionId: String, page: Int)
    case setFavorite(accountId: String, sessionId: String, mediaId: Int, isFavourite: Bool)
    case isFavouriteFilm(accountId: String, sessionId: String, filmID: String)

    var path: String {
        switch self {
        case .films:
            return "discover/movie"
        case .searchFilms:
            return "search/movie"
        case .details(let filmID):
            return "movie/\(filmID)"
        case .favouriteFilms(let accountId, _, _):
            return "account/\(accountId)/favorite/movies"
        case .setFavorite(let accountId, _, _, _):
            return "account/\(accountId)/favorite"
        case .isFavouriteFilm(let accountId, _, let filmID):
            return "account/\(accountId)/favorite/movie/\(filmID)"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .films, .searchFilms, .details, .favouriteFilms, .isFavouriteFilm:
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
        case .details, .isFavouriteFilm:
            return [:]
        case .favouriteFilms(_, let sessionId, let page):
            return [
                "session_id": sessionId,
                "page": page
            ]
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
