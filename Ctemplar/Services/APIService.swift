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
    
    //auth errors
    case passwordError     = "password"
    case usernameError     = "username"
    case nonFieldError     = "non_field_errors"
    case recaptchaError    = "recaptcha"
    case fingerprintError  = "fingerprint"
    case userExists        = "exists"
    case tokenExpired      = "detail"
    case tokenExpiredValue = "Signature has expired."
    case noCredentials     = "Invalid Authorization header. No credentials provided."
    
    //email messages
    case pageConut         = "page_count"
    case results           = "results"
}

class APIService {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var restAPIService  : RestAPIService?
    var keychainService : KeychainService?
    var pgpService      : PGPService?
    var formatterService: FormatterService?
    
    var hashedPassword: String?
    
    @objc func getHashedPassword(userName: String, password: String, completion:@escaping (Bool) -> () ) {
        
        DispatchQueue.main.async {
            if let salt = self.formatterService?.generateSaltFrom(userName: userName) {
                print("salt:", salt)
                self.hashedPassword = self.formatterService?.hash(password: password, salt: salt)
                print("hashedPassword:", self.hashedPassword as Any)
            }
            completion(true)
        }
        
    }
    
    @objc func autologin(completion:@escaping (Bool) -> () ) {
        
        DispatchQueue.main.async {
            
            let storedUserName = self.keychainService?.getUserName()
            let storedPassword = self.keychainService?.getPassword()
            
            if (storedUserName?.count)! < 1 || (storedPassword?.count)! < 1 {
                print("wrong stored credentials!")
                self.showLoginViewController()
                completion(false)
                return
            }
            
            self.authenticateUser(userName: storedUserName!, password: storedPassword!) {(result) in
                
                switch(result) {
                    
                case .success(let value):
                    print("autologin success value:", value)
                    completion(true)
                    
                case .failure(let error):
                    print("autologin error:", error)
                    
                    if let topViewController = UIApplication.topViewController() {
                        AlertHelperKit().showAlert(topViewController, title: "Autologin Error", message: error.localizedDescription, button: "Close")
                    }
                    completion(false)
                }
            }
        }
    }
    
    func initialize() {
       
        self.restAPIService = appDelegate.applicationManager.restAPIService
        self.keychainService = appDelegate.applicationManager.keychainService
        self.pgpService = appDelegate.applicationManager.pgpService
        self.formatterService = appDelegate.applicationManager.formatterService
    }
    
    //MARK: - authentication
    
    func authenticateUser(userName: String, password: String, completionHandler: @escaping (APIResult<Any>) -> Void) {
        
        HUD.show(.progress)
        
        getHashedPassword(userName: userName, password: password) { (complete) in
            if complete {
                self.restAPIService?.authenticateUser(userName: userName, password: self.hashedPassword!) {(result) in
                    
                    switch(result) {
                        
                    case .success(let value):
                        
                        if let response = value as? Dictionary<String, Any> {
                            if let message = self.parseServerResponse(response:response) {
                                let error = NSError(domain:"", code:0, userInfo:[NSLocalizedDescriptionKey: message])
                                completionHandler(APIResult.failure(error))
                            } else {
                                completionHandler(APIResult.success("success"))
                            }
                        } else {
                            let error = NSError(domain:"", code:0, userInfo:[NSLocalizedDescriptionKey: "Responce have unknown format"])
                            completionHandler(APIResult.failure(error))
                        }
                        
                    case .failure(let error):
                        let error = NSError(domain:"", code:0, userInfo:[NSLocalizedDescriptionKey: error.localizedDescription])
                        completionHandler(APIResult.failure(error))
                    }
                    
                    HUD.hide()
                }
            }
        }
    }
    
    func checkUser(userName: String, completionHandler: @escaping (APIResult<Any>) -> Void) {
        
        HUD.show(.progress)
        
        restAPIService?.checkUser(name: userName) {(result) in
            
            switch(result) {
                
            case .success(let value):
                
                if let response = value as? Dictionary<String, Any> {
                    print("checkUser response", response)
                    if let message = self.parseServerResponse(response:response) {
                        let error = NSError(domain:"", code:0, userInfo:[NSLocalizedDescriptionKey: message])
                        completionHandler(APIResult.failure(error))
                    } else {
                        completionHandler(APIResult.success("success"))
                    }
                } else {
                    let error = NSError(domain:"", code:0, userInfo:[NSLocalizedDescriptionKey: "Responce have unknown format"])
                    completionHandler(APIResult.failure(error))
                }
                
            case .failure(let error):
                let error = NSError(domain:"", code:0, userInfo:[NSLocalizedDescriptionKey: error.localizedDescription])
                completionHandler(APIResult.failure(error))
            }
            
            HUD.hide()
        }
    }
    
