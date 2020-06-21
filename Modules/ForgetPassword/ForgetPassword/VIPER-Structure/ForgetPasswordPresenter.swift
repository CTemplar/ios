import Foundation
import Utility
import UIKit
import Signup

final class ForgetPasswordPresenter {
    // MARK: Properties
    private (set) var router: ForgetPasswordRouter?
    private (set) var interactor: ForgetPasswordInteractor?
    private (set) weak var viewController: ForgetPasswordViewController?
    private let formatterService = UtilityManager.shared.formatterService
    private (set) var userName = ""
    private (set) var password = ""
    private var confirmPassword = ""
    private var resetCode = ""
    private var recoveryEmail = ""
    
    // MARK: - Constructor
    init(viewController: ForgetPasswordViewController?, router: ForgetPasswordRouter?) {
        self.viewController = viewController
        self.router = router
    }
    
    // MARK: - Setup
    func setup(interactor: ForgetPasswordInteractor?) {
        self.interactor = interactor
    }
    
    func setup(router: ForgetPasswordRouter?) {
        self.router = router
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
    
    func onCompletionAPI() {
        DispatchQueue.main.async {
            (self.viewController?.navigationController?.topViewController as? Loadable)?.onCompletionAPI()
        }
    }
    
    // MARK: - Validators
    func validate(userName: String, in viewController: ForgetPasswordViewController) {
        self.userName = userName
        
        guard formatterService.validateEmailFormat(enteredEmail: self.recoveryEmail) else {
            changeButtonState(button: viewController.resetPasswordButton, disabled: true)
            return
        }
        
        let isUserNameValidated = formatterService.validateNameLench(enteredName: userName)
        
        changeButtonState(button: viewController.resetPasswordButton, disabled: isUserNameValidated == false)
    }
    
    func validate(recoveryEmail: String, in viewController: ForgetPasswordViewController) {
        self.recoveryEmail = recoveryEmail
        
        guard formatterService.validateNameLench(enteredName: userName) else {
            changeButtonState(button: viewController.resetPasswordButton, disabled: true)
            return
        }
                
        let emailChecker = formatterService.validateEmailFormat(enteredEmail: recoveryEmail) ? EmailChecker.correctEmail : EmailChecker.incorrectEmail
        
        viewController.update(by: emailChecker)
    }
    
    func validate(recoveryEmail: String, in viewController: ForgetUsernameViewController) {
        let emailChecker = formatterService.validateEmailFormat(enteredEmail: recoveryEmail) ? EmailChecker.correctEmail : EmailChecker.incorrectEmail
        viewController.update(by: emailChecker)
    }
    
    func validate(resetCode: String, in viewController: ResetCodeViewController) {
        self.resetCode = resetCode
        changeButtonState(button: viewController.resetPasswordButton,
                          disabled: formatterService.validateNameLench(enteredName: self.resetCode) == false)
    }
    
    func setupPasswordsNextButtonState(childViewController: NewPasswordViewController, sender: UITextField) {
        let pwd = sender.text ?? ""
        
        // Length check
        guard formatterService.validatePasswordLench(enteredPassword: pwd) == true,
            formatterService.validatePasswordFormat(enteredPassword: pwd) == true else {
            childViewController.update(by: .wrongFormat)
            return
        }
        
        // Minimum Characters check
        guard pwd.count >= minPasswordLength else {
            childViewController.update(by: .minLength)
            return
        }
                
        switch sender {
        case childViewController.newPasswordTextField:
            password = pwd
        case childViewController.confirmPasswordTextField!:
            confirmPassword = pwd
        default:
            DPrint("unknown textfield")
        }
        
        if formatterService.passwordsMatched(choosedPassword: password, confirmedPassword: confirmPassword) == true {
            childViewController.update(by: .matched)
        } else {
            childViewController.update(by: .unMatched)
        }
    }
    
    // MARK: - UI Handlers
    func toggleLoader(shouldShow: Bool) {
        DispatchQueue.main.async {
            shouldShow ? (self.viewController?.navigationController?.topViewController as? Loadable)?.startLoader() : (self.viewController?.navigationController?.topViewController as? Loadable)?.stopLoader()
        }
    }
    
    func showAlert(title: String, message: String) {
        DispatchQueue.main.async {
            self.viewController?.navigationController?.topViewController?.showAlert(with: title,
                                                                                    message: message,
                                                                                    buttonTitle: Strings.Button.closeButton.localized)
        }
    }
    
    // MARK: - Interactor Handlers
    func resetPassword() {
        interactor?.resetPassword(userName: userName, password: password, resetPasswordCode: resetCode, recoveryEmail: recoveryEmail)
    }
    
    func sendResetCode() {
        interactor?.recoveryPasswordCode(userName: userName, recoveryEmail: recoveryEmail)
    }
    
    // MARK: - Router Handlers
    func showInbox() {
        router?.showInbox()
    }
    
    func showForgetUserNameScreen() {
        router?.showForgetUsernameScreen()
    }
    
    func showResetCodeScreen() {
        router?.showResetCodeScreen()
    }
    
    func showNewPasswordSetupScreen() {
        router?.showNewPasswordSetupScreen()
    }
    
    func showConfirmResetPasswordScreen() {
        router?.showConfirmResetPasswordScreen()
    }
    
    func backToLogin() {
        router?.backToRoot()
    }
}
