//
//  Created by Marc Hidalgo on 4/6/23.
//

import Foundation

protocol FavouriteFilmsDataSourceType {
    func fetchFavouriteFilms() async throws -> BaseListViewController.VM
    func fetchFavouriteFilmsNextPage() async throws -> BaseListViewController.VM
}

class FavouriteFilmsDataSource: FavouriteFilmsDataSourceType {
    
    init(apiClient: WembleyFilmsAPIClient) {
        self.apiClient = apiClient
    }
    
    let apiClient: WembleyFilmsAPIClient
    
    private var nextPage: Int = 1
    private var morePagesAreAvailable: Bool = true

    func fetchFavouriteFilms() async throws -> BaseListViewController.VM {
        self.nextPage = 1
        self.morePagesAreAvailable = true
        let pageResult =  try await self.apiClient.fetchFavouritesFilms(page: self.nextPage)
        self.morePagesAreAvailable = {
            pageResult.numberOfPages > self.nextPage
        }()
        self.nextPage += 1
        return .init(films: pageResult.films.viewModel)
    }

    func fetchFavouriteFilmsNextPage() async throws -> BaseListViewController.VM {
        guard morePagesAreAvailable else {  return .init(films: []) }
        let pageResult =  try await self.apiClient.fetchFavouritesFilms(page: self.nextPage)
        self.morePagesAreAvailable = {
            pageResult.numberOfPages > self.nextPage
        }()
        self.nextPage += 1
        return .init(films: pageResult.films.viewModel)
    }
}


