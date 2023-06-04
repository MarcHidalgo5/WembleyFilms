//
//  FilmDetailsViews.swift
//  WembleyFilms
//
//  Created by Marc Hidalgo on 4/6/23.
//

import UIKit

enum ImageCell {
    struct Configuration: UIContentConfiguration, Hashable {
        let imageURL: URL?

        init(imageURL: URL?) {
            self.imageURL = imageURL
        }
        
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
            
            layer.cornerRadius = 12
            layer.masksToBounds = true
            
            addSubview(imageView)
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
            imageView.frame = bounds
        }
        
        func configureFor(configuration: Configuration) {
            guard let url = configuration.imageURL else { return }
            imageView.setImageWithURL(url)
        }
    }
}

enum TextCell {
    struct Configuration: UIContentConfiguration, Hashable {
        let text: String

        init(text: String) {
            self.text = text
        }
        
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
    
        let label: UILabel = {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.numberOfLines = 0
            label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
            label.textAlignment = .justified
            return label
        }()
        
        init(configuration: Configuration) {
            self.configuration = configuration
            super.init(frame: .zero)
                       
            backgroundColor = .white
            
            layer.cornerRadius = 10            
            
            self.clipsToBounds = false
            self.layer.shadowColor = UIColor.black.cgColor
            self.layer.shadowOffset = CGSize(width: 0, height: 2)
            self.layer.shadowOpacity = 0.4
            self.layer.shadowRadius = 2
            
            addSubview(label)
            NSLayoutConstraint.activate([
                label.topAnchor.constraint(equalTo: topAnchor, constant: 10),
                label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
                label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
                label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
            ])
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func configureFor(configuration: Configuration) {
            label.text = configuration.text
            
        }
    }
}

enum ButtonCell {
    struct Configuration: UIContentConfiguration, Hashable {
        
        let isFavourite: Bool
        
        func makeContentView() -> UIView & UIContentView {
            return View(configuration: self)
        }
        
        func updated(for state: UIConfigurationState) -> Self {
            return self
        }
    }
    
    class View: UIView, UIContentView {
        
        let button: UIButton = {
            var configuration = UIButton.Configuration.filled()
            configuration.buttonSize = .large
            configuration.baseBackgroundColor = .black
            return UIButton(configuration: configuration)
        }()
        
        
        var configuration: UIContentConfiguration {
            didSet {
                guard let config = configuration as? Configuration else { return }
                configureFor(configuration: config)
            }
        }

        init(configuration: Configuration) {
            self.configuration = configuration
            super.init(frame: .zero)
            
            button.isUserInteractionEnabled = false
            button.translatesAutoresizingMaskIntoConstraints = false
            button.clipsToBounds = false
            button.layer.shadowColor = UIColor.black.cgColor
            button.layer.shadowOffset = CGSize(width: 0, height: 2)
            button.layer.shadowOpacity = 0.4
            button.layer.shadowRadius = 2
            
            addSubview(button)
            NSLayoutConstraint.activate([
                button.centerXAnchor.constraint(equalTo: centerXAnchor),
                button.centerYAnchor.constraint(equalTo: centerYAnchor)
            ])
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func configureFor(configuration: Configuration) {
            button.configurationUpdateHandler = { button in
                if configuration.isFavourite {
                    button.configuration?.attributedTitle = AttributedString("Remove from favorites", attributes: AttributeContainer([NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16, weight: .medium)]))
                    button.configuration?.baseForegroundColor = .red
                } else {
                    button.configuration?.attributedTitle = AttributedString("Add to favorites", attributes: AttributeContainer([NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16, weight: .medium)]))
                    button.configuration?.baseForegroundColor = .yellow
                }
            }
            
        }
    }
}
