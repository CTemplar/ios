//
//  LoginInteractor.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 02.10.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import AlertHelperKit

class LoginInteractor {
    
    var viewController  : LoginViewController?
    var presenter       : LoginPresenter?
    var apiService      : APIService?
    
    func authenticateUser(userName: String, password: String, completionHandler: @escaping (APIResult<Any>) -> Void) {
        
        apiService?.authenticateUser(userName: userName, password: password, completionHandler: completionHandler)
    }
    
    func validateEmailFormat(enteredEmail: String) -> Bool {
        
        let emailFormat = "[A-Z0-9a-z._%+-]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailFormat)
        return emailPredicate.evaluate(with: enteredEmail)
    }
    
    func validateNameLench(enteredName: String) -> Bool {
        
        if (enteredName.count > 0)  {
            return true
        } else {
            return false
        }
    }
    
    func validatePasswordLench(enteredPassword: String) -> Bool {
        
        if (enteredPassword.count > 0)  {
            return true
        } else {
            return false
        }
    }
    
    func validatePasswordFormat(enteredPassword: String) -> Bool {
        
        let passwordFormat = "[A-Z0-9a-z._%+-]{2,}"//"^(?=.*\\d)(?=.*[a-z])(?=.*[A-Z])[0-9a-zA-Z!@#$%^&*()\\-_=+{}|?>.<,:;~`’]{8,}$"
        let passwordPredicate = NSPredicate(format:"SELF MATCHES %@", passwordFormat)
        return passwordPredicate.evaluate(with: enteredPassword)
    }
    
    //temp 
    func parseServerResponse(response: Dictionary<String, Any>) {
        
        for dictionary in response {
            
            switch dictionary.key {
                case APIResponse.token.rawValue :
                    print("token:", dictionary.value)
                    break
                case APIResponse.username.rawValue :
                    let message = extractErrorTextFrom(value: dictionary.value)
                    AlertHelperKit().showAlert(self.viewController!, title: "Error", message: message, button: "Close")
                    break
                case APIResponse.password.rawValue :
                    let message = extractErrorTextFrom(value: dictionary.value)
                    AlertHelperKit().showAlert(self.viewController!, title: "Error", message: message, button: "Close")
                    break
                case APIResponse.non_field_errors.rawValue :                    
                    let message = extractErrorTextFrom(value: dictionary.value)
                    AlertHelperKit().showAlert(self.viewController!, title: "Error", message: message, button: "Close")
                    break
            default:
                print("unknown APIResponce")
            }
        }        
    }
    
    func extractErrorTextFrom(value: Any) -> String? {

        if let texts = value as? Array<Any> {
            for text in texts {
                var string : String = ""
                if let oneString = text as? String {
                    string = string + oneString
                    print("string:", string)
                }
                return string
            }
        }
        
        return ""
    }
}
