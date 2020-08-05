import Foundation
import UIKit

public protocol NetworkErrorHandler: class {
    func showErorrLoginAlert(error: Error, shouldPop: Bool, onCompletion: @escaping ((Bool) -> Void))
    func showLoginViewController()
}

public extension NetworkErrorHandler {
    func showErorrLoginAlert(error: Error, shouldPop: Bool, onCompletion: @escaping ((Bool) -> Void)) {
        if let topViewController = UIApplication.topViewController() {
            let params = AlertKitParams(
                title: Strings.Signup.refreshTokenError.localized,
                message: error.localizedDescription,
                cancelButton: Strings.Signup.relogin.localized
            )
            
            topViewController.showAlert(with: params) {
                if shouldPop {
                    topViewController.navigationController?.popToRootViewController(animated: false)
                    topViewController.navigationController?.navigationBar.isHidden = true
                }
                onCompletion(true)
                return
            }
        }
        onCompletion(false)
    }
    
    func showLoginViewController() {
        let loginViewController = UIStoryboard(storyboard: .initializer,
            bundle: UIStoryboard.Storyboard.initializer.bundle)
            .instantiateViewController(withIdentifier: UIStoryboard.Storyboard.initializer.viewControllerId.storyboardId)
        
        if let window = UIApplication.shared.getKeyWindow() {
            window.setRootViewController(loginViewController)
        }
    }
}
