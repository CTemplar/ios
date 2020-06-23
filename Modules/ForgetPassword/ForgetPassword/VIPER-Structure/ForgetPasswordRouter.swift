import Foundation
import Utility
import UIKit

final class ForgetPasswordRouter {
    // MARK: Properties
    private weak var forgetPasswordViewController: ForgetPasswordViewController?
    private let storyboard: UIStoryboard.Storyboard = .forgetPassword
    private lazy var rootNavigationController: UINavigationController? = {        
        return forgetPasswordViewController?.navigationController
    }()
    private var onCompleteForgetPassword: ((String, String) -> Void)
    
    // MARK: - Constructor
    init(forgetPasswordViewController: ForgetPasswordViewController?,
         onCompleteForgetPassword: @escaping ((String, String) -> Void)) {
        self.forgetPasswordViewController = forgetPasswordViewController
        self.onCompleteForgetPassword = onCompleteForgetPassword
    }
    
    // MARK: - Navigations
    func showConfirmResetPasswordScreen() {
        let confirmResetVC: ConfirmResetPasswordViewController = UIStoryboard(storyboard: storyboard,
                                                                              bundle: Bundle(for: type(of: self))).instantiateViewController()
        confirmResetVC.setup(presenter: forgetPasswordViewController?.presenter)
        rootNavigationController?.pushViewController(confirmResetVC, animated: true)
    }
    
    func showForgetUsernameScreen() {
        let forgetUserNameVC: ForgetUsernameViewController = UIStoryboard(storyboard: storyboard,
                                                                          bundle: Bundle(for: type(of: self))).instantiateViewController()
        forgetUserNameVC.setup(presenter: forgetPasswordViewController?.presenter)
        rootNavigationController?.pushViewController(forgetUserNameVC, animated: true) 
    }
    
    func showResetCodeScreen() {
        let resetPasswordVC: ResetCodeViewController = UIStoryboard(storyboard: storyboard,
                                                                    bundle: Bundle(for: type(of: self))).instantiateViewController()
        resetPasswordVC.setup(presenter: forgetPasswordViewController?.presenter)
        rootNavigationController?.pushViewController(resetPasswordVC, animated: true)
    }
    
    func showNewPasswordSetupScreen() {
        let newPasswordVC: NewPasswordViewController = UIStoryboard(storyboard: storyboard,
                                                                    bundle: Bundle(for: type(of: self))).instantiateViewController()
        newPasswordVC.setup(presenter: forgetPasswordViewController?.presenter)
        rootNavigationController?.pushViewController(newPasswordVC, animated: true)
    }
    
    func backToRoot() {
        rootNavigationController?.dismiss(animated: true, completion: nil)
    }
    
    func showInbox() {
        rootNavigationController?.dismiss(animated: true, completion: { [weak self] in
            guard let weakSelf = self else {
                return
            }
            self?.onCompleteForgetPassword(weakSelf.forgetPasswordViewController?.presenter?.userName ?? "",
                                           weakSelf.forgetPasswordViewController?.presenter?.password ?? "")
        })
    }
}
