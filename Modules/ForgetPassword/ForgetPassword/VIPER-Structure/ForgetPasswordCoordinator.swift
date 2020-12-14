import Foundation
import Utility
import UIKit

public class ForgetPasswordCoordinator {
    // MARK: Properties
    private var forgetPasswordViewController: ForgetPasswordViewController?
    private let configurator = ForgetPasswordConfigurator()
    
    public init() {}
    public func showForgetPassword(from presentingViewController: UIViewController,
                                   onCompleteResetPassword: @escaping ((String, String) -> Void)) {
        
        forgetPasswordViewController = UIStoryboard(storyboard: .forgetPassword,
                                                    bundle: Bundle(for: type(of: self))).instantiateViewController()
        
        configurator.configure(viewController: forgetPasswordViewController!) { (userName, password) in
            onCompleteResetPassword(userName, password)
        }
        
        let embeddedNavigationController = ForgotPasswordNavigationController(rootViewController: forgetPasswordViewController!)
        embeddedNavigationController.modalPresentationStyle = .formSheet
        embeddedNavigationController.navigationBar.barTintColor = k_sideMenuColor
        embeddedNavigationController.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: k_sideMenuColor]
        presentingViewController.show(embeddedNavigationController, sender: presentingViewController)
    }
}

class ForgotPasswordNavigationController: UINavigationController, UINavigationControllerDelegate {
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self

        setupNavigationBar()
    }
    
    // MARK: - NavigationBar setup
    func setupNavigationBar() {
        // UIBarbuttonItem tint color
        UINavigationBar.appearance().tintColor = k_sideMenuColor
        
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
        // Sets shadow (line below the bar) to a blank image
        UINavigationBar.appearance().shadowImage = UIImage()
        // Sets the translucent background color
        UINavigationBar.appearance().backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
        // Set translucent. (Default value is already true, so this can be removed if desired.)
        UINavigationBar.appearance().isTranslucent = true
    }
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if #available(iOS 14.0, *) {
            self.navigationItem.backButtonTitle = " "
            self.navigationItem.backButtonDisplayMode = .minimal
        } else {
            let item = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
            viewController.navigationItem.backBarButtonItem = item
        }
    }
}
