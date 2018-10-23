//
//  ForgotPasswordPresenter.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 16.10.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import AlertHelperKit
import PKHUD

class ForgotPasswordPresenter {
    
    var viewController   : UIViewController?
    var router           : ForgotPasswordRouter?
    var interactor       : ForgotPasswordInteractor?
    var formatterService : FormatterService?

    
    func setupUserNameTextFieldsAndHintLabel(userName: String) {
        
        let currentViewController = viewController as? ForgotPasswordViewController
        
        if (formatterService?.validateNameLench(enteredName: userName))! {
            currentViewController?.userNameHintLabel.isHidden = false
        } else {
            currentViewController?.userNameHintLabel.isHidden = true
        }
    }
    
    func setupRecoveryTextFieldsAndHintLabel(email: String) {
        
        let currentViewController = viewController as? ForgotPasswordViewController
        
        if (formatterService?.validateEmailFormat(enteredEmail: email))! {
            currentViewController?.recoveryEmailHintLabel.isHidden = false
        } else {
            currentViewController?.recoveryEmailHintLabel.isHidden = true
        }
    }
    
    func buttonResetPasswordPressed(userName: String, recoveryEmail: String) {
        
        if (formatterService?.validateNameFormat(enteredName: userName))! {
            if (formatterService?.validateEmailFormat(enteredEmail: recoveryEmail))! {
                self.router?.showConfirmResetPasswordViewController(userName: userName, recoveryEmail: recoveryEmail)
            } else {
                AlertHelperKit().showAlert(self.viewController!, title: "", message: "Entered Email is not valid", button: "Close")
            }
        } else {
            AlertHelperKit().showAlert(self.viewController!, title: "", message: "Entered Username is not valid", button: "Close")
        }
    }
    
    func setupResetCodeTextFieldsAndHintLabel(resetCode: String) {
        
        let currentViewController = viewController as? ResetPasswordViewController
        
        if (formatterService?.validateNameLench(enteredName: resetCode))! {
            currentViewController?.resetCodeHintLabel.isHidden = false
        } else {
            currentViewController?.resetCodeHintLabel.isHidden = true
        }
    }
    
    func buttonResetPasswordPressed(userName: String, resetCode: String, recoveryEmail: String) {
        
        if (formatterService?.validateNameLench(enteredName: resetCode))! {
            self.router?.showNewPasswordViewController(userName: userName, resetPasswordCode: resetCode, recoveryEmail: recoveryEmail)
        } else {
            AlertHelperKit().showAlert(self.viewController!, title: "", message: "Entered Reset Code is not valid", button: "Close")
        }
    }
    
    func setupPasswordTextFieldsAndHintLabels(childViewController: NewPasswordViewController, sender: UITextField) {
        
        switch sender {
        case (childViewController.newPasswordTextField)!:
            print("choosePasswordTextField typed:", sender.text!)
            childViewController.newPassword = sender.text
        case (childViewController.confirmPasswordTextField)!:
            print("confirmPasswordTextField typed:", sender.text!)
            childViewController.confirmedPassword = sender.text
        default:
            print("unknown textfield")
        }
        
        if (formatterService?.validatePasswordLench(enteredPassword: childViewController.newPassword!))! {
            childViewController.newPasswordHintLabel.isHidden = false
        } else {
            childViewController.newPasswordHintLabel.isHidden = true
        }
        
        if (formatterService?.validatePasswordLench(enteredPassword: childViewController.confirmedPassword!))! {
            childViewController.confirmPasswordHintLabel.isHidden = false
        } else {
            childViewController.confirmPasswordHintLabel.isHidden = true
        }
        
        if ((formatterService?.passwordsMatched(choosedPassword: childViewController.newPassword! , confirmedPassword: childViewController.confirmedPassword!))!) {
            print("passwords matched")
            childViewController.password = childViewController.newPassword
            
            if ((formatterService?.validatePasswordFormat(enteredPassword: (childViewController.password)!))!) {
                changeButtonState(button: childViewController.resetPasswordButton, disabled: false)
            } else {
                print("password wrong format")
                changeButtonState(button: childViewController.resetPasswordButton, disabled: true)
            }
        } else {
            print("passwords not matched!!!")
            childViewController.password = ""
            changeButtonState(button: childViewController.resetPasswordButton, disabled: true)
        }
    }
    
    func changeButtonState(button: UIButton, disabled: Bool) {
        
        if disabled {
            button.isEnabled = false
            button.alpha = 0.6
        } else {
            button.isEnabled = true
            button.alpha = 1.0
        }
    }
}
