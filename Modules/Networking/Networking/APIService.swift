//
//  APIService.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 01.10.2018.
//  Copyright © 2018 CTemplar. All rights reserved.
//

import Foundation
import MobileCoreServices
import Utility

public enum APIResult<T> {
    case success(T)
    case failure(Error)
}

public enum APIResponse: String {
    case token            = "token"
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
    case pageConut         = "page_count"
    case results           = "results"
    case error             = "error"
    case expires           = "expires"
}

public class APIService: HashingService {
    // MARK: Properties
    private var restAPIService: RestAPIService
    private var keychainService: KeychainService
    private var pgpService: PGPService
    private var formatterService: FormatterService
    private var hashedPassword: String?
    private var authErrorAlertAlreadyShowing = false

    // MARK: - Constructor
    init(restAPIService: RestAPIService,
         keychainService: KeychainService,
         pgpService: PGPService,
         formatterService: FormatterService) {
        self.restAPIService = restAPIService
        self.keychainService = keychainService
        self.pgpService = pgpService
        self.formatterService = formatterService
    }
    
    // MARK: - Refresh Token
    func refreshToken(completion: @escaping (Bool) -> () ) {
        let storedToken = keychainService.getToken()
        DispatchQueue.global(qos: .userInitiated).async {
            self.restAPIService.refreshToken(token: storedToken) { [weak self] (result) in
                switch(result) {
                case .success(let value):
                    DPrint("refreshToken success value:", value)
                    if let response = value as? Dictionary<String, Any> {
                        if let message = self?.parseServerResponse(response:response) {
                            let error = NSError(domain:"", code:0, userInfo:[NSLocalizedDescriptionKey: message])
                            if self?.authErrorAlertAlreadyShowing == false {
                                self?.showErorrLoginAlert(error: error)
                            }
                            Loader.stop()
                            completion(false)
                        } else {
                            completion(true)
                        }
                    }
                case .failure(let error):
                    DPrint("refreshToken error:", error)
                    let error = NSError(domain:"", code:0, userInfo:[NSLocalizedDescriptionKey: error.localizedDescription])
                    if self?.authErrorAlertAlreadyShowing == false {
                        self?.showErorrLoginAlert(error: error)
                    }
                    completion(false)
                }
            }
        }
    }

    // MARK: - authentication
    public func logOut(completionHandler: @escaping (Bool) -> Void) {
        func clearData() {
            hashedPassword = nil
            keychainService.deleteUserCredentialsAndToken()
            pgpService.deleteStoredPGPKeys()
        }
        checkTokenExpiration { [weak self] (complete) in
            if complete {
                if let token = self?.getToken() {
                    self?.restAPIService.signOut(token: token, completionHandler: { (isSucceeded) in
                        if isSucceeded {
                            clearData()
                            completionHandler(true)
                        } else {
                            completionHandler(false)
                        }
                    })
                } else {
                    clearData()
                    completionHandler(true)
                }
            } else {
                clearData()
                completionHandler(true)
            }
        }
    }
    
