//
//  Created by Marc Hidalgo on 2/6/23.
//

import UIKit

protocol DiscoverFilmsDataSourceType {
    func fetchFilmList() async throws -> BaseListViewController.VM
    func fetchNextPage() async throws -> BaseListViewController.VM
    func searchFilms(text: String) async throws -> BaseListViewController.VM
}

class DiscoverFilmsDataSource: DiscoverFilmsDataSourceType {
    
    init(apiClient: WembleyFilmsAPIClient) {
        self.apiClient = apiClient
    }
    
    let apiClient: WembleyFilmsAPIClient
    
    private var nextPage: Int = 1
    private var morePagesAreAvailable: Bool = true
    
    private var mode: Mode = .discoverFilms
    
    enum Mode: Hashable {
        case discoverFilms
        case search(text: String)
    }
    
    func fetchFilmList() async throws -> BaseListViewController.VM {
        self.mode = .discoverFilms
        self.nextPage = 1
        self.morePagesAreAvailable = true
        let pageResult = try await self.apiClient.fetchFilms(page: self.nextPage)
        self.morePagesAreAvailable = {
            pageResult.numberOfPages > self.nextPage
        }()
        self.nextPage += 1
        return .init(films: pageResult.films.viewModel)
    }
    
    func fetchNextPage() async throws -> BaseListViewController.VM {
        guard morePagesAreAvailable else {  return .init(films: []) }
        let pageResult: FilmAPIResponse = try await {
            switch mode {
            case .discoverFilms:
                return try await self.apiClient.fetchFilms(page: self.nextPage)
            case .search(let text):
                return try await self.apiClient.searchFilms(text: text, page: self.nextPage)
            }
        }()
        self.morePagesAreAvailable = {
            pageResult.numberOfPages > self.nextPage
        }()
        self.nextPage += 1
        return .init(films: pageResult.films.viewModel)
    }
    
    func searchFilms(text: String) async throws -> BaseListViewController.VM {
        self.mode = .search(text: text)
        self.nextPage = 1
        self.morePagesAreAvailable = true
        let pageResult = try await self.apiClient.searchFilms(text: text, page: self.nextPage)
        self.morePagesAreAvailable = {
            pageResult.numberOfPages > self.nextPage
        }()
        self.nextPage += 1
        return .init(films: pageResult.films.viewModel)
    }
    
    
    
}

extension Array where Element == Film {
    var viewModel: [BaseListViewController.ImageCell.Configuration] {
        compactMap { element in
            
            let urlString = element.posterPath.flatMap {
                "\(WembleyFilmsAPI.discoverFilmsImagebaseURL)\($0)"
            }
            let url = URL(string: urlString ?? "")
            
            return .init(
                id: element.id,
                imageURL: url,
                title: element.title ?? ""
            )
        }
    }
}

