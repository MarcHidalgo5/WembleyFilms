//
//  Created by Marc Hidalgo on 4/6/23.
//

import UIKit

extension BaseListViewController {
    enum ImageCell {
        struct Configuration: UIContentConfiguration, Hashable, Identifiable {
            init(id: String, imageURL: URL?, title: String?, state: UICellConfigurationState? = nil) {
                self.id = id
                self.imageURL = imageURL
                self.title = title
                self.state = nil
            }
            
            let id: String
            let imageURL: URL?
            let title: String?
            
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
            
            let blurEffectView: UIVisualEffectView = {
                let blurEffect = UIBlurEffect(style: .light)
                let blurEffectView = UIVisualEffectView(effect: blurEffect)
                blurEffectView.translatesAutoresizingMaskIntoConstraints = false
                return blurEffectView
            }()
            
            let label: UILabel = {
                let label = UILabel()
                label.translatesAutoresizingMaskIntoConstraints = false
                label.numberOfLines = 0
                label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
                label.textAlignment = .center
                return label
            }()
            
            init(configuration: Configuration) {
                self.configuration = configuration
                super.init(frame: .zero)
                blurEffectView.alpha = 0.5
                imageView.backgroundColor = .white
    
                layer.cornerRadius = 12
                layer.masksToBounds = true
                
                addSubview(imageView)
                addSubview(blurEffectView)
                addSubview(label)

                NSLayoutConstraint.activate([
                    imageView.topAnchor.constraint(equalTo: topAnchor),
                    imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
                    imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
                    imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
                    
                    blurEffectView.topAnchor.constraint(equalTo: topAnchor),
                    blurEffectView.leadingAnchor.constraint(equalTo: leadingAnchor),
                    blurEffectView.trailingAnchor.constraint(equalTo: trailingAnchor),
                    blurEffectView.bottomAnchor.constraint(equalTo: bottomAnchor),
                    
                    label.topAnchor.constraint(equalTo: topAnchor),
                    label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5),
                    label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5),
                    label.bottomAnchor.constraint(equalTo: bottomAnchor),
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
                label.text = configuration.title ?? ""
                guard let url = configuration.imageURL else { return }
                imageView.setImageWithURL(url)
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


