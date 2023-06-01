//
//  Created by Marc Hidalgo on 1/6/23.
//

import UIKit

class ViewController: UIViewController {

    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        view = UIView()
        view.backgroundColor = .red
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

