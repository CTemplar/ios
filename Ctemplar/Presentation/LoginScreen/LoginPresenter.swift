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
