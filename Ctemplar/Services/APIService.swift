//
//  APIService.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 01.10.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import PKHUD
import AlertHelperKit

enum APIResult<T>
{
    case success(T)
    case failure(Error)
}

enum APIResponse: String {
    case password         = "password"
    case username         = "username"
    case non_field_errors = "non_field_errors"
    case token            = "token"
}

class APIService {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var restAPIService  : RestAPIService?
    var keychainService : KeychainService?
    var pgpService      : PGPService?
    
    
    func initialize() {
       
        self.restAPIService = appDelegate.applicationManager.restAPIService
        self.keychainService = appDelegate.applicationManager.keychainService
        self.pgpService = appDelegate.applicationManager.pgpService
        
    }
    
    //MARK: - authentication
    
    func authenticateUser(userName: String, password: String, viewController: UIViewController) {
        
        HUD.show(.progress)
        
        restAPIService?.authenticateUser(userName: userName, password: password) {(result) in
            
            switch(result) {
                
            case .success(let value):
                
                if let response = value as? Dictionary<String, Any> {
                    if let message = self.parseServerResponse(response:response) {
                        AlertHelperKit().showAlert(viewController, title: "Error", message: message, button: "Close")
                    }
                } else {
                    AlertHelperKit().showAlert(viewController, title: "Error", message: "Responce have unknown format", button: "Close")
                }
                
            case .failure(let error):
                AlertHelperKit().showAlert(viewController, title: "Error", message: error.localizedDescription, button: "Close")
            }
            
            HUD.hide()
        }
    }
    
    func signUpUser(userName: String, password: String, recoveryEmail: String, viewController: UIViewController) {
        
        let privateKey = ""
        
        let publicKey = ""
        
        let fingerprint = ""
        
        HUD.show(.progress)
        
        restAPIService?.signUp(userName: userName, password: password, privateKey: privateKey, publicKey: publicKey, fingerprint: fingerprint, recaptcha: "1", recoveryEmail: recoveryEmail, fromAddress: "", redeemCode: "", stripeToken: "", memory: "", emailCount: "", paymentType: "") {(result) in
            
            switch(result) {
                
            case .success(let value):
                print("signUpUser success:", value)
                
                
            case .failure(let error):
                print("signUpUser error:", error.localizedDescription)
            }
            
            HUD.hide()
        }
    }
    
    //Mark: - local services
    
    func saveToken(token: String) {
        
        keychainService?.saveToken(token: token)
    }
    
    func parseServerResponse(response: Dictionary<String, Any>) -> String? {
        
        var message: String? = nil
        
        for dictionary in response {
            
            switch dictionary.key {
            case APIResponse.token.rawValue :
                if let token = dictionary.value as? String {
                    saveToken(token: token)
                }
                break
            case APIResponse.username.rawValue :
                message = extractErrorTextFrom(value: dictionary.value)
                break
            case APIResponse.password.rawValue :
                message = extractErrorTextFrom(value: dictionary.value)
                break
            case APIResponse.non_field_errors.rawValue :
                message = extractErrorTextFrom(value: dictionary.value)
                break
            default:
                print("unknown APIResponce")
            }
        }
        
        return message
    }
    
    func extractErrorTextFrom(value: Any) -> String? {
        
        if let texts = value as? Array<Any> {
            for text in texts {
                var string : String = ""
                if let oneString = text as? String {
                    string = string + " " + oneString
                    print("extracted string:", string)
                }
                return string
            }
        }
        
        return ""
    }
}
