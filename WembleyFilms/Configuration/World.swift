//
//  World.swift
//  WembleyFilms
//
//  Created by Marc Hidalgo on 2/6/23.
//

import Foundation

/// It is the AppDelegate's responsibility to initialise the world
var Current: World!

struct World {
    
    var apiClient: WembleyFilmsAPIClient
    var authenticationDataSource: AuthenticationDataSource
    
    var discoverFilmsDataSourceFactory: () -> DiscoverFilmsDataSourceType
    var favouriteFilmsDataSourceFactory: () -> FavouriteFilmsDataSourceType
    var filmDetaisDataSourceFactory: () -> FilmDetailsDataSourceType
    
    init() {
        self.apiClient = WembleyFilmsAPIClient()
        self.authenticationDataSource = AuthenticationDataSource(apiClient: apiClient)
        
        self.discoverFilmsDataSourceFactory = {
            DiscoverFilmsDataSource(apiClient: Current.apiClient)
        }
        self.favouriteFilmsDataSourceFactory = {
            FavouriteFilmsDataSource(apiClient: Current.apiClient)
        }
        self.filmDetaisDataSourceFactory = {
            FilmDetailsDataSource(apiClient: Current.apiClient)
        }
    }
}

