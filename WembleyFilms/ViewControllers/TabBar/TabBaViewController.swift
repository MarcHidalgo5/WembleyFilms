//
//  Created by Marc Hidalgo on 2/6/23.
//

import UIKit

class TabBarController: UITabBarController {

    init() {
        super.init(nibName: nil, bundle: nil)
        let filmsList: (UIViewController, UITabBarItem) = (
            DiscoverFilmsListViewController(),
            UITabBarItem(title: "Films", image: UIImage(systemName: "list.bullet"), selectedImage: UIImage(systemName: "list.bullet")?.applyingSymbolConfiguration(UIImage.SymbolConfiguration(weight: .bold)))
        )
        
        let favouritesFilms: (UIViewController, UITabBarItem) = (
            FavouriteFilmsListViewController(),
            UITabBarItem(title: "Favourites", image: UIImage(systemName: "list.star"), selectedImage: UIImage(systemName: "list.star")?.applyingSymbolConfiguration(UIImage.SymbolConfiguration(weight: .bold)))
        )
        
        let viewControllers: [UIViewController] = [
            navigationController(with: filmsList),
            viewController(with: favouritesFilms)
        ]
        self.setViewControllers(viewControllers, animated: true)
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.backgroundColor = .white
        
        //Lines: add line to the top of tabbar
        let topline = CALayer()
        topline.frame = CGRect(x: 0, y: 0, width: self.tabBar.frame.width, height: 1)
        topline.backgroundColor = UIColor.gray.withAlphaComponent(0.3).cgColor
        self.tabBar.layer.addSublayer(topline)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var selectedIndex: Int {
        didSet {
            setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    override var childForStatusBarStyle: UIViewController? {
        viewControllers?[selectedIndex]
    }
            
    // MARK: Private

    private func navigationController(with tuple:(UIViewController, UITabBarItem)) -> UIViewController {
        let navVC = UINavigationController(rootViewController: tuple.0)
        navVC.tabBarItem = tuple.1
        return navVC
    }
    
    private func viewController(with tuple:(UIViewController, UITabBarItem)) -> UIViewController {
        let vc = tuple.0
        vc.tabBarItem = tuple.1
        return vc
    }
}
