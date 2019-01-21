//
//  LoginPresenter.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 02.10.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import AlertHelperKit
import PKHUD

class LoginPresenter {
    
    var viewController   : LoginViewController?
    var interactor       : LoginInteractor?
    var formatterService : FormatterService?
    
    func hintLabel(show: Bool, sender: UITextField) {
        
        if sender == viewController?.userNameTextField {
            if show {
                viewController!.emailHintLabel.isHidden = false
                viewController?.userNameTextField.placeholder = ""
            } else {
                if !(formatterService?.validateNameLench(enteredName: (viewController?.userNameTextField.text)!))! {
                    viewController?.userNameTextField.placeholder = "usernamePlaceholder".localized()
                    viewController!.emailHintLabel.isHidden = true
                }
            }
        }
        
        if sender == viewController?.passwordTextField {            
            if show {
                viewController!.passwordHintLabel.isHidden = false
                viewController?.passwordTextField.placeholder = ""
            } else {
                if !(formatterService?.validateNameLench(enteredName: (viewController?.passwordTextField.text)!))! {
                    viewController?.passwordTextField.placeholder = "passwordPlaceholder".localized()
                    viewController!.passwordHintLabel.isHidden = true
                }
            }
        }
    }
    
    func setupEmailTextFieldsAndHintLabel(userEmail: String) {
        
        if (formatterService?.validateNameLench(enteredName: userEmail))! {
            viewController!.emailHintLabel.isHidden = false
        } else {
            viewController!.emailHintLabel.isHidden = true
        }        
    }
    
    func setupPasswordTextFieldsAndHintLabel(password: String) {
        
        if (formatterService?.validatePasswordLench(enteredPassword: password))! {
            viewController!.passwordHintLabel.isHidden = false
        } else {
            viewController!.passwordHintLabel.isHidden = true
        }
    }
    
    func buttonLoginPressed(userEmail: String, password: String) {
        
        if (formatterService?.validateNameFormat(enteredName: userEmail))! {
            if (formatterService?.validatePasswordFormat(enteredPassword: password))! {
                authenticateUser(userEmail: userEmail, password: password)
            } else {               
                AlertHelperKit().showAlert(self.viewController!, title: "", message: "invalidEnteredPassword".localized(), button: "closeButton".localized())
            }
        } else {
            AlertHelperKit().showAlert(self.viewController!, title: "", message: "invalidEnteredEmail".localized(), button: "closeButton".localized())
        }
    }
    
    func buttonCreateAccountPressed() {
        
        viewController?.router?.showSignUpViewController()
    }
    
    func authenticateUser(userEmail: String, password: String) {
        
        interactor?.authenticateUser(userName: userEmail, password: password)
    }
}
