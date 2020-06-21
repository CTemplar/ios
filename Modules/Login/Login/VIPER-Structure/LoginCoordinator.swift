import Foundation
import UIKit

public class LoginCoordinator {
    public init() {}
    public func showLogin(from presentingViewController: UIViewController,
                   withSideMenu sideMenuViewController: UIViewController) {
        
        let loginViewController: LoginViewController = UIStoryboard(storyboard: .login, bundle: Bundle(for: type(of: self)))
            .instantiateViewController()
        loginViewController.modalPresentationStyle = .fullScreen
        
        let configurator = LoginConfigurator()
        configurator.configure(viewController: loginViewController, slideMenuController: sideMenuViewController)
        
        if let window = UIApplication.shared.getKeyWindow() {
            window.setRootViewController(loginViewController)
        } else {
            presentingViewController.show(loginViewController, sender: presentingViewController)
        }
    }
}
