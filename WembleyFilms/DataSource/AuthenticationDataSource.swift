//
//  Created by Marc Hidalgo on 3/6/23.
//

import UIKit

protocol AuthenticationDataSourceType {
    func login() async throws
}

class AuthenticationDataSource: AuthenticationDataSourceType {
    
    init(apiClient: WembleyFilmsAPIClient) {
        self.apiClient = apiClient
    }
    
    let apiClient: WembleyFilmsAPIClient
    
    func login() async throws {
        
    }
}
