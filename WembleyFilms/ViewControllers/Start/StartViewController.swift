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
    
    private var activityIndicator: UIActivityIndicatorView!
    private var blurEffectView: UIVisualEffectView!
    
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
        
        blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
        blurEffectView.translatesAutoresizingMaskIntoConstraints = false
        blurEffectView.isHidden = true // Inicia oculto
        view.addSubview(blurEffectView)
        
        NSLayoutConstraint.activate([
            logoImageView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
            logoImageView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 20),
            logoImageView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
            logoImageView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 20),
            
            startButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            startButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            
            blurEffectView.topAnchor.constraint(equalTo: self.view.topAnchor),
            blurEffectView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            blurEffectView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            blurEffectView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
        ])
    }
    
    override func viewDidLoad() {
        configureActivityIndicator()
    }
    
    private func configureActivityIndicator() {
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
        ])
    }
    
    // MARK: Loading State Management
    
    func startLoading() {
        activityIndicator.startAnimating()
        blurEffectView.isHidden = false
        startButton.isUserInteractionEnabled = false
    }
    
    func stopLoading() {
        activityIndicator.stopAnimating()
        blurEffectView.isHidden = true
        startButton.isUserInteractionEnabled = true
    }
    
    //MARK: Private
    
    private func startLogin() {
        startLoading()
        Task { @MainActor in
            do {
                try await dataSource.login(fromVC: self)
                self.delegate?.didFinishLogin()
                stopLoading()
            } catch {
                if let authError = error as? AuthenticationDataSource.AuthError, authError == .userCanceled {
                    // El usuario ha cancelado la autenticación
                    stopLoading()
                    // Manejar la cancelación de autenticación según tus necesidades
                } else {
                    stopLoading()
                    showErrorAlert("Failed to login", error: error)
                }
            }
        }
    }
}

extension StartViewController: ASWebAuthenticationViewController {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return view.window!
    }
}
