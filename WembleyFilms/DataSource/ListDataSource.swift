//
//  Created by Marc Hidalgo on 2/6/23.
//

import UIKit

protocol ListDataSourceType {
    func fetchFilmList() async throws -> ListViewController.VM
    func fetchNextPage() async throws -> ListViewController.VM
    func searchFilms(text: String) async throws -> ListViewController.VM
}

class ListDataSource: ListDataSourceType {
    
    init(apiClient: WembleyFilmsAPIClient) {
        self.apiClient = apiClient
    }
    
    let apiClient: WembleyFilmsAPIClient
    
    private var nextPage: Int = 1
    private(set) var morePagesAreAvailable: Bool = true
    
    private var mode: Mode = .discoverFilms
    
    enum Mode: Hashable {
        case discoverFilms
        case search(text: String)
    }
    
    func fetchFilmList() async throws -> ListViewController.VM {
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
    
    func fetchNextPage() async throws -> ListViewController.VM {
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
    
    func searchFilms(text: String) async throws -> ListViewController.VM {
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
    var viewModel: [ListViewController.ImageCell.Configuration] {
        compactMap { element in
            
            let urlString = element.posterPath.flatMap {
                "https://image.tmdb.org/t/p/w200\($0)"
            }
            let url = URL(string: urlString ?? "")
            
            return .init(
                id: String(element.id),
                imageURL: url,
                title: element.title ?? ""
            )
        }
    }
}

