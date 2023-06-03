//
//  Created by Marc Hidalgo on 3/6/23.
//

import Foundation

struct User : Codable {
    let id: Int
    let name: String?
    let username: String?

    var displayName: String {
        if let name = name, !name.isEmpty {
            return name
        }
        return username ?? "(unknown)"
    }
}
