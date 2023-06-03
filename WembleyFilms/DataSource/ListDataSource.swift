//
//  Created by Marc Hidalgo on 2/6/23.
//

import UIKit

protocol ListDataSourceType {
    func fetchFilmList() async throws -> ListViewController.VM
}

class ListDataSource: ListDataSourceType {
    
    init(apiClient: WembleyFilmsAPIClient) {
        self.apiClient = apiClient
    }
    
    let apiClient: WembleyFilmsAPIClient
    
    private var nextPage: Int = 1
    private(set) var morePagesAreAvailable: Bool = true
    
    func fetchFilmList() async throws -> ListViewController.VM {
        if morePagesAreAvailable {
            let pageResult = try await self.apiClient.fetchFilms(page: self.nextPage)
            self.morePagesAreAvailable = {
                pageResult.numberOfPages > self.nextPage
            }()
            print(nextPage)
            self.nextPage += 1
            return .init(films: pageResult.films.viewModel)
        } else {
            return .init(films: [])
        }
    }
}

extension Array where Element == Film {
    var viewModel: [ListViewController.ImageCell.Configuration] {
        map {
            .init(id: String($0.id), image: UIImage(systemName: "pencil")!)
        }
    }
}
