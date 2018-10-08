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

    //sucess
    case token            = "token"
    
    //errors
    case passwordError    = "password"
    case usernameError    = "username"
    case nonFieldError    = "non_field_errors"
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
                    AlertHelperKit().showAlert(viewController, title: "SignIn Error", message: "Responce have unknown format", button: "Close")
                }
                
            case .failure(let error):
                AlertHelperKit().showAlert(viewController, title: "SignIn Error", message: error.localizedDescription, button: "Close")
            }
            
            HUD.hide()
        }
    }
    
    func signUpUser(userName: String, password: String, recoveryEmail: String, viewController: UIViewController) {
        /*
        let mainPgpKey = pgpService?.generatePGPKey(userName: userName)
        
        if mainPgpKey == nil {
            print("pgpKey is nil")
            return
        }
        
        pgpService?.savePGPKey(pgpKey: mainPgpKey!)
        
        
        let privateKey = pgpService?.generateArmoredPrivateKey(pgpKey: mainPgpKey!)
        
        if privateKey == nil {
            print("privateKey is nil")
            return
        }
        
        let publicKey = pgpService?.generateArmoredPublicKey(pgpKey: mainPgpKey!)
        
        if publicKey == nil {
            print("publicKey is nil")
            return
        }
        
        let fingerprint = pgpService?.fingerprintForKey(pgpKey: mainPgpKey!)
        
        if fingerprint == nil {
            print("fingerprint is nil")
            return
        }*/
        
        //let userPGPKey = UserPGPKey.init(pgpService: pgpService!, pgpKey: mainPgpKey!)
        
        let userPGPKey = pgpService?.generateUserPGPKeys(userName: userName)
        
        if userPGPKey?.privateKey == nil {
            print("publicKey is nil")
            return
        }
        
        if userPGPKey?.publicKey == nil {
            print("publicKey is nil")
            return
        }
        
        if userPGPKey?.fingerprint == nil {
            print("fingerprint is nil")
            return
        }
        
        HUD.show(.progress)
        
        restAPIService?.signUp(userName: userName, password: password, privateKey: (userPGPKey?.privateKey)!, publicKey: (userPGPKey?.publicKey)!, fingerprint: (userPGPKey?.fingerprint)!, recaptcha: "1", recoveryEmail: recoveryEmail, fromAddress: "", redeemCode: "", stripeToken: "", memory: "", emailCount: "", paymentType: "") {(result) in
            
            switch(result) {
                
            case .success(let value):
                print("signUpUser success:", value)
                
                if let response = value as? Dictionary<String, Any> {
                    if let message = self.parseServerResponse(response:response) {
                        AlertHelperKit().showAlert(viewController, title: "Error", message: message, button: "Close")
                    }
                } else {
                    AlertHelperKit().showAlert(viewController, title: "SignUp Error", message: "Responce have unknown format", button: "Close")
                }
                
            case .failure(let error):
                print("signUpUser error:", error.localizedDescription)
                AlertHelperKit().showAlert(viewController, title: "SignUp Error", message: error.localizedDescription, button: "Close")
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
            case APIResponse.usernameError.rawValue :
                if let text = extractErrorTextFrom(value: dictionary.value) {
                    message = "Username field.\n" + text
                }
                break
            case APIResponse.passwordError.rawValue :
                if let text = extractErrorTextFrom(value: dictionary.value) {
                    message = "Password field.\n" + text
                }
                break
            case APIResponse.nonFieldError.rawValue :
                message = extractErrorTextFrom(value: dictionary.value)
                break
            default:
                print("unknown APIResponce format")
                message = "unknown APIResponce format"
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
