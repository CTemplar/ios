import Foundation
import UIKit
import EmptyStateKit

enum MainState: CustomState {
    case noInternet
}

public protocol EmptyStateMachine where Self: UIViewController {
    func showEmptyState()
    func removeEmptyState()
}

public extension EmptyStateMachine {
    func showEmptyState() {
        let emptyStateVC: EmptyStateViewController = UIStoryboard(storyboard: .emptyState,
                                                                  bundle: Bundle(for: EmptyStateViewController.self))
            .instantiateViewController()
        emptyStateVC.modalPresentationStyle = .fullScreen
        self.present(emptyStateVC, animated: true, completion: nil)
    }
    
    func removeEmptyState() {
        if let emptyStateVC = presentedViewController as? EmptyStateViewController {
            emptyStateVC.dismiss(animated: true, completion: nil)
        }
    }
}
