import Foundation
import UIKit
import Signup
import Utility
import ForgetPassword

final class LoginRouter {
    // MARK: Properties
    private var loginViewController: LoginViewController
    private var signupCoordinator: SignupCoordinator?
    private var onShowInbox: (() -> Void)
    private lazy var forgetPasswordCoordinator: ForgetPasswordCoordinator = {
        let coordinator = ForgetPasswordCoordinator()
        return coordinator
    }()
    
    // MARK: - Constructor
    init(loginViewController: LoginViewController,
         onShowInbox: @escaping (() -> Void)) {
        self.loginViewController = loginViewController
        self.onShowInbox = onShowInbox
    }
    
    // MARK: - Routers
    func showSignUpViewController() {
        DispatchQueue.main.async {
            self.signupCoordinator = SignupCoordinator(with: self.loginViewController) { [weak self] in
                self?.showInboxScreen()
            }
            self.signupCoordinator?.showSignup()
        }
    }
    
    func showForgotPasswordViewController() {
        DispatchQueue.main.async {
            self.forgetPasswordCoordinator.showForgetPassword(from: self.loginViewController) { [weak self] (userName, password) in
                guard let weakSelf = self else {
                    return
                }
                weakSelf.loginViewController.userNameTextField.text = userName
                weakSelf.loginViewController.passwordTextField.text = password
                weakSelf.loginViewController.presenter?.update(userName: userName)
                weakSelf.loginViewController.presenter?.update(password: password)
                weakSelf.loginViewController.onTapSignIn(weakSelf)
            }
        }
    }
    
    func showInboxScreen() {
        onShowInbox()
    }
}
