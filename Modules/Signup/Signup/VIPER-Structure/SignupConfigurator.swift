import Foundation
import UIKit
import Utility
import Networking

final class SignupConfigurator {
    // MARK: Variables
    private var signupPageViewController: SignupPageViewController
    private var onSignupComplete: (() -> Void)?
    private (set) var signupModel = SignupModel()
    
    // MARK: Constructor
    init(with viewController: SignupPageViewController,
         onSignupComplete: (() -> Void)?) {
        self.signupPageViewController = viewController
        self.onSignupComplete = onSignupComplete
    }
    
    // MARK: - Configuration
    func configure() -> SignupConfigurator {
        // Router Setup
        let router = SignupRouter(with: signupPageViewController, onCompleteSignup: onSignupComplete)
        
        // Presenter Setup
        let presenter = SignupPresenter(with: signupPageViewController,
                                        formatter: FormatterService())
        
        // Interactor Setup
        let interactor = SignupInteractor(viewController: signupPageViewController,
                                          presenter: presenter,
                                          apiService: NetworkManager.shared.apiService,
                                          keychainService: UtilityManager.shared.keychainService)
        presenter.setup(interactor: interactor)
        signupPageViewController.setup(presenter: presenter)
        signupPageViewController.setup(router: router)
        return self
    }
    
    // MARK: - Model Update
    func update(userName: String) {
        signupModel.update(userName: userName)
    }
    
    func update(password: String) {
        signupModel.update(password: password)
    }
    
    func update(recoveryEmail: String) {
        signupModel.update(recoveryEmail: recoveryEmail)
    }
    
    func update(invitationCode: String) {
        signupModel.update(invitationCode: invitationCode)
    }
    
    
}
