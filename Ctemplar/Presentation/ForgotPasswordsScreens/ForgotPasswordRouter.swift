//
//  ForgotPasswordRouter.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 16.10.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import UIKit

class ForgotPasswordRouter {
    
    var viewController: UIViewController?
    
    func showConfirmResetPasswordViewController(userName: String, recoveryEmail: String) {
        
        let storyboard: UIStoryboard = UIStoryboard(name: k_ForgotPasswordStoryboardName, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: k_ConfirmResetPasswordViewControllerID) as! ConfirmResetPasswordViewController
        vc.userName = userName
        vc.recoveryEmail = recoveryEmail
        self.viewController?.present(vc, animated: true, completion: nil)
    }
    
    func showForgotUsernameViewController() {
        
        let storyboard: UIStoryboard = UIStoryboard(name: k_ForgotPasswordStoryboardName, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: k_ForgorUsernameViewControllerID) as! ForgotUsernameViewController
        self.viewController?.present(vc, animated: true, completion: nil)
    }
    
    func showResetPasswordViewController(userName: String, recoveryEmail: String) {
        
        let storyboard: UIStoryboard = UIStoryboard(name: k_ForgotPasswordStoryboardName, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: k_ResetPasswordViewControllerID) as! ResetPasswordViewController
        vc.userName = userName
        vc.recoveryEmail = recoveryEmail
        self.viewController?.present(vc, animated: true, completion: nil)
    }
    
    func showNewPasswordViewController() {
        
        let storyboard: UIStoryboard = UIStoryboard(name: k_ForgotPasswordStoryboardName, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: k_NewPasswordViewControllerID) as! NewPasswordViewController
        self.viewController?.present(vc, animated: true, completion: nil)
    }
}
