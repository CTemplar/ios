import Foundation

final class SignupRouter {
    // MARK: Properties
    private var signupPageViewController: SignupPageViewController
    private var onCompleteSignup: (() -> Void)?
    // MARK: - Constructor
    init(with viewController: SignupPageViewController, onCompleteSignup: (() -> Void)?) {
        self.signupPageViewController = viewController
        self.onCompleteSignup = onCompleteSignup
    }
    
    // MARK: - Routing
    func showInboxScreen() {
        signupPageViewController.dismiss(animated: true) { [weak self] in
            self?.onCompleteSignup?()
        }
    }
}