    func signUpUser(userName: String, password: String, recoveryEmail: String, completionHandler: @escaping (APIResult<Any>) -> Void) {
        
        print("userName:", userName)
        print("password:", password)
        print("recoveryEmail:", recoveryEmail)
        
        let userPGPKey = pgpService?.generateUserPGPKeys(userName: userName, password: password)
        
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
        
        getHashedPassword(userName: userName, password: password) { (complete) in
            if complete {
                self.restAPIService?.signUp(userName: userName, password: self.hashedPassword!, privateKey: (userPGPKey?.privateKey)!, publicKey: (userPGPKey?.publicKey)!, fingerprint: (userPGPKey?.fingerprint)!, recaptcha: "1", recoveryEmail: recoveryEmail, fromAddress: "", redeemCode: "", stripeToken: "", memory: "", emailCount: "", paymentType: "") {(result) in
                
                    switch(result) {
                        
                    case .success(let value):
                       // print("signUpUser success:", value)
                        
                        if let response = value as? Dictionary<String, Any> {
                            if let message = self.parseServerResponse(response:response) {
                                let error = NSError(domain:"", code:0, userInfo:[NSLocalizedDescriptionKey: message])
                                completionHandler(APIResult.failure(error))
                            } else {
                                completionHandler(APIResult.success("success"))
                            }
                        } else {
                            let error = NSError(domain:"", code:0, userInfo:[NSLocalizedDescriptionKey: "Responce have unknown format"])
                            completionHandler(APIResult.failure(error))
                        }
                        
                    case .failure(let error):
                        print("signUpUser error:", error.localizedDescription)
                        let error = NSError(domain:"", code:0, userInfo:[NSLocalizedDescriptionKey: error.localizedDescription])
                        completionHandler(APIResult.failure(error))
                    }
                    
                    HUD.hide()
                }
            }
        }
    }
    
    func recoveryPasswordCode(userName: String, recoveryEmail: String, completionHandler: @escaping (APIResult<Any>) -> Void) {
        
        HUD.show(.progress)
        
        restAPIService?.recoveryPasswordCode(userName: userName, recoveryEmail: recoveryEmail) {(result) in
            
            switch(result) {
                
            case .success(let value):
                
                if let response = value as? Dictionary<String, Any> {
                    print("recoveryPasswordCode response", response)
                    if let message = self.parseServerResponse(response:response) {
                        let error = NSError(domain:"", code:0, userInfo:[NSLocalizedDescriptionKey: message])
                        completionHandler(APIResult.failure(error))
                    } else {
                        completionHandler(APIResult.success("success"))
                    }
                } else {
                    let error = NSError(domain:"", code:0, userInfo:[NSLocalizedDescriptionKey: "Responce have unknown format"])
                    completionHandler(APIResult.failure(error))
                }
                
            case .failure(let error):
                let error = NSError(domain:"", code:0, userInfo:[NSLocalizedDescriptionKey: error.localizedDescription])
                completionHandler(APIResult.failure(error))
            }
            
            HUD.hide()
        }
    }
    
    func resetPassword(resetPasswordCode: String, userName: String, password: String, recoveryEmail: String, completionHandler: @escaping (APIResult<Any>) -> Void) {
        
        print("userName:", userName)
        print("password:", password)
        print("resetPasswordCode:", resetPasswordCode)
        print("recoveryEmail:", recoveryEmail)
        
        let userPGPKey = pgpService?.generateUserPGPKeys(userName: userName, password: password)
        
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
        
        getHashedPassword(userName: userName, password: password) { (complete) in
            if complete {
        
                self.restAPIService?.resetPassword(resetPasswordCode: resetPasswordCode, userName: userName, password: self.hashedPassword!, privateKey: (userPGPKey?.privateKey)!, publicKey: (userPGPKey?.publicKey)!, fingerprint: (userPGPKey?.fingerprint)!, recoveryEmail: recoveryEmail) {(result) in
                    
                    switch(result) {
                        
                    case .success(let value):
                        
                        if let response = value as? Dictionary<String, Any> {
                            print("resetPassword response", response)
                            if let message = self.parseServerResponse(response:response) {
                                let error = NSError(domain:"", code:0, userInfo:[NSLocalizedDescriptionKey: message])
                                completionHandler(APIResult.failure(error))
                            } else {
                                completionHandler(APIResult.success("success"))
                            }
                        } else {
                            let error = NSError(domain:"", code:0, userInfo:[NSLocalizedDescriptionKey: "Responce have unknown format"])
                            completionHandler(APIResult.failure(error))
                        }
                        
                    case .failure(let error):
                        let error = NSError(domain:"", code:0, userInfo:[NSLocalizedDescriptionKey: error.localizedDescription])
                        completionHandler(APIResult.failure(error))
                    }
                    
                    HUD.hide()
                }
            }
        }
    }
    
