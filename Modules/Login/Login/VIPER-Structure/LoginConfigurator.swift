import Foundation
import Networking
import UIKit
import Utility

extension LoginDetails {
    mutating func update(userName: String) {
        self.userName = userName
    }
    
    mutating func update(password: String) {
        self.password = password
    }
}

final class LoginConfigurator {
    // MARK: Properties
    private (set) var rememberState = RememberCredentialState.doNotRemember
    private var loginViewController: LoginViewController?
    private var interactor: LoginInteractor?
    
    // MARK: - Configure
    func configure(viewController: LoginViewController, slideMenuController: UIViewController) {
        self.loginViewController = viewController
        
        let router = LoginRouter(loginViewController: viewController, slideMenuController: slideMenuController)
        
        let presenter = LoginPresenter(loginViewController: viewController, formatterService: UtilityManager.shared.formatterService)
        
        self.interactor = LoginInteractor(with: [.loginDetails(LoginDetails()),
                                                .screenTransitionOnSuccess({ [weak self] in
                                                    // Go to Inbox
                                                    self?.loginViewController?.router?.showInboxScreen()
                                                }), .showAlert({ [weak self] (title, message) in
                                                    // Show Alert
                                                    self?.loginViewController?.presenter?.showAlert(title: title, message: message)
                                                }), .showHideLoader({ [weak self] (shouldShowLoader) in
                                                    // Show/Hide Loader
                                                    self?.loginViewController?.presenter?.toggleLoader(shouldShow: shouldShowLoader)
                                                })])
        presenter.setup(interactor: interactor!)
        
        viewController.setup(presenter: presenter)
        
        viewController.setup(router: router)
        
        viewController.setup(configurator: self)
        
        self.loginViewController = viewController
    }

    // MARK: - Model Update
    func update(userName: String) {
        loginViewController?.presenter?.interactor?.update(userName: userName)
    }
    
    func update(password: String) {
        loginViewController?.presenter?.interactor?.update(password: password)
    }
    
    func update(state: RememberCredentialState) {
        rememberState = state
        loginViewController?.presenter?.interactor?.updateRememberStatus(by: state == .remember)
    }
}
