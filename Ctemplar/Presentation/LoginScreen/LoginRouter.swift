//
//  LoginRouter.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 02.10.2018.
//  Copyright © 2018 CTemplar. All rights reserved.
//

import Foundation
import UIKit

class LoginRouter {
    
    var viewController: LoginViewController?
    
    func showSignUpViewController() {
        
        DispatchQueue.main.async {
            
            var storyboardName : String? = k_SignUpStoryboardName
            
            if (Device.IS_IPAD) {
                storyboardName = k_SignUpStoryboardName_iPad
            }
            
            let storyboard: UIStoryboard = UIStoryboard(name: storyboardName!, bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: k_SignUpPageViewControllerID) as! SignUpPageViewController
//            vc.mainViewController = self.viewController?.mainViewController
            self.viewController?.show(vc, sender: self)
        }
    }
    
    func showForgotPasswordViewController() {
        
        DispatchQueue.main.async {
            
            var storyboardName : String? = k_ForgotPasswordStoryboardName
            
            if (Device.IS_IPAD) {
                storyboardName = k_ForgotPasswordStoryboardName_iPad
            }
            
            let storyboard: UIStoryboard = UIStoryboard(name: storyboardName!, bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: k_ForgotPasswordViewControllerID) as! ForgotPasswordViewController
            self.viewController?.show(vc, sender: self)
        }
    }
    
    func showInboxScreen() {
        
//        if Device.IS_IPAD {
//            let splitViewController = self.viewController?.presenter?.interactor?.getSplitViewController()
//            if let window = UIApplication.shared.getKeyWindow() {
//                window.setRootViewController(splitViewController!)
//            }else {
//                self.viewController?.show(splitViewController!, sender: self)
//            }
//        }else {
            let slideMenuController = self.viewController?.presenter?.interactor?.getSlideMenuController()
            slideMenuController?.modalPresentationStyle = .fullScreen
            if let window = UIApplication.shared.getKeyWindow() {
                window.setRootViewController(slideMenuController!)
            }else {
                self.viewController?.show(slideMenuController!, sender: self)
            }
//        }
//        self.viewController?.dismiss(animated: true, completion: {
//
////            self.viewController?.mainViewController?.setAutoUpdaterTimer()
//
//            if (!Device.IS_IPAD) {
//                self.viewController?.mainViewController?.showInboxNavigationController()
//            } else {
//                self.viewController?.mainViewController?.showSplitViewController()
//            }
//        })
    }
}