    func logOut(completionHandler: @escaping (APIResult<Any>) -> Void) {
        
        keychainService?.deleteUserCredentialsAndToken()
        pgpService?.deleteStoredPGPKeys()
        
        showLoginViewController()
    }
    
    func verifyToken(completionHandler: @escaping (APIResult<Any>) -> Void) {
        
        //HUD.show(.progress)
        
        if let token = getToken() {
        
            restAPIService?.verifyToken(token: token)  {(result) in
                
                switch(result) {
                    
                case .success(let value):
                    
                    if let response = value as? Dictionary<String, Any> {
                        print("verifyToken response", response)
                        if let message = self.parseServerResponse(response:response) {
                            let error = NSError(domain:"", code:0, userInfo:[NSLocalizedDescriptionKey: message])
                            completionHandler(APIResult.failure(error))
                        } else {
                            completionHandler(APIResult.success("success"))
                        }
                    } else {
                        let error = NSError(domain:"", code:0, userInfo:[NSLocalizedDescriptionKey: "Responce have unknown format"])
                        completionHandler(APIResult.failure(error))
                    }
                    
                case .failure(let error):
                    let error = NSError(domain:"", code:0, userInfo:[NSLocalizedDescriptionKey: error.localizedDescription])
                    completionHandler(APIResult.failure(error))
                }
                
                HUD.hide()
            }
        }
    }
    
    //MARK: - Mail
    
    func messagesList(completionHandler: @escaping (APIResult<Any>) -> Void) {

        self.checkTokenExpiration(){ (complete) in
            if complete {
                
                if let token = self.getToken() {
                    
                    HUD.show(.progress)
                    
                    self.restAPIService?.messagesList(token: token) {(result) in
                        
                        switch(result) {
                            
                        case .success(let value):
                            
                            print("messagesList success:", value)
                            
                            if let response = value as? Dictionary<String, Any> {
                                
                                if let message = self.parseServerResponse(response:response) {
                                    print("messagesList message:", message)
                                    let error = NSError(domain:"", code:0, userInfo:[NSLocalizedDescriptionKey: message])
                                    completionHandler(APIResult.failure(error))
                                } else {
                                    let emailMessages = EmailMessagesList(dictionary: response)
                                    completionHandler(APIResult.success(emailMessages))
                                }
                            } else {
                                let error = NSError(domain:"", code:0, userInfo:[NSLocalizedDescriptionKey: "Responce have unknown format"])
                                completionHandler(APIResult.failure(error))
                            }
                            
                        case .failure(let error):
                            let error = NSError(domain:"", code:0, userInfo:[NSLocalizedDescriptionKey: error.localizedDescription])
                            completionHandler(APIResult.failure(error))
                        }
                        
                        HUD.hide()
                    }
                }
            }
        }
    }
    
    func mailboxesList(completionHandler: @escaping (APIResult<Any>) -> Void) {
        
        self.checkTokenExpiration(){ (complete) in
            if complete {
                
                if let token = self.getToken() {
                    
                    //HUD.show(.progress) //crashed when method used in root view controller
                    
                    self.restAPIService?.mailboxesList(token: token) {(result) in
                        
                        switch(result) {
                            
                        case .success(let value):
                            
                            //print("mailboxesList success:", value)
                            
                            if let response = value as? Dictionary<String, Any> {
                                
                                if let message = self.parseServerResponse(response:response) {
                                    //print("mailboxesList message:", message)
                                    let error = NSError(domain:"", code:0, userInfo:[NSLocalizedDescriptionKey: message])
                                    completionHandler(APIResult.failure(error))
                                } else {
                                    let mailbox = Mailbox(dictionary: response)
                                    completionHandler(APIResult.success(mailbox))
                                }
                            } else {
                                let error = NSError(domain:"", code:0, userInfo:[NSLocalizedDescriptionKey: "Responce have unknown format"])
                                completionHandler(APIResult.failure(error))
                            }
                            
                        case .failure(let error):
                            let error = NSError(domain:"", code:0, userInfo:[NSLocalizedDescriptionKey: error.localizedDescription])
                            completionHandler(APIResult.failure(error))
                        }
                        
                        HUD.hide()
                    }
                }
            }
        }
    }
    
    //MARK: - Local services
    
    func saveToken(token: String) {
        
        keychainService?.saveToken(token: token)
    }
    
