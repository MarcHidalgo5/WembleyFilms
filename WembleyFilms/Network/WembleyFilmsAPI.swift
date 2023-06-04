//
//  WembleyFilmsAPI.swift
//  WembleyFilms
//
//  Created by Marc Hidalgo on 3/6/23.
//

import Foundation

public enum WembleyFilmsAPI {
    static let baseURL: URL = URL(string: "https://api.themoviedb.org/3/")!
    static let authenticationBaseURL: URL = URL(string: "https://www.themoviedb.org/authenticate/")!
    static let detailsFilmImagebaseURL: URL = URL(string: "https://image.tmdb.org/t/p/w500")!
    static let discoverFilmsImagebaseURL: URL = URL(string: "https://image.tmdb.org/t/p/w200")!
}
