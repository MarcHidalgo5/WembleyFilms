//
//  Created by Marc Hidalgo on 3/6/23.
//

import UIKit

extension UIViewController {
    func showErrorAlert(_ message: String, error: Error) {
        let errorMessage = "\(message): \(error.localizedDescription)"
        let alertController = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
        let action = UIAlertAction(title: "Dismiss", style: .default)
        alertController.addAction(action)
        self.present(alertController, animated: true, completion: nil)
    }
}
