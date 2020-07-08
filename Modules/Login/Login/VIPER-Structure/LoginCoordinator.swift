import Foundation
import UIKit
import Utility

public class LoginCoordinator {
    public init() {}
    public func showLogin(from presentingViewController: UIViewController,
                          onShowInbox: @escaping (() -> Void)) {
        
        let loginViewController: LoginViewController = UIStoryboard(storyboard: .login, bundle: Bundle(for: type(of: self)))
            .instantiateViewController()
        loginViewController.modalPresentationStyle = .fullScreen
        
        let configurator = LoginConfigurator()
        configurator.configure(viewController: loginViewController, onShowInbox: onShowInbox)
        presentingViewController.add(loginViewController)
    }
}
