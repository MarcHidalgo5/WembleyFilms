//
//  WembleyFilmsTests.swift
//  WembleyFilmsTests
//
//  Created by Marc Hidalgo on 4/6/23.
//

import XCTest
@testable import WembleyFilms

final class WembleyFilmsTests: XCTestCase {
    
    var apiClient: WembleyFilmsAPIClient!
    
    override func setUp() async throws {
        apiClient = WembleyFilmsAPIClient()
    }
    
    func testCreateTokenEndpoint() {
        let createTokenAPI = AuthAPI.createToken
        XCTAssertEqual(createTokenAPI.path, "/authentication/token/new")
        XCTAssertEqual(createTokenAPI.method, .GET)
        XCTAssertEqual(createTokenAPI.parameters?.isEmpty, true)
    }
    
    func testCreateSessionEndpoint() {
        let sessionToken = "example_token"
        let createSessionAPI = AuthAPI.createSession(requestToken: sessionToken)
        XCTAssertEqual(createSessionAPI.path, "authentication/session/new")
        XCTAssertEqual(createSessionAPI.method, .POST)
        XCTAssertEqual(createSessionAPI.parameters?["request_token"] as? String, sessionToken)
    }
    
    // MARK: - UserAPI Tests
    
    func testAccountDetailsEndpoint() {
        let sessionId = "example_session_id"
        let accountDetailsAPI = UserAPI.accountDetails(sessionID: sessionId)
        XCTAssertEqual(accountDetailsAPI.path, "/account")
        XCTAssertEqual(accountDetailsAPI.method, .GET)
        XCTAssertEqual(accountDetailsAPI.parameters?["session_id"] as? String, sessionId)
    }
    
    // MARK: - FilmAPI Tests
    
    func testFilmsEndpoint() {
        let page = 1
        let filmsAPI = FilmAPI.films(page: page)
        XCTAssertEqual(filmsAPI.path, "discover/movie")
        XCTAssertEqual(filmsAPI.method, .GET)
        XCTAssertEqual(filmsAPI.parameters?["page"] as? Int, page)
    }
    
    func testSearchFilmsEndpoint() {
        let searchText = "example_text"
        let page = 1
        let searchFilmsAPI = FilmAPI.searchFilms(text: searchText, page: page)
        XCTAssertEqual(searchFilmsAPI.path, "search/movie")
        XCTAssertEqual(searchFilmsAPI.method, .GET)
        XCTAssertEqual(searchFilmsAPI.parameters?["query"] as? String, searchText)
        XCTAssertEqual(searchFilmsAPI.parameters?["page"] as? Int, page)
    }
    
    func testDetailsEndpoint() {
        let filmID = 123
        let detailsAPI = FilmAPI.details(filmID: filmID)
        XCTAssertEqual(detailsAPI.path, "movie/\(filmID)")
        XCTAssertEqual(detailsAPI.method, .GET)
        XCTAssertEqual(detailsAPI.parameters?.isEmpty, true)
    }
    
    func testFavouriteFilmsEndpoint() {
        let accountId = "example_account_id"
        let sessionId = "example_session_id"
        let page = 1
        let favouriteFilmsAPI = FilmAPI.favouriteFilms(accountId: accountId, sessionId: sessionId, page: page)
        XCTAssertEqual(favouriteFilmsAPI.path, "account/\(accountId)/favorite/movies")
        XCTAssertEqual(favouriteFilmsAPI.method, .GET)
        XCTAssertEqual(favouriteFilmsAPI.parameters?["session_id"] as? String, sessionId)
        XCTAssertEqual(favouriteFilmsAPI.parameters?["page"] as? Int, page)
    }
    
    func testSetFavoriteEndpoint() {
        let accountId = "example_account_id"
        let sessionId = "example_session_id"
        let mediaId = 789
        let isFavourite = true
        let setFavoriteAPI = FilmAPI.setFavorite(accountId: accountId, sessionId: sessionId, mediaId: mediaId, isFavourite: isFavourite)
        XCTAssertEqual(setFavoriteAPI.path, "account/\(accountId)/favorite")
        XCTAssertEqual(setFavoriteAPI.method, .POST)
        XCTAssertEqual(setFavoriteAPI.parameters?["session_id"] as? String, sessionId)
        XCTAssertEqual(setFavoriteAPI.parameters?["media_type"] as? String, "movie")
        XCTAssertEqual(setFavoriteAPI.parameters?["media_id"] as? Int, mediaId)
        XCTAssertEqual(setFavoriteAPI.parameters?["favorite"] as? Bool, isFavourite)
    }
    
    func testIsFavouriteFilmEndpoint() {
        let accountId = "example_account_id"
        let sessionId = "example_session_id"
        let filmID = "example_film_id"
        let isFavouriteFilmAPI = FilmAPI.isFavouriteFilm(accountId: accountId, sessionId: sessionId, filmID: filmID)
        XCTAssertEqual(isFavouriteFilmAPI.path, "account/\(accountId)/favorite/movie/\(filmID)")
        XCTAssertEqual(isFavouriteFilmAPI.method, .GET)
        XCTAssertEqual(isFavouriteFilmAPI.parameters?.isEmpty, true)
    }
}
