//
//  Created by Marc Hidalgo on 4/6/23.
//

import Foundation

protocol FilmDetailsDataSourceType {
    func fetchFilmDetails(filmID: Int) async throws -> FilmDetailsViewController.VM
    func setFavourite(filmID: Int, isFavourite: Bool) async throws
}

class FilmDetailsDataSource: FilmDetailsDataSourceType {
    
    init(apiClient: WembleyFilmsAPIClient) {
        self.apiClient = apiClient
    }
    
    let apiClient: WembleyFilmsAPIClient
    
    func fetchFilmDetails(filmID: Int) async throws -> FilmDetailsViewController.VM {
        let film = try await self.apiClient.fetchDetails(filmID: filmID)
        var viewModel = film.viewModel
        viewModel.isFavourite = try await isFavourite(filmID: filmID)
        return viewModel
    }
    
    func setFavourite(filmID: Int, isFavourite: Bool) async throws {
        _ = try await self.apiClient.setFavourite(filmID: filmID, isFavourite: isFavourite)
    }
    
    func isFavourite(filmID: Int) async throws -> Bool {
        let favouritFilms = try await self.apiClient.fetchFavouritesFilms(page: 1).films
        return favouritFilms.contains { $0.id == filmID }
    }
}

extension Film {
    var viewModel: FilmDetailsViewController.VM {
        let urlString = self.posterPath.flatMap {
            "\(WembleyFilmsAPI.detailsFilmImagebaseURL)\($0)"
        }
        let url = URL(string: urlString ?? "")
        return .init(title: self.title ?? "", imageConfig: .init(imageURL: url), informationConfig: .init(text: self.overview ?? ""))
    }
}
