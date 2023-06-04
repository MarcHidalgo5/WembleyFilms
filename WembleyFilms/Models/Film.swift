//
//  Created by Marc Hidalgo on 3/6/23.
//

import Foundation

struct Film {
    let id: Int
    let title: String?
    let posterPath: String?
    let releaseDate: String?
    let overview: String?
}

extension Film: Decodable {

    enum FilmCodingKeys: String, CodingKey {
        case id
        case posterPath = "poster_path"
        case title
        case releaseDate = "release_date"
        case overview
    }

    init(from decoder: Decoder) throws {
        let movieContainer = try decoder.container(keyedBy: FilmCodingKeys.self)
        id = try movieContainer.decode(Int.self, forKey: .id)
        posterPath = try? movieContainer.decode(String.self, forKey: .posterPath)
        title = try? movieContainer.decode(String.self, forKey: .title)
        releaseDate = try? movieContainer.decode(String.self, forKey: .releaseDate)
        overview = try? movieContainer.decode(String.self, forKey: .overview)
    }
}

struct FilmAPIResponse {
    let page: Int
    let numberOfPages: Int
    let films: [Film]
}

extension FilmAPIResponse: Decodable {

    private enum FilmAPIResponseCodingKeys: String, CodingKey {
        case page
        case numberOfPages = "total_pages"
        case movies = "results"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: FilmAPIResponseCodingKeys.self)
        page = try container.decode(Int.self, forKey: .page)
        numberOfPages = try container.decode(Int.self, forKey: .numberOfPages)
        films = try container.decode([Film].self, forKey: .movies)
    }
}
