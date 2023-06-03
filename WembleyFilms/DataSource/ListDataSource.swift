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
    
    func fetchFilmList() async throws -> ListViewController.VM {
        return .init(films: [
            .init(id:  UUID().uuidString, image: UIImage(systemName: "pencil")!),
            .init(id:  UUID().uuidString, image: UIImage(systemName: "pencil")!),
            .init(id:  UUID().uuidString, image: UIImage(systemName: "pencil")!),
            .init(id:  UUID().uuidString, image: UIImage(systemName: "pencil")!),
            .init(id:  UUID().uuidString, image: UIImage(systemName: "pencil")!)
        ])
    }
}
