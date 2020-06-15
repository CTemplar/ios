import Foundation
import UIKit
import Utility

public final class SignupCoordinator {
    // MARK: Properties
    private var presentingViewController: UIViewController?
    private var signupCompletion: (() -> Void)
    private var signupPageViewController: SignupPageViewController?
    
    // MARK: - Constructor
    public init(with presentingViewController: UIViewController?,
                onCompletion: @escaping (() -> Void)) {
        self.presentingViewController = presentingViewController
        self.signupCompletion = onCompletion
    }
    
    public func showSignup() {
        if let signupPageViewController = UIStoryboard(storyboard: .signup,
                                                       bundle: Bundle(for: SignupPageViewController.self))
            .instantiateViewController(withIdentifier: SignupPageViewController.className
            ) as? SignupPageViewController {
            self.signupPageViewController = signupPageViewController
            
            self.signupPageViewController?.onSignupComplete = { [weak self] in
                self?.signupCompletion()
            }
            presentingViewController?.present(self.signupPageViewController!, animated: true, completion: nil)
        }
    }
}
