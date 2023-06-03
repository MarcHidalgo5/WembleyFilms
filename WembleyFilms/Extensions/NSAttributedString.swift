//
//  Created by Marc Hidalgo on 3/6/23.
//

import Foundation
import UIKit

public extension String {
    func createAttributedString(fontSize: CGFloat = 16, fontWeight: UIFont.Weight = .medium, color: UIColor = .black) -> NSAttributedString {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: fontSize, weight: fontWeight),
            .foregroundColor: color
        ]
        return NSAttributedString(string: self, attributes: attributes)
    }

}
