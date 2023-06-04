//
//  Created by Marc Hidalgo on 4/6/23.
//

import Foundation

protocol FilmDetailsDataSourceType {
    func fetchFilmDetails(filmID: String) async throws -> FilmDetailsViewController.VM
}

class FilmDetailsDataSource: FilmDetailsDataSourceType {
    
    init(apiClient: WembleyFilmsAPIClient) {
        self.apiClient = apiClient
    }
    
    let apiClient: WembleyFilmsAPIClient
    
    func fetchFilmDetails(filmID: String) async throws -> FilmDetailsViewController.VM {
        let film = try await self.apiClient.fetchDetails(filmID: filmID)
        return film.viewModel
    }
}

extension Film {
    var viewModel: FilmDetailsViewController.VM {
        let urlString = self.posterPath.flatMap {
            "https://image.tmdb.org/t/p/w500\($0)"
        }
        let url = URL(string: urlString ?? "")
        return .init(image: .init(imageURL: url), information: .init(text: self.overview ?? ""))
    }
}
