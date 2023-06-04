//
//  Created by Marc Hidalgo on 2/6/23.
//

import Foundation

class WembleyFilmsAPIClient {
    
    init() { }
    
    let session = URLSession(configuration: .default)
    
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
    
    func fetchDetails(filmID: String) async throws -> Film {
        let endpoint = FilmAPI.details(filmID: filmID)
        return try await fetch(from: endpoint)
    }
    
    func fetchFavouritesFilms(page: Int) async throws -> FilmAPIResponse {
        #warning("Throw")
        guard let userID, let userSessionID else { fatalError() }
        let endpoint = FilmAPI.favouriteFilms(accountId: userID, sessionId: userSessionID, page: page)
        return try await fetch(from: endpoint)
    }
    
    func setFavourite(filmID: String, isFavourite: Bool) async throws -> MarkFavoriteResponse {
        #warning("Throw")
        guard let userID, let userSessionID, let filmID = Int(filmID) else { fatalError() }
        let endpoint = FilmAPI.setFavorite(accountId: userID, sessionId: userSessionID, mediaId: filmID, isFavourite: isFavourite)
        return try await fetch(from: endpoint)
        
    }
}
