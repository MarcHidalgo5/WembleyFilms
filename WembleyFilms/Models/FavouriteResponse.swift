//
//  Created by Marc Hidalgo on 4/6/23.
//

import Foundation

struct MarkFavoriteResponse: Decodable {
    let success: Bool
    let status_code: Int
    let status_message: String
}
