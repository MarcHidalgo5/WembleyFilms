//
//  Created by Marc Hidalgo on 1/6/23.
//

import UIKit
import AuthenticationServices

protocol ASWebAuthenticationViewController: UIViewController, ASWebAuthenticationPresentationContextProviding { }

protocol StartViewControllerDelegate: AnyObject {
    func didFinishLogin()
}

class StartViewController: UIViewController {
    
    init(delegate: StartViewControllerDelegate) {
        self.delegate = delegate
        self.dataSource = Current.authenticationDataSource
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let dataSource: AuthenticationDataSourceType
    private weak var delegate: StartViewControllerDelegate?
    
    private var startButton: UIButton!
    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "wembleyStudios.png")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    override func loadView() {
        super.loadView()
        view = UIView()
        view.backgroundColor = .white
        
        startButton = {
            var configuration = UIButton.Configuration.filled()
            configuration.attributedTitle = AttributedString("Start", attributes: AttributeContainer([NSAttributedString.Key.font : UIFont.systemFont(ofSize: 20, weight: .bold)]))
            configuration.baseBackgroundColor = .black
            configuration.buttonSize = .large
            return .init(configuration: configuration, primaryAction: UIAction(handler: { [weak self] _ in
                self?.startLogin()
            }))
        }()
        
        startButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(logoImageView)
        view.addSubview(startButton)
        
        NSLayoutConstraint.activate([
            logoImageView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
            logoImageView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 20),
            logoImageView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
            logoImageView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 20),
            
            startButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            startButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    override func viewDidLoad() { }
    
    private func startLogin() {
        startButton.isUserInteractionEnabled = false
        Task { @MainActor in
            do {
                try await dataSource.login(fromVC: self)
                self.delegate?.didFinishLogin()
                startButton.isUserInteractionEnabled = true
            } catch {
                startButton.isUserInteractionEnabled = true
                showErrorAlert("Failed to login", error: error)
            }
            
        }
    }
}

extension StartViewController: ASWebAuthenticationViewController {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return view.window!
    }
}
