//
//  APIService.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 01.10.2018.
//  Copyright © 2018 CTemplar. All rights reserved.
//

import Foundation
import PKHUD
import AlertHelperKit
import MobileCoreServices
import ObjectivePGP

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
    case twoFAEnabled      = "is_2fa_enabled"
    
    //email messages
    case pageConut         = "page_count"
    case results           = "results"
    case error             = "error"
    case expires           = "expires"
}

class APIService: HashingService {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var restAPIService  : RestAPIService?
    var keychainService : KeychainService?
    var pgpService      : PGPService?
    var formatterService: FormatterService?
    
    var hashedPassword: String?
    
    var authErrorAlertAlreadyShowing = false    
    
    @objc func getHashedPassword(userName: String, password: String, completion:@escaping (Bool) -> () ) {
        
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
        })
    }
    
    @objc func getNewHashedPassword(userName: String, password: String, completion:@escaping (String) -> () ) {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300), execute: {
            if let salt = self.formatterService?.generateSaltFrom(userName: userName) {
                print("salt:", salt)
                
                let newHashedPassword = self.formatterService?.hash(password: password, salt: salt)
                print("newHashedPassword:", newHashedPassword as Any)
                completion(newHashedPassword!)
            }
        })
    }
    
    @objc func refreshToken(completion:@escaping (Bool) -> () ) {
        
//        DispatchQueue.main.async {
        
        let storedToken = self.keychainService?.getToken()
        DispatchQueue.global(qos: .userInitiated).async {
            self.restAPIService?.refreshToken(token: storedToken!) {(result) in
//                DispatchQueue.main.async {
                    switch(result) {
                        
                    case .success(let value):
                        print("refreshToken success value:", value)
                        
                        if let response = value as? Dictionary<String, Any> {
                            if let message = self.parseServerResponse(response:response) {
                                let error = NSError(domain:"", code:0, userInfo:[NSLocalizedDescriptionKey: message])
                                if !self.authErrorAlertAlreadyShowing {
                                    self.showErorrLoginAlert(error: error)
                                }
                                HUD.hide()
                                completion(false)
                            } else {
                                completion(true)
                            }
                        }
                        
                    case .failure(let error):
                        print("refreshToken error:", error)
                        let error = NSError(domain:"", code:0, userInfo:[NSLocalizedDescriptionKey: error.localizedDescription])
                        if !self.authErrorAlertAlreadyShowing {
                            self.showErorrLoginAlert(error: error)
                        }
                        
                        completion(false)
                    }
//                }
            }
        }
            
//        }
    }
     
    func initialize() {
       
        self.restAPIService = appDelegate.applicationManager.restAPIService
        self.keychainService = appDelegate.applicationManager.keychainService
        self.pgpService = appDelegate.applicationManager.pgpService
        self.formatterService = appDelegate.applicationManager.formatterService
    }
    
    //MARK: - authentication
    
    func logOut(completionHandler: @escaping (APIResult<Any>) -> Void) {
        
        self.checkTokenExpiration { (complete) in
            if complete {
                if let token = self.getToken(), let deviceToken = self.keychainService?.getAPNDeviceToken() {
                    self.restAPIService?.signOut(token: token, deviceToken: deviceToken, completionHandler: { (result) in
                        self.hashedPassword = nil
                        
                        self.keychainService?.deleteUserCredentialsAndToken()
                        self.pgpService?.deleteStoredPGPKeys()
                        
                        completionHandler(APIResult.success("success"))
                    })
                }else {
                    self.hashedPassword = nil
                    
                    self.keychainService?.deleteUserCredentialsAndToken()
                    self.pgpService?.deleteStoredPGPKeys()
                    
                    completionHandler(APIResult.success("success"))
                }
            }else {
                self.hashedPassword = nil
                
                self.keychainService?.deleteUserCredentialsAndToken()
                self.pgpService?.deleteStoredPGPKeys()
                
                completionHandler(APIResult.success("success"))
            }
        }
    }
    
    //MARK: - User
    
    func userMyself(completionHandler: @escaping (APIResult<Any>) -> Void) {
        
        self.checkTokenExpiration(){ (complete) in
            if complete {
                
                if let token = self.getToken() {
                    
                    //HUD.show(.progress)
                    DispatchQueue.global(qos: .background).async {
                        self.restAPIService?.userMyself(token: token) {(result) in
                            DispatchQueue.main.async {
                                switch(result) {
                                case .success(let value):
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
        }
    }
    
    //MARK: - Mail
    
    func messagesList(folder: String, messagesIDIn: String, seconds: Int, offset: Int, pageLimit: Int = k_pageLimit, completionHandler: @escaping (APIResult<Any>) -> Void) {
        
        var folderFilter = ""
        
        if folder.count > 0 {
            if folder == MessagesFoldersName.starred.rawValue {
                //folderFilter = "?starred=1"
                folderFilter = "&starred=1"
            } else {
                //folderFilter = "?folder=" + folder
                folderFilter = "&folder=" + folder
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
                    DispatchQueue.global(qos: .background).async {
                        self.restAPIService?.messagesList(token: token, folder: folderFilter, messagesIDIn: messagesIDInParameter, filter: "", seconds: seconds, offset: offset, pageLimit: pageLimit) {(result) in
                            DispatchQueue.main.async {
                                switch(result) {
                                case .success(let value):
                                    
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
                            }
                        }
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
    
    func updateSendingMessage(messageID: String, mailboxID: Int, sender: String, encryptedMessage: String, subject: String, recieversList: [[String]], folder: String, send: Bool, encryptionObject: [String : String], encrypted: Bool, subjectEncrypted: Bool, attachments: Array<[String : String]>, selfDestructionDate: String, delayedDeliveryDate: String, deadManDate: String, completionHandler: @escaping (APIResult<Any>) -> Void) {
        
        var setFolder : String = folder
        var setSend : Bool = send
        var deadManTimer : Int = 0
        
        if delayedDeliveryDate.count > 0 {
            setFolder = MessagesFoldersName.outbox.rawValue
            setSend = false
        }
        
        print("deadManDate:", deadManDate)
        print("deadManDate cnt:", deadManDate.count)
        
        if deadManDate.count > 0 {
            setFolder = MessagesFoldersName.outbox.rawValue
            setSend = false
            
            deadManTimer = Int(deadManDate)!
            print("deadManTimer:", deadManTimer)
        }
        
        self.checkTokenExpiration(){ (complete) in
            if complete {
                
                if let token = self.getToken() {
                    
                    HUD.show(.progress)
                    
                    self.restAPIService?.updateSendingMessage(token: token, messageID: messageID, mailboxID: mailboxID, sender: sender, encryptedMessage: encryptedMessage, subject: subject, recieversList: recieversList, folder: setFolder, send: setSend, encryptionObject: encryptionObject, encrypted: encrypted, subjectEncrypted: subjectEncrypted, attachments: attachments, selfDestructionDate: selfDestructionDate, delayedDeliveryDate: delayedDeliveryDate, deadManTimer: deadManTimer) {(result) in
                        
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
    
    func createMessage(parentID: String, content: String, subject: String, recieversList: [[String]], folder: String, mailboxID: Int, send: Bool, encrypted: Bool, encryptionObject: [String : String], attachments: Array<[String : String]>, showHud: Bool = true, completionHandler: @escaping (APIResult<Any>) -> Void) {
        
        self.checkTokenExpiration(){ (complete) in
            if complete {
                
                if let token = self.getToken() {
                    DispatchQueue.main.async {
                        if showHud {
                            HUD.show(.progress)
                        }
                    }
                    DispatchQueue.global(qos: .background).async {
                        self.restAPIService?.createMessage(token: token, parentID: parentID, content: content, subject: subject, recieversList: recieversList, folder: folder, mailboxID: mailboxID, send: send, encrypted: encrypted, encryptionObject: encryptionObject, attachments: attachments) {(result) in
                            DispatchQueue.main.async {
                                switch(result) {
                                case .success(let value):
                                    if let response = value as? Dictionary<String, Any> {
                                        if let message = self.parseServerResponse(response:response) {
                                            let error = NSError(domain:"", code:0, userInfo:[NSLocalizedDescriptionKey: message])
                                            completionHandler(APIResult.failure(error))
                                        } else {
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
                                if showHud {
                                    HUD.hide()
                                }
                            }
                        }
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
    
    func deleteMessage(messagesID: String, completionHandler: @escaping (APIResult<Any>) -> Void) {
        
        self.checkTokenExpiration(){ (complete) in
            if complete {
                
                if let token = self.getToken() {
                    
                    //HUD.show(.progress)
                    
                    self.restAPIService?.deleteMessage(token: token, messagesID: messagesID) {(result) in
                        
                        switch(result) {
                            
                        case .success(let value):
                            
                            print("deleteMessage success:", value)
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
    
    func saveDraftMesssage(messageID: String, messageContent: String, subject: String, recieversList: [[String]], folder: String, encryptionObject: [String : String], encrypted: Bool, selfDestructionDate: String, delayedDeliveryDate: String, deadManDate: String, completionHandler: @escaping (APIResult<Any>) -> Void) {
        
        var deadManTimer = 0
        
        if deadManDate.count > 0 {
            deadManTimer = Int(deadManDate)!
        }
        
        self.checkTokenExpiration(){ (complete) in
            if complete {
                
                if let token = self.getToken() {
                    
                    //HUD.show(.progress)
                    
                    self.restAPIService?.saveDraftMesssage(token: token, messageID: messageID, messageContent: messageContent, subject: subject, recieversList: recieversList, folder: folder, encryptionObject: encryptionObject, encrypted: encrypted, selfDestructionDate: selfDestructionDate, delayedDeliveryDate: delayedDeliveryDate, deadManTimer: deadManTimer) {(result) in
                        
                        switch(result) {
                            
                        case .success(let value):
                            
                            print("saveDraftMesssage success:", value)
                            
                            if let response = value as? Dictionary<String, Any> {
                                
                                if let message = self.parseServerResponse(response:response) {
                                    print("saveDraftMesssage message:", message)
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
                        
                        //HUD.hide()
                    }
                }
            }
        }
    }
    
    //MARK: - Mailbox
    
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
    
    
    func updateMailbox(mailboxID: String, userSignature: String, displayName: String, isDefault: Bool, completionHandler: @escaping (APIResult<Any>) -> Void) {
        
        self.checkTokenExpiration(){ (complete) in
            if complete {
                
                if let token = self.getToken() {
            
                    
                    self.restAPIService?.updateMailbox(token: token, mailboxID: mailboxID, userSignature: userSignature, displayName: displayName, isDefault: isDefault) {(result) in
                        
                        switch(result) {
                            
                        case .success(let value):
                            
                            print("updateMailbox success:", value)
                            
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
                    }
                }
            }
        }
    }
    
    func defaultMailbox(mailboxes: Array<Mailbox>) -> Mailbox {
        
        for mailbox in mailboxes {
            if let defaultMailbox = mailbox.isDefault {
                if defaultMailbox {
                    return mailbox
                }
            }
        }
        
        return mailboxes.first!
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
       
                    //print("userEmailParameters", userEmailParameters)
                    
                    self.restAPIService?.publicKeyFor(userEmails: userEmailsArray, token: token) {(result) in
                        
                        switch(result) {
                            
                        case .success(let value):
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
                                    let newFolder = Folder(dictionary: response)
//                                    let customFolders = FolderList(dictionary: response)
                                    completionHandler(APIResult.success(newFolder))
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
    
    func updateCustomFolder(folderID: String, name: String, color: String, completionHandler: @escaping (APIResult<Any>) -> Void) {
        
        self.checkTokenExpiration(){ (complete) in
            if complete {
                
                if let token = self.getToken() {
                    
                    //HUD.show(.progress)
                    
                    self.restAPIService?.updateCustomFolder(token: token, folderID: folderID, name: name, color: color) {(result) in
                        
                        switch(result) {
                            
                        case .success(let value):
                            
                            print("updateCustomFolder success:", value)
                            
                             if let response = value as? Dictionary<String, Any> {
                             
                                if let message = self.parseServerResponse(response:response) {
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
    
    func deleteCustomFolder(folderID: String, completionHandler: @escaping (APIResult<Any>) -> Void) {
        
        self.checkTokenExpiration(){ (complete) in
            if complete {
                
                if let token = self.getToken() {
                    
                    //HUD.show(.progress)
                    
                    self.restAPIService?.deleteCustomFolder(token: token, folderID: folderID) {(result) in
                        
                        switch(result) {
                            
                        case .success(let value):
                            
                            print("deleteCustomFolder success:", value)
                            /*
                            if let response = value as? Dictionary<String, Any> {
                                
                                if let message = self.parseServerResponse(response:response) {
                                    let error = NSError(domain:"", code:0, userInfo:[NSLocalizedDescriptionKey: message])
                                    completionHandler(APIResult.failure(error))
                                } else {
                                    let customFolders = FolderList(dictionary: response)
                                    completionHandler(APIResult.success(customFolders))
                                }
                                
                            } else {
                                let error = NSError(domain:"", code:0, userInfo:[NSLocalizedDescriptionKey: "Responce have unknown format"])
                                completionHandler(APIResult.failure(error))
                            }*/
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
    
    //MARK: - Contacts
    
    func decryptContactData(encryptedData: String) {
        
        
        
    }
    
    func userContacts(fetchAll: Bool, offset: Int, silent: Bool, completionHandler: @escaping (APIResult<Any>) -> Void) {
               
        self.checkTokenExpiration(){ (complete) in
            if complete {
                
                if let token = self.getToken() {
                    DispatchQueue.main.async {
                        if !silent {
                            HUD.show(.progress)
                        }
                    }
                    DispatchQueue.global(qos: .background).async {
                        self.restAPIService?.userContacts(token: token, fetchAll: fetchAll, offset: offset) {(result) in
                            DispatchQueue.main.async {
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
                                if !silent {
                                    HUD.hide()
                                }
                            }
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
    
    @objc func encryptedContactHash(contactEmail: String, contactAsStringDictionary: String, completion:@escaping (String) -> () ) {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100), execute: {
            if let salt = self.formatterService?.generateSaltFrom(userName: contactEmail) {
                print("salt:", salt)
                
                let encryptedContactHash = self.formatterService?.hash(password: contactAsStringDictionary, salt: salt)
                print("encryptContactHash:", encryptedContactHash as Any)
                completion(encryptedContactHash!)
            }
        })
    }
    
    func encryptContact(publicKeys: Array<Key>, contactAsJson: String) -> String {
        
        if let contactData = pgpService?.encodeString(message: contactAsJson) {
            
            if let encryptedContact = self.pgpService?.encrypt(data: contactData, keys: publicKeys) {
                print("encryptedContact:", encryptedContact)
                return encryptedContact
            }
        }
        
        return ""
    }
    
    func serializeContactToJson(name: String, email: String, phone: String, address: String, note: String) -> String {
        
        var jsonString = ""
        
        let dictionary = [
            JSONKey.folderName.rawValue: name,
            JSONKey.email.rawValue: email,
            JSONKey.phone.rawValue: phone,
            JSONKey.address.rawValue: address,
            JSONKey.note.rawValue: note
        ]
        
        let encoder = JSONEncoder()
        if let jsonData = try? encoder.encode(dictionary) {
            if let jsonStringEncoded = String(data: jsonData, encoding: .utf8) {
                print("JSON string = \n\(jsonStringEncoded)")
                jsonString = jsonStringEncoded
            }
        }
        
        return jsonString
    }
    
    func createEncryptedContact(name: String, email: String, phone: String, address: String, note: String, completionHandler: @escaping (APIResult<Any>) -> Void) {
        
        let jsonString = self.serializeContactToJson(name: name, email: email, phone: phone, address: address, note: note)
        
        if jsonString.count == 0 {
            let error = NSError(domain:"", code:0, userInfo:[NSLocalizedDescriptionKey: "JSON encoding error"])
            completionHandler(APIResult.failure(error))
            return
        }
        
        self.checkTokenExpiration(){ (complete) in
            if complete {
                
                if let token = self.getToken() {
                    
                    if let userKeys = self.pgpService?.getStoredPGPKeys() {
                        if userKeys.count > 0 {
                            let encryptedContact = self.encryptContact(publicKeys: userKeys, contactAsJson: jsonString)
                            
                            self.restAPIService?.createEncryptedContact(token: token, encryptedContact: encryptedContact, encryptedContactHash: "") {(result) in
                                
                                switch(result) {
                                    
                                case .success(let value):
                                    //print("createEncryptedContact success:", value)
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
        }
    }
    
    func updateEncryptedContact(contactID: String, name: String, email: String, phone: String, address: String, note: String, completionHandler: @escaping (APIResult<Any>) -> Void) {
        
        let jsonString = self.serializeContactToJson(name: name, email: email, phone: phone, address: address, note: note)
        
        if jsonString.count == 0 {
            let error = NSError(domain:"", code:0, userInfo:[NSLocalizedDescriptionKey: "JSON encoding error"])
            completionHandler(APIResult.failure(error))
            return
        }
        
        self.checkTokenExpiration(){ (complete) in
            if complete {
                
                if let token = self.getToken() {
                    
                    /*
                    self.encryptedContactHash(contactEmail: email, contactAsStringDictionary: json.description){ (encryptedContactHash) in
                    
                    }        */
                    
                    if let userKeys = self.pgpService?.getStoredPGPKeys() {
                        if userKeys.count > 0 {
                            let encryptedContact = self.encryptContact(publicKeys: userKeys, contactAsJson: jsonString)
                            
                            self.restAPIService?.updateEncryptedContact(token: token, contactID: contactID, encryptedContact: encryptedContact, encryptedContactHash: "") {(result) in
                                
                                switch(result) {
                                    
                                case .success(let value):
                                    //print("updateEncryptedContact success:", value)
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
        }
    }
    
    //MARK: - White/Black lists
    
    func addContactToBlackList(name: String, email: String, completionHandler: @escaping (APIResult<Any>) -> Void) {
        
        self.checkTokenExpiration(){ (complete) in
            if complete {
                
                if let token = self.getToken() {
                    self.restAPIService?.addContactToBlackList(token: token, name: name, email: email) {(result) in
            
                        switch(result) {
                
                        case .success(let value):
                
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
    
    func deleteContactFromBlackList(contactID: String, completionHandler: @escaping (APIResult<Any>) -> Void) {
        
        self.checkTokenExpiration(){ (complete) in
            if complete {
                
                if let token = self.getToken() {
                    self.restAPIService?.deleteContactFromBlackList(token: token, contactID: contactID) {(result) in
                        
                        switch(result) {
                            
                        case .success(let value):
                            
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
    
    func addContactToWhiteList(name: String, email: String, completionHandler: @escaping (APIResult<Any>) -> Void) {
        
        self.checkTokenExpiration(){ (complete) in
            if complete {
                
                if let token = self.getToken() {
                    self.restAPIService?.addContactToWhiteList(token: token, name: name, email: email) {(result) in
                        
                        switch(result) {
                            
                        case .success(let value):
                            
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
    
    func deleteContactFromWhiteList(contactID: String, completionHandler: @escaping (APIResult<Any>) -> Void) {
        
        self.checkTokenExpiration(){ (complete) in
            if complete {
                
                if let token = self.getToken() {
                    self.restAPIService?.deleteContactFromWhiteList(token: token, contactID: contactID) {(result) in
                        
                        switch(result) {
                            
                        case .success(let value):
                            
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
    
    func whiteListContacts(completionHandler: @escaping (APIResult<Any>) -> Void) {
        
        self.checkTokenExpiration(){ (complete) in
            if complete {
                
                if let token = self.getToken() {
                    
                    self.restAPIService?.whiteListContacts(token: token) {(result) in
                        
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
    
    func blackListContacts(completionHandler: @escaping (APIResult<Any>) -> Void) {
        
        self.checkTokenExpiration(){ (complete) in
            if complete {
                
                if let token = self.getToken() {
                    
                    self.restAPIService?.blackListContacts(token: token) {(result) in
                        
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
    
    func createAttachment(fileUrl: URL, messageID: String, encrypt: Bool, completionHandler: @escaping (APIResult<Any>) -> Void) {
        
        var fileData = try? Data(contentsOf: fileUrl)
        
        if encrypt {
            if let userKeys = self.pgpService?.getStoredPGPKeys() {
                if userKeys.count > 0 {
                    fileData = pgpService?.encryptAsData(data: fileData!, keys: userKeys)
                }
            }
        }
        
        let fileName = fileUrl.lastPathComponent
        let mimeType = self.mimeTypeForFileAt(url: fileUrl)
        
        if (fileData == nil) {
            return
        }        
        
        self.checkTokenExpiration(){ (complete) in
            if complete {
                
                if let token = self.getToken() {
                    
                    self.restAPIService?.createAttachment(token: token, file: fileData!, fileName: fileName, mimeType: mimeType, messageID: messageID, encrypted: encrypt) {(result) in
                        
                        switch(result) {
                            
                        case .success(let value):
                            
                            if let response = value as? Dictionary<String, Any> {
                                
                                if let message = self.parseServerResponse(response:response) {
                                    let error = NSError(domain:"", code:0, userInfo:[NSLocalizedDescriptionKey: message])
                                    completionHandler(APIResult.failure(error))
                                } else {
                                    var attachment = Attachment(dictionary: value as! [String : Any])
                                    attachment.localUrl = fileUrl.path
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
    
    func deleteAttachment(attachmentID: String, completionHandler: @escaping (APIResult<Any>) -> Void) {
        
        self.checkTokenExpiration(){ (complete) in
            if complete {
                
                if let token = self.getToken() {
                    
                    self.restAPIService?.deleteAttachment(token: token, attachmentID: attachmentID) {(result) in
                        
                        switch(result) {
                            
                        case .success(let value):
                            print("deleted attach:", value)
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
    
    func updateAttachment(attachmentID: String, fileUrl: URL, fileData: Data, messageID: Int, encrypt: Bool, completionHandler: @escaping (APIResult<Any>) -> Void) {
        
        let fileName = fileUrl.lastPathComponent
        let mimeType = self.mimeTypeForFileAt(url: fileUrl)
        
        self.checkTokenExpiration(){ (complete) in
            if complete {
                
                if let token = self.getToken() {
                    
                    self.restAPIService?.updateAttachment(token: token, attachmentID: attachmentID, file: fileData, fileName: fileName, mimeType: mimeType, messageID: messageID, encrypted: encrypt) {(result) in
                        
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
    
    //MARK: - Settings
    
    func updateSettings(settingsID: Int, recoveryEmail: String, dispalyName: String, savingContacts: Bool, encryptContacts: Bool, encryptAttachment: Bool, encryptSubject: Bool, completionHandler: @escaping (APIResult<Any>) -> Void) {
        
        self.checkTokenExpiration(){ (complete) in
            if complete {
                
                if let token = self.getToken() {
                    
                    self.restAPIService?.updateSettings(token: token, settingsID: settingsID, recoveryEmail: recoveryEmail, dispalyName: dispalyName, savingContacts: savingContacts, encryptContacts: encryptContacts, encryptAttachment: encryptAttachment, encryptSubject: encryptSubject) {(result) in
                        
                        switch(result) {
                            
                        case .success(let value):
                            //print("updateSettings:", value)
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
    
    //MARK: - Notifications
    
    func createAppToken(deviceToken: String, completionHandler: @escaping (APIResult<Any>) -> Void) {
        
        self.checkTokenExpiration(){ (complete) in
            if complete {
                       
                if let token = self.getToken() {
                           
                    self.restAPIService?.createAppToken(token: token, deviceToken: deviceToken) {(result) in
                               
                        switch(result) {
                                   
                        case .success(let value):
                            //print("createAppToken:", value)
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
                        self.refreshToken(){ (complete) in
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
            } else {
                self.refreshToken(){ (complete) in
                    if complete {
                        completion(true)
                    }
                }
            }
        } else {
            self.refreshToken(){ (complete) in
                if complete {
                    completion(true)
                }
            }
        }
        /*
        self.autologin(){ (complete) in
            if complete {
                completion(true)
            }
        }*/
    }
    
    func isTokenValid() -> Bool{
        if let tokenSavedTime = keychainService?.getTokenSavedTime() {
            if tokenSavedTime.count > 0 {
                if let tokenSavedDate = formatterService?.formatTokenTimeStringToDate(date: tokenSavedTime) {
                    print("tokenSavedDate:", tokenSavedDate)
                    let minutesCount = tokenSavedDate.minutesCountForTokenExpiration()
                    if minutesCount < k_tokenMinutesExpiration {
                        return true
                    }
                }
            }
        }
        return false
    }
    
    func canTokenRefresh() -> Bool {
        if let tokenSavedTime = keychainService?.getTokenSavedTime() {
            if tokenSavedTime.count > 0 {
                if let tokenSavedDate = formatterService?.formatTokenTimeStringToDate(date: tokenSavedTime) {
                    print("tokenSavedDate:", tokenSavedDate)
                    let hoursCount = tokenSavedDate.hoursCountForTokenExpiration()
                    if hoursCount <= k_tokenHoursRefresh {
                        return true
                    }
                }
            }
        }
        return false
    }
    //check message encryption for avoid server bug
    
    func isMessageEncrypted(message: EmailMessage) -> Bool {
        
        if let isEncrypted = message.isEncrypted {
            if isEncrypted {
                return true
            } else {
                
                let content = message.content
                
                if content!.count > k_firstCharsForEncryptdHeader {
                    let index = content!.index(content!.startIndex, offsetBy: k_firstCharsForEncryptdHeader)
                    let header = String(content!.prefix(upTo: index))
                    
                    //print("header:", header)
                    
                    if header == "-----" {
                        return true
                    }
                }
            }
        }
        
        return false
    }
    
    func isSubjectEncrypted(message: EmailMessage) -> Bool {
     
        if let content = message.subject {
                
            if content.count > k_firstCharsForEncryptdHeader {
                let index = content.index(content.startIndex, offsetBy: k_firstCharsForEncryptdHeader)
                let header = String(content.prefix(upTo: index))
                    
                    //print("header:", header)
                    
                    if header == "-----" {
                        return true
                    }
                }
        }    
        
        return false
    }
    
    //MARK: - Parcing
    
    func parseServerResponse(response: Dictionary<String, Any>) -> String? {
        
        var message: String? = nil
        
        for dictionary in response {
            
            switch dictionary.key {
            case APIResponse.token.rawValue :
                if let token = dictionary.value as? String {
                    if token.count > 0 {
                        saveToken(token: token)
                    } else {
                        message = "Token Error"
                    }
                } else {
                    //message = "Token Error"
                    if let twoFactorAuth = response[APIResponse.twoFAEnabled.rawValue] as? Bool {
                        if twoFactorAuth == true {
                            message = APIResponse.twoFAEnabled.rawValue
                        } else {
                            message = "Token Error"
                        }
                    } else {
                        message = "Token Error"
                    }
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
    
    func showErorrLoginAlert(error: NSError) {
        
        authErrorAlertAlreadyShowing = true
        
        if let topViewController = UIApplication.topViewController() {
            
            let params = Parameters(
                title: "Refresh Token".localized(),
                message: error.localizedDescription,
                cancelButton: "Relogin".localized()
            )
            
            AlertHelperKit().showAlertWithHandler(topViewController, parameters: params) { buttonIndex in
                self.hashedPassword = nil
                
                self.keychainService?.deleteUserCredentialsAndToken()
                self.pgpService?.deleteStoredPGPKeys()
                topViewController.navigationController?.popToRootViewController(animated: false)
                topViewController.navigationController?.navigationBar.isHidden = true
                
                self.showLoginViewController()
                self.authErrorAlertAlreadyShowing = false
//                self.logOut()  {(done) in
//                    switch(done) {
//
//                    case .success(let value):
//                        print("value:", value)
//
//                        topViewController.navigationController?.popToRootViewController(animated: false)
//                        topViewController.navigationController?.navigationBar.isHidden = true
//
//                        self.showLoginViewController()
//                        self.authErrorAlertAlreadyShowing = false
//
//                    case .failure(let error):
//                        print("error:", error)
//
//                    }
//                }
            }
        }
    }

    func showLoginViewController() {
        let loginVC = LoginViewController.instantiate(fromAppStoryboard: .Login)
        if let window = UIApplication.shared.getKeyWindow() {
            window.setRootViewController(loginVC)
        }
//        let mainViewController: MainViewController = UIApplication.shared.keyWindow?.rootViewController as! MainViewController
//        
//        let inboxViewController = mainViewController.inboxNavigationController.viewControllers.first as! InboxViewController
//        inboxViewController.inboxSideMenuViewController?.presenter?.interactor?.resetInboxData()
//        
////        self.logOut() { done in
//            mainViewController.inboxNavigationController.dismiss(animated: false, completion: {
//                mainViewController.showLoginViewController()
//            })
////        }       
    }
}
