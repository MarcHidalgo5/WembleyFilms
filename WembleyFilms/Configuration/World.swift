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
    
    var listDataSourceFactory: () -> ListDataSource
    
    init() {
        self.apiClient = WembleyFilmsAPIClient()
        self.listDataSourceFactory = {
            ListDataSource(apiClient: Current.apiClient)
        }
    }
}
