//
//  Created by Marc Hidalgo on 3/6/23.
//

import Foundation

// MARK: - Endpoint
/**
 Protocol used to describe what is needed
 in order to send REST API requests.
*/
public protocol Endpoint {
    
    /// The path for the request
    var path: String { get }
    
    /// The HTTPMethod for the request
    var method: HTTPMethod { get }
    
    /// Optional parameters for the request
    var parameters: [String: Any]? { get }
    
    /// The HTTP headers to be sent
    var httpHeaderFields: [String: String]? { get }

}

public enum HTTPMethod: String {
    case GET, POST, DELETE
}

extension Endpoint {
    var httpHeaderFields: [String: String]? {
        return ["accept": "application/json",
                "Authorization": "Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJlNzZkOGNjYzQyYjE0MjI2ZGZmZDJhNjEwODdmZTM0NiIsInN1YiI6IjY0Nzg5NjgzMGUyOWEyMDEzM2MyM2Q1ZSIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.bRJKiWIidwYzRREft1XWBRVcSSmfrdvpJk0_fpzJlKc"]
    }
}
