//
//  Created by Marc Hidalgo on 2/6/23.
//

import Foundation

protocol ListDataSourceType {
    func fetchFilmList() async throws
}

class ListDataSource: ListDataSourceType {
    
    init(apiClient: WembleyFilmsAPIClient) {
        self.apiClient = apiClient
    }
    
    let apiClient: WembleyFilmsAPIClient
    
    func fetchFilmList() async throws { }
}
