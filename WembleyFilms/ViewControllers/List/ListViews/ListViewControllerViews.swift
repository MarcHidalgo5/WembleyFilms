//
//  Created by Marc Hidalgo on 2/6/23.
//

import UIKit

class ImageCell: UICollectionViewCell {
    
    struct Configuration: UIContentConfiguration, Hashable, Identifiable {
        init(id: String, image: UIImage) {
            self.id = id
            self.image = image
        }
        
        let id: String
        let image: UIImage
        
        func makeContentView() -> UIView & UIContentView {
            return View(configuration: self)
        }
        
        func updated(for state: UIConfigurationState) -> Self {
            return self
        }
    }
    
    class View: UIView, UIContentView {
        var configuration: UIContentConfiguration {
            didSet {
                guard let config = configuration as? Configuration else { return }
                configureFor(configuration: config)
            }
        }
        
        let imageView: UIImageView = {
            let imageView = UIImageView()
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.contentMode = .scaleAspectFill
            return imageView
        }()
        
        init(configuration: Configuration) {
            self.configuration = configuration
            super.init(frame: .zero)
            addSubview(imageView)
            imageView.backgroundColor = .red
            NSLayoutConstraint.activate([
                imageView.topAnchor.constraint(equalTo: topAnchor),
                imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
                imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
                imageView.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func configureFor(configuration: Configuration) {
            imageView.image = configuration.image
        }
    }
}
