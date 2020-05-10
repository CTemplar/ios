//
//  ForgotPasswordPresenter.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 16.10.2018.
//  Copyright © 2018 CTemplar. All rights reserved.
//

import Foundation
import AlertHelperKit
import PKHUD

class ForgotPasswordPresenter {
    
    var viewController   : UIViewController?
    var router           : ForgotPasswordRouter?
    var interactor       : ForgotPasswordInteractor?
    var formatterService : FormatterService?

    func forgotPasswordHintLabel(show: Bool, sender: UITextField) {
        
        let currentViewController = viewController as? ForgotPasswordViewController
        
        if sender == currentViewController?.userNameTextField {
            if show {
                currentViewController!.userNameHintLabel.isHidden = false
                currentViewController?.userNameTextField.placeholder = ""
            } else {
                if !(formatterService?.validateNameLench(enteredName: (currentViewController?.userNameTextField.text)!))! {
                    currentViewController?.userNameTextField.placeholder = "usernameResetPlaceholder".localized()
                    currentViewController!.userNameHintLabel.isHidden = true
                }
            }
        }
        
        if sender == currentViewController?.recoveryEmailTextField {
            if show {
                currentViewController?.recoveryEmailHintLabel.isHidden = false
                currentViewController?.recoveryEmailTextField.placeholder = ""
            } else {
                if !(formatterService?.validateNameLench(enteredName: (currentViewController?.recoveryEmailTextField.text)!))! {
                    currentViewController?.recoveryEmailTextField.placeholder = "recoveryEmailPlaceholder".localized()
                    currentViewController!.recoveryEmailHintLabel.isHidden = true
                }
            }
        }
    }
    
    func buttonResetPasswordPressed(userName: String, recoveryEmail: String) {
        
        if (formatterService?.validateNameFormat(enteredName: userName))! {
            if (formatterService?.validateEmailFormat(enteredEmail: recoveryEmail))! {
                self.router?.showConfirmResetPasswordViewController(userName: userName, recoveryEmail: recoveryEmail)
            } else {
                AlertHelperKit().showAlert(self.viewController!, title: "", message: "invalidEnteredEmail".localized(), button: "closeButton".localized())
            }
        } else {
            AlertHelperKit().showAlert(self.viewController!, title: "", message: "Entered Username is not valid", button: "closeButton".localized())
        }
    }
    
    func resetPasswordHintLabel(show: Bool) {
        
        let currentViewController = viewController as? ResetPasswordViewController
        
        if show {
            currentViewController?.resetCodeHintLabel.isHidden = false
            currentViewController?.resetCodeTextField.placeholder = ""
        } else {
            if !(formatterService?.validateNameLench(enteredName: (currentViewController?.resetCodeTextField.text)!))! {
                currentViewController?.resetCodeTextField.placeholder = "resetCodePlaceholder".localized()
                currentViewController!.resetCodeHintLabel.isHidden = true
            }
        }
    }
    
    func buttonResetPasswordPressed(userName: String, resetCode: String, recoveryEmail: String) {
        
        if (formatterService?.validateNameLench(enteredName: resetCode))! {
            self.router?.showNewPasswordViewController(userName: userName, resetPasswordCode: resetCode, recoveryEmail: recoveryEmail)
        } else {
            AlertHelperKit().showAlert(self.viewController!, title: "", message: "Entered Reset Code is not valid", button: "closeButton".localized())
        }
    }
    
    func passwordsHintLabel(show: Bool, sender: UITextField) {
        
        let currentViewController = viewController as? NewPasswordViewController
        
        if sender == currentViewController?.newPasswordTextField {
            if show {
                currentViewController?.newPasswordHintLabel.isHidden = false
                currentViewController?.newPasswordTextField.placeholder = ""
            } else {
                if !(formatterService?.validateNameLench(enteredName: (currentViewController?.newPasswordTextField.text)!))! {
                    currentViewController?.newPasswordTextField.placeholder = "newPasswordPlaceholder".localized()
                    currentViewController?.newPasswordHintLabel.isHidden = true
                }
            }
        }
        
        if sender == currentViewController?.confirmPasswordTextField {
            if show {
                currentViewController?.confirmPasswordHintLabel.isHidden = false
                currentViewController?.confirmPasswordTextField.placeholder = ""
            } else {
                if !(formatterService?.validateNameLench(enteredName: (currentViewController?.confirmPasswordTextField.text)!))! {
                    currentViewController?.confirmPasswordTextField.placeholder = "confirmNewPasswordPlaceholder".localized()
                    currentViewController?.confirmPasswordHintLabel.isHidden = true
                }
            }
        }
    }
    
    func newPasswordsResetButtonState(childViewController: NewPasswordViewController, sender: UITextField) {
        
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
