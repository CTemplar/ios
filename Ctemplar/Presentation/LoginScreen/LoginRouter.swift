//
//  LoginRouter.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 02.10.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import UIKit

class LoginRouter {
    
    var viewController: LoginViewController?
    
    func showSignUpViewController() {
        
        DispatchQueue.main.async {
            let storyboard: UIStoryboard = UIStoryboard(name: k_SignUpStoryboardName, bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: k_SignUpPageViewControllerID) as! SignUpPageViewController
            vc.mainViewController = self.viewController?.mainViewController
            self.viewController?.show(vc, sender: self)
        }
    }
    
    func showForgotPasswordViewController() {
        
        DispatchQueue.main.async {
            let storyboard: UIStoryboard = UIStoryboard(name: k_ForgotPasswordStoryboardName, bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: k_ForgotPasswordViewControllerID) as! ForgotPasswordViewController
            self.viewController?.show(vc, sender: self)
        }
    }
}
