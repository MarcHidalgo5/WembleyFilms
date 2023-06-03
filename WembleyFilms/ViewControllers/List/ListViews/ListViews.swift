//
//  Created by Marc Hidalgo on 2/6/23.
//

import UIKit

extension ListViewController {
    enum ImageCell {
        struct Configuration: UIContentConfiguration, Hashable, Identifiable {
            init(id: String, image: UIImage, state: UICellConfigurationState? = nil) {
                self.id = id
                self.image = image
                self.state = nil
            }
            
            let id: String
            let image: UIImage
            
            var state: UICellConfigurationState?
            
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
                
                layer.cornerRadius = 12
                layer.masksToBounds = true
                
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
            
            override func layoutSubviews() {
                super.layoutSubviews()
                // Adjust the size of the image to match the size of the cell
                imageView.frame = bounds
            }
            
            func configureFor(configuration: Configuration) {
                imageView.image = configuration.image
            }
        }
    }
    
    enum EmptyCell {
        struct Configuration: UIContentConfiguration, Hashable {
            var state: UICellConfigurationState?
            
            init(state: UICellConfigurationState? = nil) {
                self.state = state
            }
            
            func makeContentView() -> UIView & UIContentView {
                return View(configuration: self)
            }
            
            func updated(for state: UIConfigurationState) -> Self {
                return self
            }
        }
        
        class View: UIView, UIContentView {
            var configuration: UIContentConfiguration
            private let label: UILabel = {
                let label = UILabel()
                label.textAlignment = .center
                return label
            }()
            
            init(configuration: Configuration) {
                self.configuration = configuration
                super.init(frame: .zero)
                
                let title = "It seems that no movie was found"
                label.attributedText = title.createAttributedString(fontSize: 20)
                
                addSubview(label)
                label.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    label.centerXAnchor.constraint(equalTo: centerXAnchor),
                    label.centerYAnchor.constraint(equalTo: centerYAnchor)
                ])
            }
            
            required init?(coder: NSCoder) {
                fatalError("init(coder:) has not been implemented")
            }
        }
    }

}

