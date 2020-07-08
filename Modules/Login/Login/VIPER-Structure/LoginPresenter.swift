import Foundation
import UIKit
import Utility

final class LoginPresenter {
    // MARK: Properties
    private (set) weak var loginViewController: LoginViewController?
    private (set) var interactor: LoginInteractor?
    private (set) weak var formatterService: FormatterService?
    private var userName = "" {
        didSet {
            loginViewController?.configurator?.update(userName: userName)
        }
    }
    private var password = "" {
        didSet {
            loginViewController?.configurator?.update(password: password)
        }
    }
    
    // MARK: - Constructor
    init(loginViewController: LoginViewController,
         formatterService: FormatterService) {
        self.loginViewController = loginViewController
        self.formatterService = formatterService
    }
    
    // MARK: - Configuration
    func setup(interactor: LoginInteractor) {
        self.interactor = interactor
    }
    
    // MARK: - Validator
    func validate(value: String?, of sender: UITextField) {
        let value = value ?? ""
        
        switch sender {
        case loginViewController?.userNameTextField:
            userName = value
        case loginViewController?.passwordTextField:
            password = value
        default:
            DPrint("unknown textfield")
        }
        
        loginViewController?.update(by: (userName.isEmpty == false && password.isEmpty == false))
    }
    
    // MARK: - Updates
    func update(userName: String) {
        self.userName = userName
    }
    
    func update(password: String) {
        self.password = password
    }
    
    // MARK: - Sub-Controllers Config
    func changeButtonState(button: UIButton, disabled: Bool) {
        if disabled {
            button.isEnabled = false
            button.alpha = 0.6
        } else {
            button.isEnabled = true
            button.alpha = 1.0
        }
    }
    
    func changePasswordEntryStyle(_ shouldSecure: Bool, textField: UITextField) {
        textField.isSecureTextEntry = shouldSecure
    }
    
    func showAlert(title: String, message: String) {
        loginViewController?.showAlert(with: title,
                                       message: message,
                                       buttonTitle: Strings.Button.closeButton.localized)
    }
    
    func toggleLoader(shouldShow: Bool) {
        shouldShow ? loginViewController?.startLoader() : loginViewController?.stopLoader()
    }
    
    // MARK: - Login
    func login() {
        interactor?.authenticateUser()
    }
}
