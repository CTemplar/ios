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
    
    var viewController  : LoginViewController?
    var interactor      : LoginInteractor?
    
    func setupEmailTextFieldsAndHintLabel(userEmail: String) {
        
        if (interactor?.validateNameLench(enteredName: userEmail))! {
            viewController!.emailHintLabel.isHidden = false
        } else {
            viewController!.emailHintLabel.isHidden = true
        }        
    }
    
    func setupPasswordTextFieldsAndHintLabel(password: String) {
        
        if (interactor?.validatePasswordLench(enteredPassword: password))! {
            viewController!.passwordHintLabel.isHidden = false
        } else {
            viewController!.passwordHintLabel.isHidden = true
        }
        
        //viewController!.passwordTextField.isSecureTextEntry = true
    }
    
    func buttonLoginPressed(userEmail: String, password: String) {
        
        if (interactor?.validateNameFormat(enteredName: userEmail))! {
            if (interactor?.validatePasswordFormat(enteredPassword: password))! {
                authenticateUser(userEmail: userEmail, password: password)
            } else {
                AlertHelperKit().showAlert(self.viewController!, title: "", message: "Entered Password is not valid", button: "Close")
            }
        } else {
            AlertHelperKit().showAlert(self.viewController!, title: "", message: "Entered Email is not valid", button: "Close")
        }
    }
    
    func buttonCreateAccountPressed() {
        
        viewController?.router?.showSignUpViewController()
    }
    
    func authenticateUser(userEmail: String, password: String) {
        
        interactor?.authenticateUser(userName: userEmail, password: password)
    }
}
