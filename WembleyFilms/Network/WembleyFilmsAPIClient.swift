//
//  Created by Marc Hidalgo on 2/6/23.
//

import Foundation

class WembleyFilmsAPIClient {
    
    var session: URLSession
    
    init(session: URLSession = URLSession.shared) {
        self.session = session
    }
    
    var userSessionID: String?
    var userID: String?
    
    func createRequestToken() async throws -> AuthenticationTokenResponse {
        let endpoint = AuthAPI.createToken
        return try await fetch(from: endpoint)
    }
    
    func createSession(requestToken: String) async throws -> CreateSessionResponse {
        let endpoint = AuthAPI.createSession(requestToken: requestToken)
        return try await fetch(from: endpoint)
    }
    
    func getAccountDetails(sessionId: String) async throws -> User {
        let endpoint = UserAPI.accountDetails(sessionID: sessionId)
        return try await fetch(from: endpoint)
    }
    
    func fetchFilms(page: Int) async throws -> FilmAPIResponse {
        let endpoint = FilmAPI.films(page: page)
        return try await fetch(from: endpoint)
    }
    
    func searchFilms(text: String, page: Int) async throws -> FilmAPIResponse {
        let endpoint = FilmAPI.searchFilms(text: text, page: page)
        return try await fetch(from: endpoint)
    }
    
    func fetchDetails(filmID: Int) async throws -> Film {
        let endpoint = FilmAPI.details(filmID: filmID)
        return try await fetch(from: endpoint)
    }
    
    func fetchFavouritesFilms(page: Int) async throws -> FilmAPIResponse {
        guard let userID, let userSessionID else { throw APIClientError.invalidSession }
        let endpoint = FilmAPI.favouriteFilms(accountId: userID, sessionId: userSessionID, page: page)
        return try await fetch(from: endpoint)
    }
    
    func setFavourite(filmID: Int, isFavourite: Bool) async throws -> MarkFavoriteResponse {
        guard let userID, let userSessionID else { throw APIClientError.invalidSession }
        let endpoint = FilmAPI.setFavorite(accountId: userID, sessionId: userSessionID, mediaId: filmID, isFavourite: isFavourite)
        return try await fetch(from: endpoint)        
    }
    
    enum APIClientError: Error {
        case invalidSession
    }
}

