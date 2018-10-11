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
    case passwordError    = "password"
    case usernameError    = "username"
    case nonFieldError    = "non_field_errors"
    case recaptchaError   = "recaptcha"
    case fingerprintError = "fingerprint"
    case userExists       = "exists"
    case tokenExpired     = "details"
    
    //email messages
    case pageConut        = "page_count"
    case results          = "results"
}

class APIService {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var restAPIService  : RestAPIService?
    var keychainService : KeychainService?
    var pgpService      : PGPService?
    var formatterService: FormatterService?
    
    
    func initialize() {
       
        self.restAPIService = appDelegate.applicationManager.restAPIService
        self.keychainService = appDelegate.applicationManager.keychainService
        self.pgpService = appDelegate.applicationManager.pgpService
        self.formatterService = appDelegate.applicationManager.formatterService
    }
    
    //MARK: - authentication
    
    func authenticateUser(userName: String, password: String, completionHandler: @escaping (APIResult<Any>) -> Void) {
        
        var hashedPassword: String?
        
        if let salt = formatterService?.generateSaltFrom(userName: userName) {
            print("salt:", salt)
            hashedPassword = formatterService?.hash(password: password, salt: salt)
            print("hashedPassword:", hashedPassword as Any)
        }
        
        if hashedPassword == nil {
            print("hashedPassword is nil")
            return
        }
        
        if (hashedPassword?.count)! < 1 {
            print("hashedPassword is short")
            return
        }
        
        //==temp avoid login with hashed password problem
        hashedPassword = password
        //========================
        
        HUD.show(.progress)
        
        restAPIService?.authenticateUser(userName: userName, password: hashedPassword!) {(result) in
            
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
        
        var hashedPassword: String?
        
        if let salt = formatterService?.generateSaltFrom(userName: userName) {
            print("generated salt:", salt)
            hashedPassword = formatterService?.hash(password: password, salt: salt)
            print("hashedPassword:", hashedPassword!)
        }
        
        if hashedPassword == nil {
            print("hashedPassword is nil")
            return
        }
        
        if (hashedPassword?.count)! < 1 {
            print("hashedPassword is short")
            return
        }

        //==temp avoid login with hashed password problem
        hashedPassword = password
        //========================
        
        HUD.show(.progress)
        
        restAPIService?.signUp(userName: userName, password: hashedPassword!, privateKey: (userPGPKey?.privateKey)!, publicKey: (userPGPKey?.publicKey)!, fingerprint: (userPGPKey?.fingerprint)!, recaptcha: "1", recoveryEmail: recoveryEmail, fromAddress: "", redeemCode: "", stripeToken: "", memory: "", emailCount: "", paymentType: "") {(result) in
            
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
    
    //MARK: - Mail
    
    func messagesList(completionHandler: @escaping (APIResult<Any>) -> Void) {
        
        if let token = getToken() {
            
            HUD.show(.progress)
            
            restAPIService?.messagesList(token: token) {(result) in
                
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
    
    func mailboxesList(completionHandler: @escaping (APIResult<Any>) -> Void) {
        
        if let token = getToken() {
            
            //HUD.show(.progress) //crashed when method used in root view controller
            
            restAPIService?.mailboxesList(token: token) {(result) in
                
                switch(result) {
                    
                case .success(let value):
                    
                    print("mailboxesList success:", value)
                    
                    if let response = value as? Dictionary<String, Any> {
                        
                        if let message = self.parseServerResponse(response:response) {
                            print("mailboxesList message:", message)
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
    
    //Mark: - local services
    
    func saveToken(token: String) {
        
        keychainService?.saveToken(token: token)
    }
    
    func getToken() -> String? {
        
        return keychainService?.getToken()
    }
    
    func parseServerResponse(response: Dictionary<String, Any>) -> String? {
        
        var message: String? = nil
        
        for dictionary in response {
            
            switch dictionary.key {
            case APIResponse.token.rawValue :
                if let token = dictionary.value as? String {
                    saveToken(token: token)
                } else {
                    message = "Unknown Error"
                }
                break
            case APIResponse.tokenExpired.rawValue :
                print("tokenExpired APIResponce key:", dictionary.key, "value:", dictionary.value)
                self.showLoginViewController()
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
    
    func showLoginViewController() {
        
        if let topController = UIApplication.topViewController() {
            
            var storyboardName : String? = k_LoginStoryboardName
            
            if (Device.IS_IPAD) {
                storyboardName = k_LoginStoryboardName_iPad
            }
            
            let storyboard: UIStoryboard = UIStoryboard(name: storyboardName!, bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: k_LoginViewControllerID) as! LoginViewController
            ///topController.show(vc, sender: self)
            topController.present(vc, animated: true, completion: nil)
        }
    }
}
