import Foundation
import UIKit
import Utility
import Networking
import BJOTPViewController

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
    
    private var twoFACode = "" {
        didSet {
            loginViewController?.configurator?.update(twoFACode: twoFACode)
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
    
    func update(twoFACode: String) {
        self.twoFACode = twoFACode
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
    
    func showOTPScreen(with loginResponse: LoginResult, password: String) {
        // Initialise view controller
        let oneTimePasswordVC = BJOTPViewController(withHeading: Strings.Login.TwoFactorAuth.twoFATitle.localized,
                                                    withNumberOfCharacters: 6,
                                                    delegate: self)
        // Modal presentation Style
        oneTimePasswordVC.modalPresentationStyle = .formSheet
        
        // Button title. Optional. Default is "AUTHENTICATE".
      //  oneTimePasswordVC.authenticateButtonTitle = Strings.Login.TwoFactorAuth.twoFAButtonTitle.localized
        
        // Secondary Header Title. Default is Nil
        oneTimePasswordVC.secondaryHeaderTitle = Strings.Login.TwoFactorAuth.twoFASecondaryTitle.localized

        // Sets the overall accent of the view controller. Optional. Default is system blue.
        oneTimePasswordVC.accentColor = AppStyle.Colors.loaderColor.color

        // Currently selected text field color. Optional. This takes precedence over the accent color.
        oneTimePasswordVC.currentTextFieldColor = AppStyle.Colors.loaderColor.color

        // Button color. Optional. This takes precedence over the accent color.
    //oneTimePasswordVC.authenticateButtonColor = AppStyle.Colors.loaderColor.color
        
        loginViewController?.present(oneTimePasswordVC, animated: true, completion: nil)
    }
    
    // MARK: - Login
    func login(fromPresenter presenter: UIViewController? = nil) {
        interactor?.authenticateUser(fromPresenter: presenter)
    }
}

//Conform to BJOTPViewControllerDelegate
extension LoginPresenter: BJOTPViewControllerDelegate {
    func didClose(_ viewController: BJOTPViewController) {
    }
    
    func didTap(footer button: UIButton, from viewController: BJOTPViewController) {
    }
    
    func authenticate(_ otp: String, from viewController: BJOTPViewController) {
        // Make API calls, show loading animation in viewController, do whatever you want.
        // You can dismiss the viewController when you're done.
        // This method will get called only after the validation is successful, i.e.,
        // after the user has filled all the textfields.
        self.twoFACode = otp
        
        if otp.count == 6 {
            login(fromPresenter: viewController)
        }
    }
}
