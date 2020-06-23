import Foundation
import Utility
import UIKit

protocol Loadable where Self: UIViewController {
    func startLoader()
    func stopLoader()
    func onCompletionAPI()
}

final class ForgetPasswordConfigurator {
    // MARK: Properties
    private var presenter: ForgetPasswordPresenter?
    private var router: ForgetPasswordRouter?
    private var interactor: ForgetPasswordInteractor?
    private weak var forgetPasswordViewController: ForgetPasswordViewController?
    
    // MARK: - Configuration
    func configure(viewController: ForgetPasswordViewController,
                   onCompleteForgetPassword: @escaping ((String, String) -> Void)) {
        forgetPasswordViewController = viewController
        
        router = ForgetPasswordRouter(forgetPasswordViewController: forgetPasswordViewController,
                                      onCompleteForgetPassword: onCompleteForgetPassword)
        
        presenter = ForgetPasswordPresenter(viewController: forgetPasswordViewController, router: router)
        
        interactor = ForgetPasswordInteractor(viewController: forgetPasswordViewController,
                                              presenter: presenter,
                                              shouldShowLoader: { [weak self] (showLoader) in
                                                self?.presenter?.toggleLoader(shouldShow: showLoader)
            },
                                              onDisplayAlert: { [weak self] (title, message) in
                                                self?.presenter?.showAlert(title: title, message: message)
            },
                                              onCompletion: { [weak self] in
                                                self?.presenter?.onCompletionAPI()
        })

        presenter?.setup(interactor: interactor)
        
        forgetPasswordViewController?.setup(presenter: presenter)
    }
}
