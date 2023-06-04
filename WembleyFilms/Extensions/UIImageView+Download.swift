//
//  Created by Marc Hidalgo on 3/6/23.
//

import UIKit
import Nuke

extension UIImageView {
    func setImageWithURL(_ url: URL) {
        let request = ImageRequest(url: url)
        
        ImagePipeline.shared.loadImage(with: request) { result in
            switch result {
            case .success(let response):
                DispatchQueue.main.async {
                    self.image = response.image
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}


