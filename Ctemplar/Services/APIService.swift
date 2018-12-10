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
import MobileCoreServices

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
    case errorDetail       = "detail"
    case tokenExpiredValue = "Signature has expired."
    case noCredentials     = "Invalid Authorization header. No credentials provided."
    
    //email messages
    case pageConut         = "page_count"
    case results           = "results"
    case error             = "error"
    case expires           = "expires"
}

class APIService {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var restAPIService  : RestAPIService?
    var keychainService : KeychainService?
    var pgpService      : PGPService?
    var formatterService: FormatterService?
    
    var hashedPassword: String?
    
    @objc func getHashedPassword(userName: String, password: String, completion:@escaping (Bool) -> () ) {
        
        //DispatchQueue.main.async {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300), execute: {
            if let salt = self.formatterService?.generateSaltFrom(userName: userName) {
                print("salt:", salt)
                
                if self.hashedPassword != nil {
                    print("already hashedPassword:", self.hashedPassword as Any)
                    completion(true)
                    return
                }
                
                self.hashedPassword = self.formatterService?.hash(password: password, salt: salt)
                print("hashedPassword:", self.hashedPassword as Any)
            }
            completion(true)
        }
        )
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
        
        self.hashedPassword = nil
        
        keychainService?.deleteUserCredentialsAndToken()
        pgpService?.deleteStoredPGPKeys()
        
        completionHandler(APIResult.success("success"))
        //showLoginViewController()
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
    
    //MARK: - User
    
    func userMyself(completionHandler: @escaping (APIResult<Any>) -> Void) {
        
        self.checkTokenExpiration(){ (complete) in
            if complete {
                
                if let token = self.getToken() {
                    
                    //HUD.show(.progress)
                    
                    self.restAPIService?.userMyself(token: token) {(result) in
                        
                        switch(result) {
                            
                        case .success(let value):
                            
                           // print("userMyself success:", value)
                            
                            if let response = value as? Dictionary<String, Any> {                            
                                
                                if let message = self.parseServerResponse(response:response) {
                                    print("userMyself message:", message)
                                    let error = NSError(domain:"", code:0, userInfo:[NSLocalizedDescriptionKey: message])
                                    completionHandler(APIResult.failure(error))
                                } else {
                                    let userMyself = UserMyself(dictionary: response)
                                    completionHandler(APIResult.success(userMyself))
                                }
                            } else {
                                let error = NSError(domain:"", code:0, userInfo:[NSLocalizedDescriptionKey: "Responce have unknown format"])
                                completionHandler(APIResult.failure(error))
                            }
                            
                        case .failure(let error):
                            let error = NSError(domain:"", code:0, userInfo:[NSLocalizedDescriptionKey: error.localizedDescription])
                            completionHandler(APIResult.failure(error))
                        }
                        
                        //HUD.hide()
                    }
                }
            }
        }
    }
    
    //MARK: - Mail
    
    func messagesList(folder: String, messagesIDIn: String, seconds: Int, completionHandler: @escaping (APIResult<Any>) -> Void) {
        
        var folderFilter = ""
        
        if folder.count > 0 {
            if folder == MessagesFoldersName.starred.rawValue {
                folderFilter = "?starred=1"
            } else {
                folderFilter = "?folder=" + folder
            }
        }
        
        var messagesIDInParameter = ""
        
        if messagesIDIn.count > 0 {
            messagesIDInParameter = "?id__in=" + messagesIDIn
        }

        self.checkTokenExpiration(){ (complete) in
            if complete {
                
                if let token = self.getToken() {
                    
                    //HUD.show(.progress)
                    
                    self.restAPIService?.messagesList(token: token, folder: folderFilter, messagesIDIn: messagesIDInParameter, seconds: seconds) {(result) in
                        
                        switch(result) {
                            
                        case .success(let value):
                            
                            //print("messagesList success:", value)
                            
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
                        
                        //HUD.hide()
                    }
                }
            }
        }
    }
    
    func updateMessages(messageID: String, messagesIDIn: String, folder: String, starred: Bool, read: Bool, updateFolder: Bool, updateStarred: Bool, updateRead: Bool, completionHandler: @escaping (APIResult<Any>) -> Void) {
        
        var messageIDParameter = ""
        
        if messageID.count > 0 {
            messageIDParameter = messageID + "/"
        }
    
        var messagesIDInParameter = ""
        
        if messagesIDIn.count > 0 {
            messagesIDInParameter = "?id__in=" + messagesIDIn
        }
        
        self.checkTokenExpiration(){ (complete) in
            if complete {
                
                if let token = self.getToken() {
                    
                    //HUD.show(.progress)
                    
                    self.restAPIService?.updateMessages(token: token, messageID: messageIDParameter, messagesIDIn: messagesIDInParameter, folder: folder, starred: starred, read: read, updateFolder: updateFolder, updateStarred: updateStarred, updateRead: updateRead) {(result) in
                        
                        switch(result) {
                            
                        case .success(let value):
                            
                            print("updateMessages success:", value)
                            
                            if let response = value as? Dictionary<String, Any> {
                                
                                if let message = self.parseServerResponse(response:response) {
                                    print("updateMessages message:", message)
                                    let error = NSError(domain:"", code:0, userInfo:[NSLocalizedDescriptionKey: message])
                                    completionHandler(APIResult.failure(error))
                                } else {
                                    //
                                    completionHandler(APIResult.success(value))
                                }
                            } else {
                               // let error = NSError(domain:"", code:0, userInfo:[NSLocalizedDescriptionKey: "Responce have unknown format"])
                               // completionHandler(APIResult.failure(error))
                                completionHandler(APIResult.success(value))
                            }
                            
                        case .failure(let error):
                            let error = NSError(domain:"", code:0, userInfo:[NSLocalizedDescriptionKey: error.localizedDescription])
                            completionHandler(APIResult.failure(error))
                        }
                        
                        //HUD.hide()
                    }
                }
            }
        }
    }
    
    func updateSendingMessage(messageID: String, encryptedMessage: String, subject: String, recieversList: Array<String>, folder: String, send: Bool, encryptionObject: [String : String], encrypted: Bool, completionHandler: @escaping (APIResult<Any>) -> Void) {
        
        self.checkTokenExpiration(){ (complete) in
            if complete {
                
                if let token = self.getToken() {
                    
                    HUD.show(.progress)
                    
                    self.restAPIService?.updateSendingMessage(token: token, messageID: messageID, encryptedMessage: encryptedMessage, subject: subject, recieversList: recieversList, folder: folder, send: send, encryptionObject: encryptionObject, encrypted: encrypted) {(result) in
                        
                        switch(result) {
                            
                        case .success(let value):
                            
                            print("updateSendingMessages success:", value)
                            
                            if let response = value as? Dictionary<String, Any> {
                                
                                if let message = self.parseServerResponse(response:response) {
                                    print("updateSendingMessages message:", message)
                                    let error = NSError(domain:"", code:0, userInfo:[NSLocalizedDescriptionKey: message])
                                    completionHandler(APIResult.failure(error))
                                } else {
                                    //completionHandler(APIResult.success(value))
                                    let emailMessage = EmailMessage(dictionary: response)
                                    completionHandler(APIResult.success(emailMessage))
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
                                    let mailboxes = Mailboxes(dictionary: response)
                                    completionHandler(APIResult.success(mailboxes))
                                }
                            } else {
                                let error = NSError(domain:"", code:0, userInfo:[NSLocalizedDescriptionKey: "Responce have unknown format"])
                                completionHandler(APIResult.failure(error))
                            }
                            
                        case .failure(let error):
                            let error = NSError(domain:"", code:0, userInfo:[NSLocalizedDescriptionKey: error.localizedDescription])
                            completionHandler(APIResult.failure(error))
                        }
                        
                        //HUD.hide()
                    }
                }
            }
        }
    }
    
    func unreadMessagesCounter(completionHandler: @escaping (APIResult<Any>) -> Void) {
        
        self.checkTokenExpiration(){ (complete) in
            if complete {
                
                if let token = self.getToken() {
                    
                    //HUD.show(.progress)
                    
                    self.restAPIService?.unreadMessagesCounter(token: token) {(result) in
                        
                        switch(result) {
                            
                        case .success(let value):
                            
                            //print("unreadMessagesCounter success:", value)
                            
                            if let response = value as? Dictionary<String, Any> {
                                
                                if let message = self.parseServerResponse(response:response) {
                                    //print("unreadMessagesCounter message:", message)
                                    let error = NSError(domain:"", code:0, userInfo:[NSLocalizedDescriptionKey: message])
                                    completionHandler(APIResult.failure(error))
                                } else {                              
                                    completionHandler(APIResult.success(response))
                                }                            
                            } else {
                                let error = NSError(domain:"", code:0, userInfo:[NSLocalizedDescriptionKey: "Responce have unknown format"])
                                completionHandler(APIResult.failure(error))
                            }
                            
                        case .failure(let error):
                            let error = NSError(domain:"", code:0, userInfo:[NSLocalizedDescriptionKey: error.localizedDescription])
                            completionHandler(APIResult.failure(error))
                        }
                        
                        //HUD.hide()
                    }
                }
            }
        }
    }
    
    func createMessage(content: String, subject: String, recieversList: Array<String>, folder: String, mailboxID: Int, send: Bool, encrypted: Bool, encryptionObject: [String : String], completionHandler: @escaping (APIResult<Any>) -> Void) {
        
        self.checkTokenExpiration(){ (complete) in
            if complete {
                
                if let token = self.getToken() {
                    
                    HUD.show(.progress)
                    
                    self.restAPIService?.createMessage(token: token, content: content, subject: subject, recieversList: recieversList, folder: folder, mailboxID: mailboxID, send: send, encrypted: encrypted, encryptionObject: encryptionObject) {(result) in
                        
                        switch(result) {
                            
                        case .success(let value):
                            
                           //print("createMessage success:", value)
                            
                            if let response = value as? Dictionary<String, Any> {
                                
                                if let message = self.parseServerResponse(response:response) {
                                    //print("unreadMessagesCounter message:", message)
                                    let error = NSError(domain:"", code:0, userInfo:[NSLocalizedDescriptionKey: message])
                                    completionHandler(APIResult.failure(error))
                                } else {
                                    //completionHandler(APIResult.success(response))
                                    
                                    let emailMessage = EmailMessage(dictionary: response)
                                    completionHandler(APIResult.success(emailMessage))
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
    
    func deleteMessages(messagesIDIn: String, completionHandler: @escaping (APIResult<Any>) -> Void) {
        
        var messagesIDInParameter = ""
        
        if messagesIDIn.count > 0 {
            messagesIDInParameter = "?id__in=" + messagesIDIn
        }
        
        self.checkTokenExpiration(){ (complete) in
            if complete {
                
                if let token = self.getToken() {
                    
                    //HUD.show(.progress)
                    
                    self.restAPIService?.deleteMessages(token: token, messagesIDIn: messagesIDInParameter) {(result) in
                        
                        switch(result) {
                            
                        case .success(let value):
                            
                            print("deleteMessages success:", value)
                            completionHandler(APIResult.success(value))
                            
                        case .failure(let error):
                            let error = NSError(domain:"", code:0, userInfo:[NSLocalizedDescriptionKey: error.localizedDescription])
                            completionHandler(APIResult.failure(error))
                        }
                        
                        //HUD.hide()
                    }
                }
            }
        }
    }
    
    func publicKeyList(completionHandler: @escaping (APIResult<Any>) -> Void) {
        
        self.checkTokenExpiration(){ (complete) in
            if complete {
                
                if let token = self.getToken() {
                    
                    //HUD.show(.progress)
                    
                    self.restAPIService?.publicKeyList(token: token) {(result) in
                        
                        switch(result) {
                            
                        case .success(let value):
                            
                            print("publicKeyList success:", value)
                            completionHandler(APIResult.success(value))
                            
                        case .failure(let error):
                            let error = NSError(domain:"", code:0, userInfo:[NSLocalizedDescriptionKey: error.localizedDescription])
                            completionHandler(APIResult.failure(error))
                        }
                        
                        //HUD.hide()
                    }
                }
            }
        }
    }
    
    func publicKeyFor(userEmailsArray: Array<String>, completionHandler: @escaping (APIResult<Any>) -> Void) {
        
        self.checkTokenExpiration(){ (complete) in
            if complete {
                
                if let token = self.getToken() {
                    
                    //HUD.show(.progress)
                    
                    var userEmailParameters = ""
                    
                    for email in userEmailsArray {
                        userEmailParameters = userEmailParameters + email + ","
                    }
                    
                    if userEmailsArray.count > 0 {
                        userEmailParameters = String(userEmailParameters.dropLast())
                    }
                    
                    //print("userEmailParameters", userEmailParameters)
                    
                    self.restAPIService?.publicKeyFor(userEmail: userEmailParameters, token: token) {(result) in
                        
                        switch(result) {
                            
                        case .success(let value):
                            
                            //print("publicKeyFor success:", value)
                            
                            if let response = value as? Dictionary<String, Any> {
                                
                                if let message = self.parseServerResponse(response:response) {
                                    let error = NSError(domain:"", code:0, userInfo:[NSLocalizedDescriptionKey: message])
                                    completionHandler(APIResult.failure(error))
                                } else {
                                    
                                    for dictionary in response {
                                        
                                        if dictionary.key == "results" {
                                            //print("dictionary:", dictionary.value)
                                            
                                            var publicKeysArray = Array<Any>()
                                            
                                            let array = dictionary.value as! Array<Any>
                                            for item in array {
                                                //print("item:", item)
                                                let keysDictionary = item as! [String : Any]
                                                
                                                for (key, value) in keysDictionary {
                                                    if key == "public_key" {
                                                        print("public Key:", value)
                                                        publicKeysArray.append(value)
                                                        //completionHandler(APIResult.success(value))
                                                        //return
                                                    }
                                                }
                                            }
                                            
                                            completionHandler(APIResult.success(publicKeysArray))
                                        }
                                    }                                    
                                }
                                
                            } else {
                                let error = NSError(domain:"", code:0, userInfo:[NSLocalizedDescriptionKey: "Responce have unknown format"])
                                completionHandler(APIResult.failure(error))
                            }
                            
                            
                            
                            //completionHandler(APIResult.success(value))
                            
                        case .failure(let error):
                            let error = NSError(domain:"", code:0, userInfo:[NSLocalizedDescriptionKey: error.localizedDescription])
                            completionHandler(APIResult.failure(error))
                        }
                        
                        //HUD.hide()
                    }
                }
            }
        }
    }
    
    //MARK: - Folders
    
    func customFoldersList(limit: Int, offset: Int, completionHandler: @escaping (APIResult<Any>) -> Void) {
        
        self.checkTokenExpiration(){ (complete) in
            if complete {
                
                if let token = self.getToken() {
                    
                    //HUD.show(.progress)
                    
                    self.restAPIService?.customFoldersList(token: token, limit: limit, offset: offset) {(result) in
                        
                        switch(result) {
                            
                        case .success(let value):
                            
                            //print("customFoldersList success:", value)
                            
                            if let response = value as? Dictionary<String, Any> {
                                
                                if let message = self.parseServerResponse(response:response) {
                                    //print("customFoldersList message:", message)
                                    let error = NSError(domain:"", code:0, userInfo:[NSLocalizedDescriptionKey: message])
                                    completionHandler(APIResult.failure(error))
                                } else {
                                    let customFolders = FolderList(dictionary: response)
                                    completionHandler(APIResult.success(customFolders))
                                }
                                
                            } else {
                                let error = NSError(domain:"", code:0, userInfo:[NSLocalizedDescriptionKey: "Responce have unknown format"])
                                completionHandler(APIResult.failure(error))
                            }
                            
                        case .failure(let error):
                            let error = NSError(domain:"", code:0, userInfo:[NSLocalizedDescriptionKey: error.localizedDescription])
                            completionHandler(APIResult.failure(error))
                        }
                        
                        //HUD.hide()
                    }
                }
            }
        }
    }
    
    func createCustomFolder(name: String, color: String, completionHandler: @escaping (APIResult<Any>) -> Void) {
        
        self.checkTokenExpiration(){ (complete) in
            if complete {
                
                if let token = self.getToken() {
                    
                    //HUD.show(.progress)
                    
                    self.restAPIService?.createCustomFolder(token: token, name: name, color: color) {(result) in
                        
                        switch(result) {
                            
                        case .success(let value):
                            
                            print("createCustomFolder success:", value)
                            
                            if let response = value as? Dictionary<String, Any> {
                                
                                if let message = self.parseServerResponse(response:response) {
                                    //print("customFoldersList message:", message)
                                    let error = NSError(domain:"", code:0, userInfo:[NSLocalizedDescriptionKey: message])
                                    completionHandler(APIResult.failure(error))
                                } else {
                                    let customFolders = FolderList(dictionary: response)
                                    completionHandler(APIResult.success(customFolders))
                                }
                                
                            } else {
                                let error = NSError(domain:"", code:0, userInfo:[NSLocalizedDescriptionKey: "Responce have unknown format"])
                                completionHandler(APIResult.failure(error))
                            }
                            
                        case .failure(let error):
                            let error = NSError(domain:"", code:0, userInfo:[NSLocalizedDescriptionKey: error.localizedDescription])
                            completionHandler(APIResult.failure(error))
                        }
                        
                        //HUD.hide()
                    }
                }
            }
        }
    }
    
    //MARK: - Contacts
    
    func userContacts(contactsIDIn: String, completionHandler: @escaping (APIResult<Any>) -> Void) {
        
        var contactsIDInParameter = ""
        
        if contactsIDIn.count > 0 {
            contactsIDInParameter = "?id__in=" + contactsIDIn
        }
        
        self.checkTokenExpiration(){ (complete) in
            if complete {
                
                if let token = self.getToken() {
                    
                    self.restAPIService?.userContacts(token: token, contactsIDIn: contactsIDInParameter) {(result) in
                        
                        switch(result) {
                            
                        case .success(let value):
                            
                            if let response = value as? Dictionary<String, Any> {
                                
                                if let message = self.parseServerResponse(response:response) {
                                    let error = NSError(domain:"", code:0, userInfo:[NSLocalizedDescriptionKey: message])
                                    completionHandler(APIResult.failure(error))
                                } else {
                                    let contactsList = ContactsList(dictionary: response)
                                    completionHandler(APIResult.success(contactsList))
                                }
                                
                            } else {
                                let error = NSError(domain:"", code:0, userInfo:[NSLocalizedDescriptionKey: "Responce have unknown format"])
                                completionHandler(APIResult.failure(error))
                            }
                            
                        case .failure(let error):
                            let error = NSError(domain:"", code:0, userInfo:[NSLocalizedDescriptionKey: error.localizedDescription])
                            completionHandler(APIResult.failure(error))
                        }
                        
                    }
                }
            }
        }
    }
    
    func createContact(name: String, email: String, phone: String, address: String, note: String, completionHandler: @escaping (APIResult<Any>) -> Void) {
        
        self.checkTokenExpiration(){ (complete) in
            if complete {
                
                if let token = self.getToken() {
                    
                    self.restAPIService?.createContact(token: token, name: name, email: email, phone: phone, address: address, note: note)                    {(result) in
                        
                        switch(result) {
                            
                        case .success(let value):
                            
                            //print("createContacts success:", value)
                            //completionHandler(APIResult.success(value))
                            
                            if let response = value as? Dictionary<String, Any> {
                                
                                if let message = self.parseServerResponse(response:response) {
                                    let error = NSError(domain:"", code:0, userInfo:[NSLocalizedDescriptionKey: message])
                                    completionHandler(APIResult.failure(error))
                                } else {
                                    let contact = Contact(dictionary: response)
                                    completionHandler(APIResult.success(contact))
                                }
                                
                            } else {
                                let error = NSError(domain:"", code:0, userInfo:[NSLocalizedDescriptionKey: "Responce have unknown format"])
                                completionHandler(APIResult.failure(error))
                            }
                            
                        case .failure(let error):
                            let error = NSError(domain:"", code:0, userInfo:[NSLocalizedDescriptionKey: error.localizedDescription])
                            completionHandler(APIResult.failure(error))
                        }
                        
                    }
                }
            }
        }
    }
    
    func updateContact(contactID: String, name: String, email: String, phone: String, address: String, note: String, completionHandler: @escaping (APIResult<Any>) -> Void) {
        
        self.checkTokenExpiration(){ (complete) in
            if complete {
                
                if let token = self.getToken() {
                    
                    self.restAPIService?.updateContact(token: token, contactID: contactID, name: name, email: email, phone: phone, address: address, note: note) {(result) in
                        
                        switch(result) {
                            
                        case .success(let value):
                            
                            print("updateContact success:", value)
                            completionHandler(APIResult.success(value))
                            /*
                            if let response = value as? Dictionary<String, Any> {
                                
                                if let message = self.parseServerResponse(response:response) {
                                    let error = NSError(domain:"", code:0, userInfo:[NSLocalizedDescriptionKey: message])
                                    completionHandler(APIResult.failure(error))
                                } else {
                                    let contact = Contact(dictionary: response)
                                    completionHandler(APIResult.success(contact))
                                }
                                
                            } else {
                                let error = NSError(domain:"", code:0, userInfo:[NSLocalizedDescriptionKey: "Responce have unknown format"])
                                completionHandler(APIResult.failure(error))
                            }
                            */
                        case .failure(let error):
                            let error = NSError(domain:"", code:0, userInfo:[NSLocalizedDescriptionKey: error.localizedDescription])
                            completionHandler(APIResult.failure(error))
                        }
                        
                    }
                }
            }
        }
    }
    
    func deleteContacts(contactsIDIn: String, completionHandler: @escaping (APIResult<Any>) -> Void) {
        
        var contactsIDInParameter = ""
        
        if contactsIDIn.count > 0 {
            contactsIDInParameter = "?id__in=" + contactsIDIn
        }
        
        self.checkTokenExpiration(){ (complete) in
            if complete {
                
                if let token = self.getToken() {
                    
                    self.restAPIService?.deleteContacts(token: token, contactsIDIn: contactsIDInParameter) {(result) in
                        
                        switch(result) {
                            
                        case .success(let value):
                            
                            //print("deleteContact success:", value)
                            completionHandler(APIResult.success(value))
                            
                        case .failure(let error):
                            let error = NSError(domain:"", code:0, userInfo:[NSLocalizedDescriptionKey: error.localizedDescription])
                            completionHandler(APIResult.failure(error))
                        }
                    }
                }
            }
        }
    }
    
    //MARK: - Download
    
    func loadAttachFile(url: String, completionHandler: @escaping (APIResult<Any>) -> Void) {
        
        self.restAPIService?.loadAttachFile(url: url) {(result) in
            
            switch(result) {
                
            case .success(let value):
              
                completionHandler(APIResult.success(value))
                
            case .failure(let error):
                let error = NSError(domain:"", code:0, userInfo:[NSLocalizedDescriptionKey: error.localizedDescription])
                completionHandler(APIResult.failure(error))
            }
        }
    }
    
    //MARK: - Attachments
    
    func createAttachment(fileUrl: URL, messageID: String, completionHandler: @escaping (APIResult<Any>) -> Void) {
        
        let fileData = try? Data(contentsOf: fileUrl)
        let fileName = fileUrl.lastPathComponent
        let mimeType = self.mimeTypeForFileAt(url: fileUrl)
        
        if (fileData == nil) {
            return
        }        
        
        self.checkTokenExpiration(){ (complete) in
            if complete {
                
                if let token = self.getToken() {
                    
                    self.restAPIService?.createAttachment(token: token, file: fileData!, fileName: fileName, mimeType: mimeType, messageID: messageID) {(result) in
                        
                        switch(result) {
                            
                        case .success(let value):
                            
                            if let response = value as? Dictionary<String, Any> {
                                
                                if let message = self.parseServerResponse(response:response) {
                                    let error = NSError(domain:"", code:0, userInfo:[NSLocalizedDescriptionKey: message])
                                    completionHandler(APIResult.failure(error))
                                } else {
                                    let attachment = Attachment(dictionary: value as! [String : Any])
                                    completionHandler(APIResult.success(attachment))
                                }
                                
                            } else {
                                let error = NSError(domain:"", code:0, userInfo:[NSLocalizedDescriptionKey: "Responce have unknown format"])
                                completionHandler(APIResult.failure(error))
                            }
                            
                        case .failure(let error):
                            let error = NSError(domain:"", code:0, userInfo:[NSLocalizedDescriptionKey: error.localizedDescription])
                            completionHandler(APIResult.failure(error))
                        }
                    }
                }
            }
        }
    }
    
    func mimeTypeForFileAt(url: URL) -> String {
        
        let pathExtension = url.pathExtension
        
        if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension as NSString, nil)?.takeRetainedValue() {
            if let mimetype = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue() {
                return mimetype as String
            }
        }
        return "application/octet-stream"
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
            case APIResponse.errorDetail.rawValue :
                print("errorDetail APIResponce key:", dictionary.key, "value:", dictionary.value)
                message = extractErrorTextFrom(value: dictionary.value)
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
            case APIResponse.expires.rawValue :
                print("expires APIResponce key:", dictionary.key, "value:", dictionary.value)
                message = extractErrorTextFrom(value: dictionary.value)
                break
            default:
                print("Default case APIResponce key:", dictionary.key, "value:", dictionary.value)
               // if let errorMessage = extractErrorTextFrom(value: dictionary.value) {
               //     message = dictionary.key + ": " + errorMessage
               // }
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
        /*
        if let topViewController = UIApplication.topViewController() {
            
            var storyboardName : String? = k_LoginStoryboardName
            
            if (Device.IS_IPAD) {
                storyboardName = k_LoginStoryboardName_iPad
            }
            
            let storyboard: UIStoryboard = UIStoryboard(name: storyboardName!, bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: k_LoginViewControllerID) as! LoginViewController
            topViewController.present(vc, animated: false, completion: nil)
        }
 */
    }
}