    // MARK: - User
    public func userMyself(completionHandler: @escaping (APIResult<Any>) -> Void) {
        
        checkTokenExpiration() { [weak self] (complete) in
            if complete {
                if let token = self?.getToken() {
                    DispatchQueue.global(qos: .background).async {
                        self?.restAPIService.userMyself(token: token) { (result) in
                            DispatchQueue.main.async {
                                switch(result) {
                                case .success(let value):
                                    if let response = value as? Dictionary<String, Any> {
                                        if let message = self?.parseServerResponse(response:response) {
                                            DPrint("userMyself message:", message)
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
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Mail
    public func messagesList(folder: String, messagesIDIn: String,
                      seconds: Int,
                      offset: Int,
                      pageLimit: Int = GeneralConstant.OffsetValue.pageLimit.rawValue,
                      completionHandler: @escaping (APIResult<Any>) -> Void) {
        var folderFilter = ""
        
        if !folder.isEmpty {
            folderFilter = folder == MessagesFoldersName.starred.rawValue ? "&starred=1": "&folder=\(folder)"
        }
        
        let messagesIDInParameter = messagesIDIn.isEmpty == false ? "?id__in=\(messagesIDIn)": ""
       // print("messageList________")
        checkTokenExpiration() { [weak self] (complete) in
            if complete {
                if let token = self?.getToken() {
                    DispatchQueue.global(qos: .background).async {
                        self?.restAPIService.messagesList(token: token, folder: folderFilter, messagesIDIn: messagesIDInParameter, filter: "", seconds: seconds, offset: offset, pageLimit: pageLimit) { (result) in
//                            DispatchQueue.main.async {
                                self?.handleMessageResponse(with: result, completionHandler: completionHandler)
                           // }
                        }
                    }
                }
            }
        }
    }
    
    public func searchMessageList(withQuery searchQuery: String,
                                  offset: Int,
                                  pageLimit: Int = GeneralConstant.OffsetValue.pageLimit.rawValue,
                                  completionHandler: @escaping (APIResult<Any>) -> Void) {
        checkTokenExpiration() { [weak self] (complete) in
            if complete {
                if let token = self?.getToken() {
                    DispatchQueue.global(qos: .background).async {
                        self?.restAPIService.searchMessages(withToken: token, searchQuery: searchQuery, offset: offset, pageLimit: pageLimit, completionHandler: { (result) in
                            DispatchQueue.main.async {
                                self?.handleMessageResponse(with: result, completionHandler: completionHandler)
                            }
                        })
                    }
                }
            }
        }
    }
    
    private func handleMessageResponse(with result: APIResult<Any>, completionHandler: @escaping (APIResult<Any>) -> Void) {
        switch(result) {
        case .success(let value):
            if let response = value as? Dictionary<String, Any> {
                    if let message = self.parseServerResponse(response:response) {
                        DPrint("messagesList message:", message)
                        let error = NSError(domain:"", code:0, userInfo:[NSLocalizedDescriptionKey: message])
                        completionHandler(APIResult.failure(error))
                    } else {
                        //print(response)
                        let emailMessages = EmailMessagesList(dictionary: response)
                        completionHandler(APIResult.success(emailMessages))
                    }
            } else {
                let error = NSError(domain:"", code: URLError.unknown.rawValue, userInfo:[NSLocalizedDescriptionKey: "Response have unknown format"])
                completionHandler(APIResult.failure(error))
            }
            
        case .failure(let error):
            completionHandler(APIResult.failure(error))
        }
    }
    
    public func updateMessages(messageID: String,
                               messagesIDIn: String,
                               folder: String,
                               starred: Bool,
                               read: Bool,
                               updateFolder: Bool,
                               updateStarred: Bool,
                               updateRead: Bool,
                               mailboxId: String? = nil,
                               completionHandler: @escaping (APIResult<Any>) -> Void) {
        
        let messageIDParameter = messageID.isEmpty == false ? "\(messageID)/" : ""
    
        let messagesIDInParameter = messagesIDIn.isEmpty == false ? "?id__in=\(messagesIDIn)" : ""

        checkTokenExpiration() { [weak self] (complete) in
            if complete {
                if let token = self?.getToken() {
                    self?.restAPIService.updateMessages(token: token, messageID: messageIDParameter, messagesIDIn: messagesIDInParameter, folder: folder, starred: starred, read: read, updateFolder: updateFolder, updateStarred: updateStarred, updateRead: updateRead, mailboxId: mailboxId) { (result) in
                        switch(result) {
                        case .success(let value):
                            DPrint("updateMessages success:", value)
                            if let response = value as? Dictionary<String, Any> {
                                if let message = self?.parseServerResponse(response:response) {
                                    DPrint("updateMessages message:", message)
                                    let error = NSError(domain:"", code:0, userInfo:[NSLocalizedDescriptionKey: message])
                                    completionHandler(APIResult.failure(error))
                                } else {
                                    completionHandler(APIResult.success(value))
                                }
                            } else {
                                completionHandler(APIResult.success(value))
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
    
    public func updateSendingMessage(messageID: String, mailboxID: Int, sender: String, encryptedMessage: String, subject: String, recieversList: [[String]], folder: String, send: Bool, encryptionObject: [String: String], encrypted: Bool, subjectEncrypted: Bool, attachments: Array<[String: String]>, selfDestructionDate: String, delayedDeliveryDate: String, deadManDate: String, completionHandler: @escaping (APIResult<Any>) -> Void) {
        
        var setFolder = folder
        var setSend = send
        var deadManTimer: Int = 0
        
        if delayedDeliveryDate.count > 0 {
            setFolder = MessagesFoldersName.outbox.rawValue
            setSend = false
        }
        
        DPrint("deadManDate:", deadManDate)
        DPrint("deadManDate cnt:", deadManDate.count)
        
        if deadManDate.count > 0 {
            setFolder = MessagesFoldersName.outbox.rawValue
            setSend = false
            
            deadManTimer = Int(deadManDate)!
            DPrint("deadManTimer:", deadManTimer)
        }
        
        checkTokenExpiration() { [weak self] (complete) in
            if complete {
                if let token = self?.getToken() {
                    Loader.start()
                    self?.restAPIService.updateSendingMessage(token: token, messageID: messageID, mailboxID: mailboxID, sender: sender, encryptedMessage: encryptedMessage, subject: subject, recieversList: recieversList, folder: setFolder, send: setSend, encryptionObject: encryptionObject, encrypted: encrypted, subjectEncrypted: subjectEncrypted, attachments: attachments, selfDestructionDate: selfDestructionDate, delayedDeliveryDate: delayedDeliveryDate, deadManTimer: deadManTimer) { (result) in
                        
                        switch(result) {
                        case .success(let value):
                            DPrint("updateSendingMessages success:", value)
                            if let response = value as? Dictionary<String, Any> {
                                if let message = self?.parseServerResponse(response:response) {
                                    DPrint("updateSendingMessages message:", message)
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
                    }
                }
            }
        }
    }
    
    public func unreadMessagesCounter(completionHandler: @escaping (APIResult<Any>) -> Void) {
        checkTokenExpiration() { [weak self] (complete) in
            if complete {
                if let token = self?.getToken() {
                    self?.restAPIService.unreadMessagesCounter(token: token) { (result) in
                        switch(result) {
                        case .success(let value):
                            if let response = value as? Dictionary<String, Any> {
                                if let message = self?.parseServerResponse(response:response) {
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
                    }
                }
            }
        }
    }
    
    public func createMessage(parentID: String, lastActionParentId: String?, content: String, subject: String, recieversList: [[String]], folder: String, mailboxID: Int, send: Bool, encrypted: Bool, encryptionObject: [String: String], attachments: Array<[String: String]>, isSubjectEncrypted: Bool, sender: String, isHTML: Bool = false, showHud: Bool = true, lastAction: String?, completionHandler: @escaping (APIResult<Any>) -> Void) {
        
        checkTokenExpiration() { [weak self] (complete) in
            if complete {
                if let token = self?.getToken() {
                    DispatchQueue.main.async {
                        if showHud {
                            Loader.start()
                        }
                    }
                    DispatchQueue.global(qos: .background).async {
                        self?.restAPIService.createMessage(token: token, parentID: parentID, content: content, subject: subject, lastActionParentId: lastActionParentId, recieversList: recieversList, folder: folder, mailboxID: mailboxID, send: send, encrypted: encrypted, encryptionObject: encryptionObject, attachments: attachments, isSubjectEncrypted: isSubjectEncrypted, sender: sender, lastAction: lastAction) { (result) in
                            DispatchQueue.main.async {
                                switch(result) {
                                case .success(let value):
                                    if let response = value as? Dictionary<String, Any> {
                                        if let message = self?.parseServerResponse(response:response) {
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
                            }
                        }
                    }
                }
            }
        }
    }
    
    public func deleteMessages(messagesIDIn: String, completionHandler: @escaping (APIResult<Any>) -> Void) {
        let messagesIDInParameter = messagesIDIn.isEmpty == false ? "?id__in=\(messagesIDIn)" : ""
        checkTokenExpiration() { [weak self] (complete) in
            if complete {
                if let token = self?.getToken() {
                    self?.restAPIService.deleteMessages(token: token, messagesIDIn: messagesIDInParameter) { (result) in
                        switch(result) {
                        case .success(let value):
                            DPrint("deleteMessages success:", value)
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
    
    public func deleteMessage(messagesID: String, completionHandler: @escaping (APIResult<Any>) -> Void) {
        checkTokenExpiration() { [weak self] (complete) in
            if complete {
                if let token = self?.getToken() {
                    self?.restAPIService.deleteMessage(token: token, messagesID: messagesID) { (result) in
                        switch(result) {
                        case .success(let value):
                            DPrint("deleteMessage success:", value)
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
    
    public func saveDraftMesssage(messageID: String, messageContent: String, subject: String, recieversList: [[String]], folder: String, encryptionObject: [String: String], encrypted: Bool, selfDestructionDate: String, delayedDeliveryDate: String, deadManDate: String, mailbox: String?, completionHandler: @escaping (APIResult<Any>) -> Void) {
        
        var deadManTimer = 0
        
        if deadManDate.count > 0 {
            deadManTimer = Int(deadManDate)!
        }
        
        checkTokenExpiration() { [weak self] (complete) in
            if complete {
                if let token = self?.getToken() {
                    self?.restAPIService.saveDraftMesssage(token: token, messageID: messageID, messageContent: messageContent, subject: subject, recieversList: recieversList, folder: folder, encryptionObject: encryptionObject, encrypted: encrypted, selfDestructionDate: selfDestructionDate, delayedDeliveryDate: delayedDeliveryDate, deadManTimer: deadManTimer, mailbox: mailbox) { (result) in
                        
                        switch(result) {
                        case .success(let value):
                            DPrint("saveDraftMesssage success:", value)
                            if let response = value as? Dictionary<String, Any> {
                                if let message = self?.parseServerResponse(response:response) {
                                    DPrint("saveDraftMesssage message:", message)
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
                    }
                }
            }
        }
    }
    
    // MARK: - Mailbox
    public func mailboxesList(completionHandler: @escaping (APIResult<Any>) -> Void) {
        checkTokenExpiration() { [weak self] (complete) in
            if complete {
                if let token = self?.getToken() {
                    self?.restAPIService.mailboxesList(token: token) { (result) in
                        switch(result) {
                        case .success(let value):
                            if let response = value as? Dictionary<String, Any> {
                                if let message = self?.parseServerResponse(response:response) {
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
                    }
                }
            }
        }
    }
    
    
    // MARK: - Filter List
    public func filterList(completionHandler: @escaping (APIResult<Any>) -> Void) {
        checkTokenExpiration() { [weak self] (complete) in
            if complete {
                if let token = self?.getToken() {
                    self?.restAPIService.filterList(token: token) { (result) in
                        switch(result) {
                        case .success(let value):
                            if let response = value as? Dictionary<String, Any> {
                                if let message = self?.parseServerResponse(response:response) {
                                    let error = NSError(domain:"", code:0, userInfo:[NSLocalizedDescriptionKey: message])
                                    completionHandler(APIResult.failure(error))
                                } else {
                                    if  let filterList = Filter.filterList(array: response["results"] as? Array<Any> ?? []) as? [Filter] {
                                        completionHandler(APIResult.success(filterList))
                                    }
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
    
    // MARK: - Mailbox
    public func keysList(completionHandler: @escaping (APIResult<Any>) -> Void) {
        checkTokenExpiration() { [weak self] (complete) in
            if complete {
                if let token = self?.getToken() {
                    self?.restAPIService.keysList(token: token) { (result) in
                        switch(result) {
                        case .success(let value):
                            if let response = value as? Dictionary<String, Any> {
                                if let message = self?.parseServerResponse(response:response) {
                                    let error = NSError(domain:"", code:0, userInfo:[NSLocalizedDescriptionKey: message])
                                    completionHandler(APIResult.failure(error))
                                } else {
                                    let mailboxes = Mailboxes(dictionary: response, true)
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
                    }
                }
            }
        }
    }
    
    
    public func addFilter(model: Filter ,completionHandler: @escaping (APIResult<Any>) -> Void) {
        checkTokenExpiration() { [weak self] (complete) in
            if complete {
                if let token = self?.getToken() {
                    self?.restAPIService.addFilter(filter: model, token: token) { (result) in
                        switch(result) {
                        case .success(let value):
                            if let response = value as? Dictionary<String, Any> {
                                if let message = self?.parseServerResponse(response:response) {
                                    let error = NSError(domain:"", code:0, userInfo:[NSLocalizedDescriptionKey: message])
                                    completionHandler(APIResult.failure(error))
                                } else {
                                    let filter = Filter(dictionary: response)
                                    completionHandler(APIResult.success(filter))
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
    
    public func editFilter(model: Filter ,completionHandler: @escaping (APIResult<Any>) -> Void) {
        checkTokenExpiration() { [weak self] (complete) in
            if complete {
                if let token = self?.getToken() {
                    self?.restAPIService.editFilter(filter: model, token: token) { (result) in
                        switch(result) {
                        case .success(let value):
                            if let response = value as? Dictionary<String, Any> {
                                if let message = self?.parseServerResponse(response:response) {
                                    let error = NSError(domain:"", code:0, userInfo:[NSLocalizedDescriptionKey: message])
                                    completionHandler(APIResult.failure(error))
                                } else {
                                    let filter = Filter(dictionary: response)
                                    completionHandler(APIResult.success(filter))
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
    
    public func deleteFilter(filterId: String ,completionHandler: @escaping (APIResult<Any>) -> Void) {
        checkTokenExpiration() { [weak self] (complete) in
            if complete {
                if let token = self?.getToken() {
                    self?.restAPIService.deleteFilter(filterId: filterId, token: token) { (result) in
                        switch(result) {
                        case .success(_):
                            completionHandler(APIResult.success(""))
                            
                        case .failure(let error):
                            let error = NSError(domain:"", code:0, userInfo:[NSLocalizedDescriptionKey: error.localizedDescription])
                            completionHandler(APIResult.failure(error))
                        }
                    }
                }
            }
        }
    }
    
    
    public func createNewKey(model: NewKeyModel ,completionHandler: @escaping (APIResult<Any>) -> Void) {
        checkTokenExpiration() { [weak self] (complete) in
            if complete {
                if let token = self?.getToken() {
                    self?.restAPIService.addNewKey(token: token, model: model) { (result) in
                        switch(result) {
                        case .success(let value):
                            if let response = value as? Dictionary<String, Any> {
                                if let message = self?.parseServerResponse(response:response) {
                                    let error = NSError(domain:"", code:0, userInfo:[NSLocalizedDescriptionKey: message])
                                    completionHandler(APIResult.failure(error))
                                } else {
                                    let mailbox = Mailbox(dictionary: response, true)
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
    
    
    public func setKeyAsPrimary(id:Int , mailboxId: Int, completionHandler: @escaping (APIResult<Any>) -> Void) {
        checkTokenExpiration() { [weak self] (complete) in
            if complete {
                if let token = self?.getToken() {
                    self?.restAPIService.setKeyAsPrimary(token: token,id: id, mailboxId: mailboxId) { (result) in
                        switch(result) {
                        case .success(let value):
                            if let response = value as? Dictionary<String, Any> {
                                if let message = self?.parseServerResponse(response:response) {
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
                    }
                }
            }
        }
    }
    
    
    public func deleteKey(id:Int, password: String,completionHandler: @escaping (APIResult<Any>) -> Void) {
        checkTokenExpiration() { [weak self] (complete) in
            if complete {
                if let token = self?.getToken() {
                    self?.restAPIService.deleteKey(token: token,id: id, password:password) { (result) in
                        switch(result) {
                        case .success(_):
                            completionHandler(APIResult.success(""))
                             
                        case .failure(let error):
                            let error = NSError(domain:"", code:0, userInfo:[NSLocalizedDescriptionKey: error.localizedDescription])
                            completionHandler(APIResult.failure(error))
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Subscription Plan Purchasing
    public func subscribePlan(model: PurchaseModel ,completionHandler: @escaping (APIResult<Any>) -> Void) {
        checkTokenExpiration() { [weak self] (complete) in
            if complete {
                if let token = self?.getToken() {
                    self?.restAPIService.purchasePlan(token: token, model: model, completionHandler: { (result) in
                        switch(result) {
                        case .success(let value):
                            if let response = value as? [String : Any]{
                                if let status = response["status"] as? Bool{
                                    if status{
                                        completionHandler(APIResult.success(status))
                                    }else{
                                        let error = NSError(domain:"", code:0, userInfo:[NSLocalizedDescriptionKey: "Purchase is failed"])
                                        completionHandler(APIResult.failure(error))
                                    }
                                }else{
                                    let error = NSError(domain:"", code:0, userInfo:[NSLocalizedDescriptionKey: "Purchase is failed"])
                                    completionHandler(APIResult.failure(error))
                                }
                            }else{
                                let error = NSError(domain:"", code:0, userInfo:[NSLocalizedDescriptionKey: "Responce have unknown format"])
                                completionHandler(APIResult.failure(error))
                            }
                        case .failure(let error):
                            let error = NSError(domain:"", code:0, userInfo:[NSLocalizedDescriptionKey: error.localizedDescription])
                            completionHandler(APIResult.failure(error))
                        }
                    })
                }
            }
        }
    }
    
    
    // MARK: - Mailbox Alias
    public func createAlias(model: AliasModel ,completionHandler: @escaping (APIResult<Any>) -> Void) {
        checkTokenExpiration() { [weak self] (complete) in
            if complete {
                if let token = self?.getToken() {
                    self?.restAPIService.addAlias(token: token, model: model) { (result) in
                        switch(result) {
                        case .success(let value):
                            if let response = value as? Dictionary<String, Any> {
                                if let message = self?.parseServerResponse(response:response) {
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

    public func updateMailbox(mailboxID: String, userSignature: String, displayName: String, isDefault: Bool, completionHandler: @escaping (APIResult<Any>) -> Void) {
        checkTokenExpiration() { [weak self] (complete) in
            if complete {
                if let token = self?.getToken() {
                    self?.restAPIService.updateMailbox(token: token, mailboxID: mailboxID, userSignature: userSignature, displayName: displayName, isDefault: isDefault) { (result) in
                        switch(result) {
                        case .success(let value):
                            DPrint("updateMailbox success:", value)
                            if let response = value as? Dictionary<String, Any> {
                                if let message = self?.parseServerResponse(response:response) {
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
    
    public func updateMailboxStatus(mailboxID: String, isEnable: Bool, completionHandler: @escaping (APIResult<Any>) -> Void) {
        checkTokenExpiration() { [weak self] (complete) in
            if complete {
                if let token = self?.getToken() {
                    self?.restAPIService.updateMailboxStatus(token: token, mailboxID: mailboxID, isEnable: isEnable) { (result) in
                        switch(result) {
                        case .success(let value):
                            DPrint("updateMailbox success:", value)
                            if let response = value as? Dictionary<String, Any> {
                                if let message = self?.parseServerResponse(response:response) {
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
    
    public func defaultMailbox(mailboxes: Array<Mailbox>) -> Mailbox {
        return mailboxes.first(where: { $0.isDefault == true }) ?? mailboxes.first!
    }
    
    public func publicKeyList(completionHandler: @escaping (APIResult<Any>) -> Void) {
        checkTokenExpiration() { [weak self] (complete) in
            if complete {
                if let token = self?.getToken() {
                    self?.restAPIService.publicKeyList(token: token) { (result) in
                        switch(result) {
                        case .success(let value):
                            DPrint("publicKeyList success:", value)
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
    
    public func publicKeyFor(userEmailsArray: Array<String>, completionHandler: @escaping (APIResult<Any>) -> Void) {
        checkTokenExpiration() { [weak self] (complete) in
            if complete {
                if let token = self?.getToken() {
                    self?.restAPIService.publicKeyFor(userEmails: userEmailsArray, token: token) { (result) in
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
    
    // MARK: - Folders
    public func customFoldersList(limit: Int, offset: Int, completionHandler: @escaping (APIResult<Any>) -> Void) {
        checkTokenExpiration() { [weak self] (complete) in
            if complete {
                if let token = self?.getToken() {
                    self?.restAPIService.customFoldersList(token: token, limit: limit, offset: offset) { (result) in
                        switch(result) {
                        case .success(let value):
                            if let response = value as? Dictionary<String, Any> {
                                if let message = self?.parseServerResponse(response:response) {
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
                    }
                }
            }
        }
    }
    
    public func createCustomFolder(name: String, color: String, completionHandler: @escaping (APIResult<Any>) -> Void) {
        checkTokenExpiration() { [weak self] (complete) in
            if complete {
                if let token = self?.getToken() {
                    self?.restAPIService.createCustomFolder(token: token, name: name, color: color) { (result) in
                        switch(result) {
                        case .success(let value):
                            DPrint("createCustomFolder success:", value)
                            if let response = value as? Dictionary<String, Any> {
                                if let message = self?.parseServerResponse(response:response) {
                                    let error = NSError(domain:"", code:0, userInfo:[NSLocalizedDescriptionKey: message])
                                    completionHandler(APIResult.failure(error))
                                } else {
                                    let newFolder = Folder(dictionary: response)
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
                    }
                }
            }
        }
    }
    
    public func updateCustomFolder(folderID: String, name: String, color: String, completionHandler: @escaping (APIResult<Any>) -> Void) {
        checkTokenExpiration() { [weak self] (complete) in
            if complete {
                if let token = self?.getToken() {
                    self?.restAPIService.updateCustomFolder(token: token, folderID: folderID, name: name, color: color) { (result) in
                        switch(result) {
                        case .success(let value):
                            DPrint("updateCustomFolder success:", value)
                             if let response = value as? Dictionary<String, Any> {
                                if let message = self?.parseServerResponse(response:response) {
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
                    }
                }
            }
        }
    }
    
    public func deleteCustomFolder(folderID: String, completionHandler: @escaping (APIResult<Any>) -> Void) {
        checkTokenExpiration() { [weak self] (complete) in
            if complete {
                if let token = self?.getToken() {
                    self?.restAPIService.deleteCustomFolder(token: token, folderID: folderID) { (result) in
                        switch(result) {
                        case .success(let value):
                            DPrint("deleteCustomFolder success:", value)
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
    
    // MARK: - Contacts
    public func userContacts(fetchAll: Bool, offset: Int, silent: Bool, completionHandler: @escaping (APIResult<Any>) -> Void) {
        checkTokenExpiration() { [weak self] (complete) in
            if complete {
                if let token = self?.getToken() {
                    DispatchQueue.main.async {
                        if !silent {
                            Loader.start()
                        }
                    }
                    DispatchQueue.global(qos: .background).async {
                        self?.restAPIService.userContacts(token: token, fetchAll: fetchAll, offset: offset) { (result) in
                                switch(result) {
                                case .success(let value):
                                    if let response = value as? Dictionary<String, Any> {
                                        if let message = self?.parseServerResponse(response:response) {
                                            let error = NSError(domain:"", code:0, userInfo:[NSLocalizedDescriptionKey: message])
                                            completionHandler(APIResult.failure(error))
                                        } else {
                                            DispatchQueue.global(qos: .background).async {
                                                let contactsList = ContactsList(dictionary: response, pgpService: self?.pgpService)
                                                completionHandler(APIResult.success(contactsList))
                                            }
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
                                    DispatchQueue.main.async {
                                        Loader.stop()
                                    }
                                }
                        }
                    }
                }
            }
        }
    }
    
    
    
    // MARK: - Contacts
    public func userContactsForComposeMail(fetchAll: Bool, offset: Int, silent: Bool, completionHandler: @escaping (APIResult<Any>) -> Void) {
        checkTokenExpiration() { [weak self] (complete) in
            if complete {
                if let token = self?.getToken() {
                    DispatchQueue.main.async {
                        if !silent {
                            Loader.start()
                        }
                    }
                    DispatchQueue.global(qos: .background).async {
                        self?.restAPIService.userContacts(token: token, fetchAll: fetchAll, offset: offset) { (result) in
                                switch(result) {
                                case .success(let value):
                                    if let response = value as? Dictionary<String, Any> {
                                        if let message = self?.parseServerResponse(response:response) {
                                            let error = NSError(domain:"", code:0, userInfo:[NSLocalizedDescriptionKey: message])
                                            completionHandler(APIResult.failure(error))
                                        } else {
                                            DispatchQueue.global(qos: .background).async {
                                                let contactsList = ContactsList(dictionary: response)
                                                completionHandler(APIResult.success(contactsList))
                                            }
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
                                    DispatchQueue.main.async {
                                        Loader.stop()
                                    }
                                }
                        }
                    }
                }
            }
        }
    }
    
    
    public func createContact(name: String, email: String, phone: String, address: String, note: String, completionHandler: @escaping (APIResult<Any>) -> Void) {
        checkTokenExpiration() { [weak self] (complete) in
            if complete {
                if let token = self?.getToken() {
                    self?.restAPIService.createContact(token: token, name: name, email: email, phone: phone, address: address, note: note) { (result) in
                        switch(result) {
                        case .success(let value):
                            if let response = value as? Dictionary<String, Any> {
                                if let message = self?.parseServerResponse(response:response) {
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
    
    public func updateContact(contactID: String, name: String, email: String, phone: String, address: String, note: String, completionHandler: @escaping (APIResult<Any>) -> Void) {
        checkTokenExpiration() { [weak self] (complete) in
            if complete {
                if let token = self?.getToken() {
                    self?.restAPIService.updateContact(token: token, contactID: contactID, name: name, email: email, phone: phone, address: address, note: note) { (result) in
                        switch(result) {
                        case .success(let value):
                            DPrint("updateContact success:", value)
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
    
    public func deleteContacts(contactsIDIn: String, completionHandler: @escaping (APIResult<Any>) -> Void) {
        let contactsIDInParameter = contactsIDIn.isEmpty == false ? "?id__in=\(contactsIDIn)" : ""

        checkTokenExpiration() { [weak self] (complete) in
            if complete {
                if let token = self?.getToken() {
                    self?.restAPIService.deleteContacts(token: token, contactsIDIn: contactsIDInParameter) { (result) in
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
    
    @objc
    public func encryptedContactHash(contactEmail: String, contactAsStringDictionary: String, completion:@escaping (String) -> () ) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100), execute: {
            let salt = self.formatterService.generateSaltFrom(userName: contactEmail)
            DPrint("salt:", salt)
            let encryptedContactHash = self.formatterService.hash(password: contactAsStringDictionary, salt: salt)
            DPrint("encryptContactHash:", encryptedContactHash as Any)
            completion(encryptedContactHash)
        })
    }
    
    public func serializeContactToJson(name: String, email: String, phone: String, address: String, note: String) -> String {
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
                DPrint("JSON string = \n\(jsonStringEncoded)")
                jsonString = jsonStringEncoded
            }
        }
        
        return jsonString
    }
    
    public func createEncryptedContact(name: String, email: String, phone: String, address: String, note: String, completionHandler: @escaping (APIResult<Any>) -> Void) {
        let jsonString = self.serializeContactToJson(name: name, email: email, phone: phone, address: address, note: note)
        
        if jsonString.count == 0 {
            let error = NSError(domain:"", code:0, userInfo:[NSLocalizedDescriptionKey: "JSON encoding error"])
            completionHandler(APIResult.failure(error))
            return
        }
        
        checkTokenExpiration() { [weak self] (complete) in
            if complete {
                if let token = self?.getToken() {
                    if let encryptedContact = self?.pgpService.encryptContact(contactAsJson: jsonString) {
                        self?.restAPIService.createEncryptedContact(token: token, encryptedContact: encryptedContact, encryptedContactHash: "") { (result) in
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
    }
    
    public func updateEncryptedContact(contactID: String, name: String, email: String, phone: String, address: String, note: String, completionHandler: @escaping (APIResult<Any>) -> Void) {
        let jsonString = self.serializeContactToJson(name: name, email: email, phone: phone, address: address, note: note)
        
        if !jsonString.isEmpty {
            let error = NSError(domain:"", code:0, userInfo:[NSLocalizedDescriptionKey: "JSON encoding error"])
            completionHandler(APIResult.failure(error))
            return
        }
        
        checkTokenExpiration() { [weak self] (complete) in
            if complete {
                if let token = self?.getToken() {
                    if let encryptedContact = self?.pgpService.encryptContact(contactAsJson: jsonString) {
                        self?.restAPIService.updateEncryptedContact(token: token, contactID: contactID, encryptedContact: encryptedContact, encryptedContactHash: "") { (result) in
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
    }
    
    // MARK: - White/Black lists
    public func addContactToBlackList(name: String, email: String, completionHandler: @escaping (APIResult<Any>) -> Void) {
        checkTokenExpiration() { [weak self] (complete) in
            if complete {
                if let token = self?.getToken() {
                    self?.restAPIService.addContactToBlackList(token: token, name: name, email: email) { (result) in
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
    
    public func deleteContactFromBlackList(contactID: String, completionHandler: @escaping (APIResult<Any>) -> Void) {
        checkTokenExpiration() { [weak self] (complete) in
            if complete {
                if let token = self?.getToken() {
                    self?.restAPIService.deleteContactFromBlackList(token: token, contactID: contactID) { (result) in
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
    
    public func addContactToWhiteList(name: String, email: String, completionHandler: @escaping (APIResult<Any>) -> Void) {
        checkTokenExpiration() { [weak self] (complete) in
            if complete {
                if let token = self?.getToken() {
                    self?.restAPIService.addContactToWhiteList(token: token, name: name, email: email) { (result) in
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
    
    public func deleteContactFromWhiteList(contactID: String, completionHandler: @escaping (APIResult<Any>) -> Void) {
        checkTokenExpiration() { [weak self] (complete) in
            if complete {
                if let token = self?.getToken() {
                    self?.restAPIService.deleteContactFromWhiteList(token: token, contactID: contactID) { (result) in
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
    
    public func whiteListContacts(completionHandler: @escaping (APIResult<Any>) -> Void) {
        checkTokenExpiration() { [weak self] (complete) in
            if complete {
                if let token = self?.getToken() {
                    self?.restAPIService.whiteListContacts(token: token) { (result) in
                        switch(result) {
                        case .success(let value):
                            if let response = value as? Dictionary<String, Any> {
                                if let message = self?.parseServerResponse(response:response) {
                                    let error = NSError(domain:"", code:0, userInfo:[NSLocalizedDescriptionKey: message])
                                    completionHandler(APIResult.failure(error))
                                } else {
                                    let contactsList = ContactsList(dictionary: response, pgpService: self?.pgpService)
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
    
    public func blackListContacts(completionHandler: @escaping (APIResult<Any>) -> Void) {
        checkTokenExpiration() { [weak self] (complete) in
            if complete {
                if let token = self?.getToken() {
                    self?.restAPIService.blackListContacts(token: token) { (result) in
                        switch(result) {
                        case .success(let value):
                            if let response = value as? Dictionary<String, Any> {
                                if let message = self?.parseServerResponse(response:response) {
                                    let error = NSError(domain:"", code:0, userInfo:[NSLocalizedDescriptionKey: message])
                                    completionHandler(APIResult.failure(error))
                                } else {
                                    let contactsList = ContactsList(dictionary: response, pgpService: self?.pgpService)
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
    
    // MARK: - Download
    public func loadAttachFile(url: String, completionHandler: @escaping (APIResult<Any>) -> Void) {
        restAPIService.loadAttachFile(url: url) { (result) in
            switch(result) {
            case .success(let value):
                completionHandler(APIResult.success(value))
            case .failure(let error):
                let error = NSError(domain:"", code:0, userInfo:[NSLocalizedDescriptionKey: error.localizedDescription])
                completionHandler(APIResult.failure(error))
            }
        }
    }
    
    // MARK: - Attachments
    public func createAttachment(fileUrl: URL, messageID: String, completionHandler: @escaping (APIResult<Any>) -> Void) {
        
        guard let fileData = try? Data(contentsOf: fileUrl) else {
            fatalError("File URL not found")
        }

        let fileName = fileUrl.lastPathComponent
        let mimeType = mimeTypeForFileAt(url: fileUrl)
        
        checkTokenExpiration() { [weak self] (complete) in
            if complete {
                if let token = self?.getToken() {
                    self?.restAPIService.createAttachment(token: token, file: fileData, fileName: fileName, mimeType: mimeType, messageID: messageID, encrypted: false) { (result) in
                        switch(result) {
                        case .success(let value):
                            
                            if let response = value as? Dictionary<String, Any> {
                                if let message = self?.parseServerResponse(response:response) {
                                    let error = NSError(domain:"", code:0, userInfo:[NSLocalizedDescriptionKey: message])
                                    completionHandler(APIResult.failure(error))
                                } else {
                                    var attachment = Attachment(dictionary: value as! [String: Any])
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
    
    public func deleteAttachment(attachmentID: String, completionHandler: @escaping (APIResult<Any>) -> Void) {
        checkTokenExpiration() { [weak self] (complete) in
            if complete {
                if let token = self?.getToken() {
                    self?.restAPIService.deleteAttachment(token: token, attachmentID: attachmentID) { (result) in
                        switch(result) {
                        case .success(let value):
                            DPrint("deleted attach:", value)
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
    
    public func updateAttachment(attachmentID: String, fileUrl: URL, fileName: String, fileData: Data, messageID: Int, encrypt: Bool, completionHandler: @escaping (APIResult<Any>) -> Void) {
       // let fileName = fileUrl.lastPathComponent
        if let pathExtension = fileUrl.pathExtension as? String , pathExtension == "--" {
            print(pathExtension)
        }
        let mimeType = self.mimeTypeForFileAt(url: fileUrl)
        
        checkTokenExpiration() { [weak self] (complete) in
            if complete {
                if let token = self?.getToken() {
                    self?.restAPIService.updateAttachment(token: token, attachmentID: attachmentID, file: fileData, fileName: fileName, mimeType: mimeType, messageID: messageID, encrypted: encrypt) { (result) in
                        switch(result) {
                        case .success(let value):
                            if let response = value as? Dictionary<String, Any> {
                                if let message = self?.parseServerResponse(response:response) {
                                    let error = NSError(domain:"", code:0, userInfo:[NSLocalizedDescriptionKey: message])
                                    completionHandler(APIResult.failure(error))
                                } else {
                                    let attachment = Attachment(dictionary: value as! [String: Any])
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
    
    public func mimeTypeForFileAt(url: URL) -> String {
        let pathExtension = url.pathExtension
        if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension as NSString, nil)?.takeRetainedValue() {
            if let mimetype = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue() {
                return mimetype as String
            }
        }
        return pathExtension.mimeType()
    }
    
    // MARK: - Settings
    public func updateSettings(settingsID: Int,
                               recoveryEmail: String,
                               dispalyName: String,
                               savingContacts: Bool,
                               encryptContacts: Bool,
                               encryptAttachment: Bool,
                               encryptSubject: Bool,
                               blockExternalImages: Bool,
                               htmlDisabled: Bool,
                               completionHandler: @escaping (APIResult<Any>) -> Void) {
        checkTokenExpiration() { [weak self] (complete) in
            if complete {
                if let token = self?.getToken() {
                    self?.restAPIService.updateSettings(token: token,
                                                        settingsID: settingsID,
                                                        recoveryEmail: recoveryEmail,
                                                        dispalyName: dispalyName,
                                                        savingContacts: savingContacts,
                                                        encryptContacts: encryptContacts,
                                                        encryptAttachment: encryptAttachment,
                                                        encryptSubject: encryptSubject,
                                                        blockExternalImages: blockExternalImages,
                                                        htmlDisabled: htmlDisabled)
                    { (result) in
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
    
    // MARK: - Notifications
    public func createAppToken(deviceToken: String, completionHandler: @escaping (APIResult<Any>) -> Void) {
        checkTokenExpiration() { [weak self] (complete) in
            if complete {
                if let token = self?.getToken() {
                    self?.restAPIService.createAppToken(token: token, deviceToken: deviceToken) { (result) in
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
    
    // MARK: - Local services
    public func saveToken(token: String) {
        keychainService.saveToken(token: token)
    }
    
    public func getToken() -> String? {
        let token = keychainService.getToken()
        if !token.isEmpty {
            return token
        } else {
            showLoginViewController()
            return nil
        }
    }
    
    public func checkTokenExpiration(completion:@escaping (Bool) -> () ) {
        let tokenSavedTime = keychainService.getTokenSavedTime()
        if !tokenSavedTime.isEmpty {
            if let tokenSavedDate = formatterService.formatTokenTimeStringToDate(date: tokenSavedTime) {
                DPrint("tokenSavedDate:", tokenSavedDate)
                let minutesCount = tokenSavedDate.minutesCountForTokenExpiration()
                if minutesCount > TokenConstant.tokenMinutesExpiration.rawValue {
                    self.refreshToken() { (complete) in
                        if complete {
                            completion(true)
                            return
                        }
                    }
                } else {
                    DPrint("token is valid")
                    completion(true)
                    return
                }
            }
        } else {
            refreshToken() { (complete) in
                if complete {
                    completion(true)
                }
            }
        }
    }
    
    public func isTokenValid() -> Bool {
        let tokenSavedTime = keychainService.getTokenSavedTime()
        if !tokenSavedTime.isEmpty {
            if let tokenSavedDate = formatterService.formatTokenTimeStringToDate(date: tokenSavedTime) {
                DPrint("tokenSavedDate:", tokenSavedDate)
                let minutesCount = tokenSavedDate.minutesCountForTokenExpiration()
                if minutesCount < TokenConstant.tokenMinutesExpiration.rawValue {
                    return true
                }
            }
        }
        
        return false
    }
    
    public func canTokenRefresh() -> Bool {
        let tokenSavedTime = keychainService.getTokenSavedTime()
        if !tokenSavedTime.isEmpty {
            if let tokenSavedDate = formatterService.formatTokenTimeStringToDate(date: tokenSavedTime) {
                DPrint("tokenSavedDate:", tokenSavedDate)
                let hoursCount = tokenSavedDate.hoursCountForTokenExpiration()
                if hoursCount <= TokenConstant.tokenHoursRefresh.rawValue {
                    return true
                }
            }
        }
        return false
    }
    
    // check message encryption for avoid server bug
    public func isMessageEncrypted(message: EmailMessage) -> Bool {
        if let isEncrypted = message.isEncrypted {
            if isEncrypted {
                return true
            } else {
                guard let content = message.content else {
                    return false
                }
                
                if content.count > firstCharsForEncryptdHeader {
                    let index = content.index(content.startIndex, offsetBy: firstCharsForEncryptdHeader)
                    let header = String(content.prefix(upTo: index))
                    if header == "-----" {
                        return true
                    }
                }
            }
        }
        
        return false
    }
    
    public func isSubjectEncrypted(message: EmailMessage) -> Bool {
        if let content = message.subject {
            if content.count > firstCharsForEncryptdHeader {
                let index = content.index(content.startIndex, offsetBy: firstCharsForEncryptdHeader)
                let header = String(content.prefix(upTo: index))
                if header == "-----" {
                    return true
                }
            }
        }
        return false
    }
    
    // MARK: - Parsing
    public func parseServerResponse(response: Dictionary<String, Any>) -> String? {
        var message: String?
        for dictionary in response {
            switch dictionary.key {
            case APIResponse.token.rawValue:
                if let token = dictionary.value as? String {
                    if token.count > 0 {
                        saveToken(token: token)
                    } else {
                        message = "Token Error"
                    }
                } else {
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
            case APIResponse.errorDetail.rawValue:
                DPrint("errorDetail APIResponce key:", dictionary.key, "value:", dictionary.value)
                message = extractErrorTextFrom(value: dictionary.value)
                if let value = dictionary.value as? String { //temp
                    if value == APIResponse.tokenExpiredValue.rawValue || value == APIResponse.noCredentials.rawValue {
                        //self.autologinWhenTokenExpired()
                    }
                }
            case APIResponse.tokenExpiredValue.rawValue: break
                //self.autologinWhenTokenExpired()
            case APIResponse.usernameError.rawValue:
                if let errorMessage = extractErrorTextFrom(value: dictionary.value) {
                    message = "Username field.\n" + errorMessage
                }
            case APIResponse.passwordError.rawValue:
                if let errorMessage = extractErrorTextFrom(value: dictionary.value) {
                    message = "Password field.\n" + errorMessage
                }
            case APIResponse.nonFieldError.rawValue:
                message = extractErrorTextFrom(value: dictionary.value)
            
                if let texts = dictionary.value as? Array<Any> { // when checking Token verification catch if Token expired
                    if let value = texts.first as? String {
                        DPrint("value: ", value)
                        if value == APIResponse.tokenExpiredValue.rawValue || value == APIResponse.noCredentials.rawValue {
                            //self.autologinWhenTokenExpired()
                        }
                    }
                }
            case APIResponse.userExists.rawValue:
                if let userExists = dictionary.value as? Int {
                    if userExists == 1 {
                        message = "This name already exists!"
                    }
                } else {
                    message = "Unknown Error"
                }
            case APIResponse.pageConut.rawValue, APIResponse.results.rawValue: break
                // do nothing
            case APIResponse.expires.rawValue:
                DPrint("expires APIResponce key:", dictionary.key, "value:", dictionary.value)
                message = extractErrorTextFrom(value: dictionary.value)
                break
            default:
                DPrint("Default case APIResponce key:", dictionary.key, "value:", dictionary.value)
            }
        }
        
        if (message ?? "").isSignatureDecodingError() {
            self.logoutUser()
        }
        return message
    }
    
    public func extractErrorTextFrom(value: Any) -> String? {
        if let texts = value as? [Any] {
            for text in texts {
                var string: String = ""
                if let oneString = text as? String {
                    string = string + " " + oneString
                    DPrint("extracted string:", string)
                }
                return string
            }
        } else {
            return value as? String
        }
        return ""
    }
    
    public func checkAppVersion(onCompletion: @escaping ((String, Bool) -> Void)) {
        restAPIService.checkAppVersion(onCompletion: { (version, isForceUpdate) in
            onCompletion(version, isForceUpdate)
        })
    }
}
// MARK: - Application Logic
extension APIService: NetworkErrorHandler {
    private func showErorrLoginAlert(error: NSError) {
        authErrorAlertAlreadyShowing = true
        showErorrLoginAlert(error: error as Error, shouldPop: true) { [weak self] (isSucceeded) in
            if isSucceeded {
                self?.hashedPassword = nil
                self?.keychainService.deleteUserCredentialsAndToken()
                self?.pgpService.deleteStoredPGPKeys()
                self?.showLoginViewController()
                self?.authErrorAlertAlreadyShowing = false
            }
        }
    }
    
    private func logoutUser() {
        keychainService.deleteUserCredentialsAndToken()
        pgpService.deleteStoredPGPKeys()
        showLoginViewController()
    }
}