    func getToken() -> String? {
        
        if let token = keychainService?.getToken() {
            
            if token.count > 0 {
                return token
            } else {
                showLoginViewController()
                return nil
            }
        }
        
        showLoginViewController()
        return nil
    }
    
    func checkTokenExpiration(completion:@escaping (Bool) -> () ) {

        if let tokenSavedTime = keychainService?.getTokenSavedTime() {
            if tokenSavedTime.count > 0 {
                
                if let tokenSavedDate = formatterService?.formatTokenTimeStringToDate(date: tokenSavedTime) {
                    print("tokenSavedDate:", tokenSavedDate)
                    
                    let minutesCount = tokenSavedDate.minutesCountForTokenExpiration()
                    if minutesCount > k_tokenMinutesExpiration {
                       
                        self.autologin(){ (complete) in
                            if complete {
                                completion(true)
                                return
                            }
                        }
                        
                    } else {
                        print("token is valid")
                        completion(true)
                        return
                    }
                }
            }
        }
        
        self.autologin(){ (complete) in
            if complete {
                completion(true)
            }
        }
    }
    
    //MARK: - Parcing
    
    func parseServerResponse(response: Dictionary<String, Any>) -> String? {
        
        var message: String? = nil
        
        for dictionary in response {
            
            switch dictionary.key {
            case APIResponse.token.rawValue :
                if let token = dictionary.value as? String {
                    saveToken(token: token)
                } else {
                    message = "Token Error"
                }
                break
            case APIResponse.tokenExpired.rawValue :
                print("tokenExpired APIResponce key:", dictionary.key, "value:", dictionary.value)
                if let value = dictionary.value as? String { //temp
                    if value == APIResponse.tokenExpiredValue.rawValue || value == APIResponse.noCredentials.rawValue {
                        //self.autologinWhenTokenExpired()
                    }
                }
                break
            case APIResponse.tokenExpiredValue.rawValue :
                //self.autologinWhenTokenExpired()
                break
            case APIResponse.usernameError.rawValue :
                if let errorMessage = extractErrorTextFrom(value: dictionary.value) {
                    message = "Username field.\n" + errorMessage
                }
                break
            case APIResponse.passwordError.rawValue :
                if let errorMessage = extractErrorTextFrom(value: dictionary.value) {
                    message = "Password field.\n" + errorMessage
                }
                break
            case APIResponse.nonFieldError.rawValue :
                message = extractErrorTextFrom(value: dictionary.value)
            
                if let texts = dictionary.value as? Array<Any> { // when checking Token verification catch if Token expired 
                    if let value = texts.first as? String {
                        print("value: ", value)
                        if value == APIResponse.tokenExpiredValue.rawValue || value == APIResponse.noCredentials.rawValue {
                            //self.autologinWhenTokenExpired()
                        }
                    }
                }

                break
            case APIResponse.userExists.rawValue :
                if let userExists = dictionary.value as? Int {
                    if userExists == 1 {
                        message = "This name already exists!"
                    }
                } else {
                    message = "Unknown Error"
                }
                break
            case APIResponse.pageConut.rawValue :
                //do nothing
                break
            case APIResponse.results.rawValue :
                //do nothing
                break
            default:
                print("APIResponce key:", dictionary.key, "value:", dictionary.value)
                if let errorMessage = extractErrorTextFrom(value: dictionary.value) {
                    message = dictionary.key + ": " + errorMessage
                }
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
        } else {
            return value as? String
        }
        
        return ""
    }
/*
    func autologinWhenTokenExpired() {
        
        let storedUserName = keychainService?.getUserName()
        let storedPassword = keychainService?.getPassword()
        
        if (storedUserName?.count)! < 1 || (storedPassword?.count)! < 1 {
            print("wrong stored credentials!")
            showLoginViewController()
            return
        }
        
        self.authenticateUser(userName: storedUserName!, password: storedPassword!) {(result) in
            
            switch(result) {
                
            case .success(let value):
                print("autologin success value:", value)
                //need repeat request
              
            case .failure(let error):
                print("autologin error:", error)
                
                if let topViewController = UIApplication.topViewController() {
                    AlertHelperKit().showAlert(topViewController, title: "Autologin Error", message: error.localizedDescription, button: "closeButton".localized())
                }
            }
        }
    }
    */
    func showLoginViewController() {
        
        if let topViewController = UIApplication.topViewController() {
            
            var storyboardName : String? = k_LoginStoryboardName
            
            if (Device.IS_IPAD) {
                storyboardName = k_LoginStoryboardName_iPad
            }
            
            let storyboard: UIStoryboard = UIStoryboard(name: storyboardName!, bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: k_LoginViewControllerID) as! LoginViewController
            topViewController.present(vc, animated: true, completion: nil)
        }
    }
}
