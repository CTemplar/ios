//
//  LoginPresenter.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 02.10.2018.
//  Copyright © 2018 CTemplar. All rights reserved.
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
                    viewController?.userNameTextField.attributedPlaceholder = NSAttributedString(string: "usernamePlaceholder".localized(), attributes: [.foregroundColor: UIColor.white])
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
                    viewController?.passwordTextField.attributedPlaceholder = NSAttributedString(string: "passwordPlaceholder".localized(), attributes: [.foregroundColor: UIColor.white])
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
        viewController?.emailHintLabel.text = "usernamePlaceholder".localized()
        viewController?.userNameTextField.attributedPlaceholder = NSAttributedString(string: "usernamePlaceholder".localized(), attributes: [.foregroundColor: UIColor.white])
    }
    
    func setupPasswordTextFieldsAndHintLabel(password: String) {
        
        if (formatterService?.validatePasswordLench(enteredPassword: password))! {
            viewController!.passwordHintLabel.isHidden = false
        } else {
            viewController!.passwordHintLabel.isHidden = true
        }
        viewController?.passwordHintLabel.text = "passwordPlaceholder".localized()
        viewController?.passwordTextField.attributedPlaceholder = NSAttributedString(string: "passwordPlaceholder".localized(), attributes: [.foregroundColor: UIColor.white])
    }
    
    func buttonLoginPressed(userEmail: String, password: String, twoFAcode: String) {
        
        if userEmail != "" {
            if password != "" {
                authenticateUser(userEmail: userEmail, password: password, twoFAcode: twoFAcode)
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
    
    func authenticateUser(userEmail: String, password: String, twoFAcode: String) {
        
        interactor?.authenticateUser(userName: userEmail, password: password, twoFAcode: twoFAcode)
    }
}
