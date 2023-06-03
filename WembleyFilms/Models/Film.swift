//
//  Created by Marc Hidalgo on 3/6/23.
//

import Foundation

struct Film: Codable {
    let id: String
    let title: String
    let posterPath: String
    let releaseDate: String

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case posterPath = "poster_path"
        case releaseDate = "release_date"
    }
}

extension Film {
    struct Response: Codable {
        let page: Int
        let results: [Film]
        let totalResults: Int
        let totalPages: Int

        enum CodingKeys: String, CodingKey {
            case page
            case results
            case totalResults = "total_results"
            case totalPages = "total_pages"
        }
    }
}




