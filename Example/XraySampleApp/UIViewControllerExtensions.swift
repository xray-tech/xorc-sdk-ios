//
//  This file is part of Xray SDK.
//  See the file LICENSE.txt for copying permission.
//

import UIKit

typealias Action = (() -> ())

extension UIViewController {

    func present(error: Error) {
        OperationQueue.main.addOperation {
            let controller = UIAlertController(title: "Invalid JSON \(error.localizedDescription)", message: "\(error)", preferredStyle: .alert)
            controller.addAction(UIAlertAction(title: "Ok", style: .default))
            self.present(controller, animated: true)
        }
    }

    func present(title: String, message: String) {
        OperationQueue.main.addOperation {
            let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
            controller.addAction(UIAlertAction(title: "Ok", style: .default))
            self.present(controller, animated: true)
        }
    }

    func askYesNo(title: String, question: String, yesAction: @escaping (() -> ()), noAction: (() -> ())?) {
        let controller = UIAlertController(title: title, message: question, preferredStyle: .alert)

        controller.addAction(UIAlertAction(title: "Ok", style: .default) { action in
            yesAction()
        })

        controller.addAction(UIAlertAction(title: "Not now", style: .default) { action in
            noAction?()
        })
        self.present(controller, animated: true)
    }
}

