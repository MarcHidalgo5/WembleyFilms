//
//  Created by Marc Hidalgo on 2/6/23.
//

import UIKit

class ContainerViewController: UIViewController {

    private(set) public var containedViewController: UIViewController

    public init(containedViewController: UIViewController) {
        self.containedViewController = containedViewController
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        addChild(containedViewController)
        containedViewController.view.frame = view.bounds
        view.addSubview(containedViewController.view)
        containedViewController.didMove(toParent: self)
    }

    func updateContainedViewController(_ newVC: UIViewController) {
        addChild(newVC)
        newVC.view.frame = view.bounds
        view.addSubview(newVC.view)
        newVC.didMove(toParent: self)
        newVC.view.alpha = 0
        UIView.animate(withDuration: 0.3) {
            self.containedViewController.view.alpha = 0
            newVC.view.alpha = 1
        } completion: { _ in
            self.containedViewController.willMove(toParent: nil)
            self.containedViewController.view.removeFromSuperview()
            self.containedViewController.removeFromParent()
            self.containedViewController = newVC
        }
    }
}
