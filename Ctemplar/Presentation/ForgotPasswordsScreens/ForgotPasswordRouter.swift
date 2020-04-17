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
        
        var storyboardName : String? = k_ForgotPasswordStoryboardName
        
        if (Device.IS_IPAD) {
            storyboardName = k_ForgotPasswordStoryboardName_iPad
        }
        
        let storyboard: UIStoryboard = UIStoryboard(name: storyboardName!, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: k_ConfirmResetPasswordViewControllerID) as! ConfirmResetPasswordViewController
        vc.userName = userName
        vc.recoveryEmail = recoveryEmail
        self.viewController?.present(vc, animated: true, completion: nil)
        //self.viewController?.show(vc, sender: self)
    }
    
    func showForgotUsernameViewController() {
        
        var storyboardName : String? = k_ForgotPasswordStoryboardName
        
        if (Device.IS_IPAD) {
            storyboardName = k_ForgotPasswordStoryboardName_iPad
        }
        
        let storyboard: UIStoryboard = UIStoryboard(name: storyboardName!, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: k_ForgorUsernameViewControllerID) as! ForgotUsernameViewController
        self.viewController?.present(vc, animated: true, completion: nil)
    }
    
    func showResetPasswordViewController(userName: String, recoveryEmail: String) {
        
        var storyboardName : String? = k_ForgotPasswordStoryboardName
        
        if (Device.IS_IPAD) {
            storyboardName = k_ForgotPasswordStoryboardName_iPad
        }
        
        let storyboard: UIStoryboard = UIStoryboard(name: storyboardName!, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: k_ResetPasswordViewControllerID) as! ResetPasswordViewController
        vc.userName = userName
        vc.recoveryEmail = recoveryEmail
        self.viewController?.present(vc, animated: true, completion: nil)
        //self.viewController?.show(vc, sender: self)
    }
    
    func showNewPasswordViewController(userName: String, resetPasswordCode: String, recoveryEmail: String) {
        
        var storyboardName : String? = k_ForgotPasswordStoryboardName
        
        if (Device.IS_IPAD) {
            storyboardName = k_ForgotPasswordStoryboardName_iPad
        }
        
        let storyboard: UIStoryboard = UIStoryboard(name: storyboardName!, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: k_NewPasswordViewControllerID) as! NewPasswordViewController
        vc.userName = userName
        vc.resetCode = resetPasswordCode
        vc.recoveryEmail = recoveryEmail
        self.viewController?.present(vc, animated: true, completion: nil)
        //self.viewController?.show(vc, sender: self)
    }
    
    func backToLoginViewController() {
    
        self.viewController?.view.window?.rootViewController?.presentedViewController!.dismiss(animated: true, completion: nil)        
    }
    
    func showInboxScreen() {
//        guard let mainViewController = self.viewController?.view.window?.rootViewController as? MainViewController else {
//            backToLoginViewController()
//            return
//        }
//        mainViewController.dismiss(animated: true, completion: {
//            mainViewController.setAutoUpdaterTimer()
//            
//            if (!Device.IS_IPAD) {
//                mainViewController.showInboxNavigationController()
//            } else {
//                mainViewController.showSplitViewController()
//            }
//        })
    }
}
