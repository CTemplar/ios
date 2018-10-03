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
        
        if (interactor?.validateEmailFormat(enteredEmail: userEmail))! {
            if (interactor?.validatePasswordFormat(enteredPassword: password))! {
                authenticateUser(userEmail: userEmail, password: password)
            } else {
                AlertHelperKit().showAlert(self.viewController!, title: "", message: "Entered Password is not valid", button: "Close")
            }
        } else {
            AlertHelperKit().showAlert(self.viewController!, title: "", message: "Entered Email is not valid", button: "Close")
        }
    }
    
    func authenticateUser(userEmail: String, password: String) {
        
        HUD.show(.progress)
        
        interactor?.authenticateUser(userName: userEmail, password: password) {(result) in
            
            switch(result) {
                
            case .success(let value):
                print("success:", value)
                
                if let response = value as? Dictionary<String, Any> {
                    self.interactor?.parseServerResponse(response:response)
                } else {
                    print("error: responce have unknown format")
                    AlertHelperKit().showAlert(self.viewController!, title: "Error", message: "Responce have unknown format", button: "Close")
                }
                
            case .failure(let error):
                print("error:", error.localizedDescription)
                AlertHelperKit().showAlert(self.viewController!, title: "Error", message: error.localizedDescription, button: "Close")
            }
            
            HUD.hide()
        }
    }
}
