//
//  Created by Marc Hidalgo on 1/6/23.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    //MARK: UIWindowSceneDelegate
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        
        let rootViewController = ContainerViewController(containedViewController: createViewController(forAppState: .start))
        window.rootViewController = rootViewController
        window.makeKeyAndVisible()
        self.rootViewController = rootViewController
        
        self.window = window
    }

    //MARK: Private
    
    private var rootViewController: ContainerViewController!
    private var startPresentationIsFinish = false
    
    private func createViewController(forAppState appState: AppState) -> UIViewController {
        switch appState {
        case .normal:
            return TabBarController()
        case .start:
            return StartViewController(delegate: self)
        }
    }
    
    private func updateContainedViewController() {
        rootViewController.updateContainedViewController(createViewController(forAppState: currentAppState))
        
    }
    
    private var currentAppState: AppState {
        if startPresentationIsFinish {
            return .normal
        } else {
            return .start
        }
    }
}

//MARK: StartViewControllerDelegate

extension SceneDelegate: StartViewControllerDelegate {
    func didFinishStart() {
        self.startPresentationIsFinish = true
        updateContainedViewController()
    }
}
