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
    
    func buttonResetPasswordPressed(userName: String, recoveryPassword: String) {
        
        if (formatterService?.validateNameFormat(enteredName: userName))! {
            if (formatterService?.validateEmailFormat(enteredEmail: recoveryPassword))! {
                self.router?.showConfirmResetPasswordViewController()
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
    
    func buttonResetPasswordPressed(resetCode: String) {
        
        if (formatterService?.validateNameLench(enteredName: resetCode))! {
            //temp
            self.router?.showNewPasswordViewController()
        } else {
            AlertHelperKit().showAlert(self.viewController!, title: "", message: "Entered Reset Code is not valid", button: "Close")
        }
    }
}
