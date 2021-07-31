//
//  RestAPIService.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 01.10.2018.
//  Copyright © 2018 CTemplar. All rights reserved.
//

import Foundation
import Alamofire
import Utility

public class RestAPIService {
    // MARK: - Refresh Token
    func refreshToken(token: String, completionHandler: @escaping (APIResult<Any>) -> Void) {
        let headers: HTTPHeaders = [
            "Accept": "application/json"
        ]
        
        let parameters: Parameters = [
            JSONKey.token.rawValue: token
        ]
        
        let url = EndPoint.baseUrl.rawValue + EndPoint.refreshToken.rawValue
        
        DPrint("verifyToken parameters:", parameters)
        DPrint("refreshToken url:", url)
        
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers) .responseJSON { (response: AFDataResponse<Any>) in
            DPrint("refreshToken responce:", response)
            switch(response.result) {
            case .success(let value):
                completionHandler(APIResult.success(value))
            case .failure(let error):
                completionHandler(APIResult.failure(error))
            }
        }
    }
    
    // MARK: - Authentication
    func signOut(token: String,
                 completionHandler: @escaping (Bool) -> Void) {
        let headers: HTTPHeaders = [
            "Authorization": "JWT " + token,
            "Accept": "application/json"
        ]
        
        let url = "\(EndPoint.baseUrl.rawValue)\(EndPoint.signOut.rawValue)"
        AF.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
            if let statusCode = response.response?.statusCode,
                !(200..<300 ~= statusCode) {
                completionHandler(false)
            } else {
                completionHandler(true)
            }
        }
    }
    
    // MARK: - User
    func userMyself(token: String, completionHandler: @escaping (APIResult<Any>) -> Void) {
        let headers: HTTPHeaders = [
            "Authorization": "JWT " + token,
            "Accept": "application/json"
        ]
        
        let url = EndPoint.baseUrl.rawValue + EndPoint.userMyself.rawValue
        
        DPrint("userMyself url:", url)
        
        AF.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers) /*.validate()*/ .responseJSON { (response: AFDataResponse<Any>) in
            DPrint("userMyself responce:", response)
            switch(response.result) {
            case .success(let value):
                completionHandler(APIResult.success(value))
            case .failure(let error):
                completionHandler(APIResult.failure(error))
            }
        }
    }
    
    // MARK: - Mail
    func messagesList(token: String,
                             folder: String,
                             messagesIDIn: String,
                             filter: String,
                             seconds: Int,
                             offset: Int,
                             pageLimit: Int = GeneralConstant.OffsetValue.pageLimit.rawValue,
                             completionHandler: @escaping (APIResult<Any>) -> Void) {
        
        let headers: HTTPHeaders = [
            "Authorization": "JWT " + token,
            "Accept": "application/json"
        ]
        
        let timeParameter = seconds > 0 ? "&seconds=\(seconds.description)" : ""

        let limitParams = offset > -1 ? String(format: "?limit=%d&offset=%d", pageLimit, offset) : ""

        var url = EndPoint.baseUrl.rawValue + EndPoint.messages.rawValue + limitParams + folder + messagesIDIn + timeParameter + filter
        url = url.replacingOccurrences(of: " ", with: "%20")
        DPrint("messagesList url:", url)
        
        AF.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers) /*.validate()*/ .responseJSON { (response: AFDataResponse<Any>) in
            DPrint("messagesList responce:", response)
            switch(response.result) {
            case .success(let value):
                completionHandler(APIResult.success(value))
            case .failure(let error):
                completionHandler(APIResult.failure(error))
            }
        }
    }
    
    func searchMessages(withToken token: String,
                        searchQuery: String,
                        offset: Int,
                        pageLimit: Int = GeneralConstant.OffsetValue.pageLimit.rawValue,
                        completionHandler: @escaping (APIResult<Any>) -> Void) {
        let headers: HTTPHeaders = [
            "Authorization": "JWT " + token,
            "Accept": "application/json"
        ]
        
        let limitParams = offset > -1 ? "?q=\(searchQuery)&limit=\(pageLimit)&offset=\(offset)" : ""
        
        var url = "\(EndPoint.baseUrl.rawValue)\(EndPoint.searchMessages.rawValue)\(limitParams)"
        
        url = url.replacingOccurrences(of: " ", with: "%20")
        
        DPrint("messagesList url:", url)
        
        AF.request(url, method: .get, parameters: nil,
                   encoding: JSONEncoding.default,
                   headers: headers).responseJSON { (response: AFDataResponse<Any>) in
            DPrint("messagesList responce:", response)
            switch(response.result) {
            case .success(let value):
                completionHandler(APIResult.success(value))
            case .failure(let error):
                completionHandler(APIResult.failure(error))
            }
        }
    }
    
    func updateMessages(token: String, messageID: String, messagesIDIn: String, folder: String, starred: Bool, read: Bool, updateFolder: Bool, updateStarred: Bool, updateRead: Bool, mailboxId: String?, completionHandler: @escaping (APIResult<Any>) -> Void) {
        
        let headers: HTTPHeaders = [
            "Authorization": "JWT " + token,
            "Accept": "application/json"
        ]

        let configureParameters : NSMutableDictionary = [:]
        
        if updateFolder {
            configureParameters[JSONKey.folder.rawValue] = folder
        }
        
        if updateStarred {
            configureParameters[JSONKey.starred.rawValue] = starred
        }
        
        if updateRead {
            configureParameters[JSONKey.read.rawValue] = read
        }
        
        if let mailboxId = mailboxId {
            configureParameters[JSONKey.mailbox.rawValue] = mailboxId
        }
        
        let parameters: Parameters = configureParameters as! Parameters
        
        let url = EndPoint.baseUrl.rawValue + EndPoint.messages.rawValue + messageID + messagesIDIn
        
        DPrint("updateMessages parameters:", parameters)
        DPrint("updateMessages url:", url)
        
        AF.request(url, method: .patch, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .responseJSON { (response: AFDataResponse<Any>) in
            DPrint("updateMessages responce:", response)
            switch(response.result) {
            case .success(let value):
                completionHandler(APIResult.success(value))
            case .failure(let error):
                completionHandler(APIResult.failure(error))
            }
        }
    }
    
    func unreadMessagesCounter(token: String, completionHandler: @escaping (APIResult<Any>) -> Void) {
        
        let headers: HTTPHeaders = [
            "Authorization": "JWT " + token,
            "Accept": "application/json"
        ]
        
        let url = EndPoint.baseUrl.rawValue + EndPoint.unreadCounter.rawValue
        
        DPrint("unreadMessagesCounter url:", url)
        
        AF.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers) /*.validate()*/ .responseJSON { (response: AFDataResponse<Any>) in
            switch(response.result) {
            case .success(let value):
                completionHandler(APIResult.success(value))
            case .failure(let error):
                completionHandler(APIResult.failure(error))
            }
        }
    }
    
    func createMessage(token: String, parentID: String, content: String, subject: String, lastActionParentId: String?, recieversList: [[String]], folder: String, mailboxID: Int, send: Bool, encrypted: Bool, encryptionObject: [String : String], attachments: Array<[String: String]>, isSubjectEncrypted: Bool, sender: String, isHTML: Bool = false, lastAction: String?, completionHandler: @escaping (APIResult<Any>) -> Void) {
    
        let headers: HTTPHeaders = [
            "Authorization": "JWT " + token,
            "Accept": "application/json"
        ]
        
        var parameters: Parameters = [
            JSONKey.content.rawValue: content,
            JSONKey.subject.rawValue: subject,
            JSONKey.receiver.rawValue: recieversList[0],
            JSONKey.folder.rawValue: folder,
            JSONKey.mailbox.rawValue: mailboxID,
            JSONKey.send.rawValue: send,
            JSONKey.encrypted.rawValue: encrypted,
            JSONKey.encryption.rawValue: encryptionObject,
            JSONKey.attachments.rawValue: attachments,
            JSONKey.parent.rawValue: parentID,
            JSONKey.isHTML.rawValue: isHTML,
            JSONKey.subjectEncrypted.rawValue: isSubjectEncrypted,
            JSONKey.sender.rawValue: sender
        ]
        
        if recieversList[1].count > 0 {
            parameters[JSONKey.carbonCopy.rawValue] = recieversList[1]
        }
        
        if recieversList[2].count > 0 {
            parameters[JSONKey.blindCarbonCopy.rawValue] = recieversList[2]
        }
        
        if attachments.count > 0 {
            parameters[JSONKey.forwardAttachmentsMessage.rawValue] = parentID
        }
        
        if let lastActionParentId = lastActionParentId {
            parameters[JSONKey.lastActionParentId.rawValue] = lastActionParentId
        }
        
        if let lastAction = lastAction {
            parameters[JSONKey.lastAction.rawValue] = lastAction
        }
        
        let url = EndPoint.baseUrl.rawValue + EndPoint.messages.rawValue
        
        DPrint("createMessage url:", url)
        DPrint("createMessage parameters:", parameters)
        
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers) .responseJSON { (response: AFDataResponse<Any>) in
            DPrint("createMessage responce:", response)
            switch(response.result) {
            case .success(let value):
                completionHandler(APIResult.success(value))
            case .failure(let error):
                completionHandler(APIResult.failure(error))
            }
        }
    }
    
    func updateSendingMessage(token: String, messageID: String, mailboxID: Int, sender: String, encryptedMessage: String, subject: String, recieversList: [[String]], folder: String, send: Bool, encryptionObject: [String : String], encrypted: Bool, subjectEncrypted: Bool, attachments: Array<[String : String]>, selfDestructionDate: String, delayedDeliveryDate: String, deadManTimer: Int, completionHandler: @escaping (APIResult<Any>) -> Void) {
        
        let headers: HTTPHeaders = [
            "Authorization": "JWT " + token,
            "Accept": "application/json"
        ]
        
        var parameters: Parameters = [
            JSONKey.content.rawValue: encryptedMessage,
            JSONKey.folder.rawValue: folder,
            JSONKey.mailbox.rawValue: mailboxID,
            JSONKey.sender.rawValue: sender,
            JSONKey.subject.rawValue: subject,
            JSONKey.receiver.rawValue: recieversList[0],
            JSONKey.send.rawValue: send,
            JSONKey.encryption.rawValue: encryptionObject,
            JSONKey.encrypted.rawValue: encrypted,
            JSONKey.subjectEncrypted.rawValue: subjectEncrypted,
            JSONKey.attachments.rawValue: attachments,
        ]
        
        if selfDestructionDate.count > 0 {
            parameters[JSONKey.selfDestructionDate.rawValue] = selfDestructionDate
        }
        
        if delayedDeliveryDate.count > 0 {
            parameters[JSONKey.delayedDeliveryDate.rawValue] = delayedDeliveryDate
        }
        
        if deadManTimer > 0 {
            parameters[JSONKey.deadManDate.rawValue] = deadManTimer
        }
        
        if recieversList[1].count > 0 {
            parameters[JSONKey.carbonCopy.rawValue] = recieversList[1]
        }
        
        if recieversList[2].count > 0 {
            parameters[JSONKey.blindCarbonCopy.rawValue] = recieversList[2]
        }
        
        let url = EndPoint.baseUrl.rawValue + EndPoint.messages.rawValue + messageID + "/"
        
        DPrint("updateSendingMessage parameters:", parameters)
        DPrint("updateSendingMessage url:", url)
        
        AF.request(url, method: .patch, parameters: parameters, encoding: JSONEncoding.default, headers: headers) .responseJSON { (response: AFDataResponse<Any>) in
            DPrint("updateSendingMessage responce:", response)
            switch(response.result) {
            case .success(let value):
                completionHandler(APIResult.success(value))
            case .failure(let error):
                completionHandler(APIResult.failure(error))
            }
        }
    }
    
    func saveDraftMesssage(token: String, messageID: String, messageContent: String, subject: String, recieversList: [[String]], folder: String, encryptionObject: [String: String], encrypted: Bool, selfDestructionDate: String, delayedDeliveryDate: String, deadManTimer: Int, mailbox: String?, completionHandler: @escaping (APIResult<Any>) -> Void) {
        
        let headers: HTTPHeaders = [
            "Authorization": "JWT " + token,
            "Accept": "application/json"
        ]
        
        var parameters: Parameters = [
            JSONKey.content.rawValue : messageContent,
            JSONKey.folder.rawValue: folder,
            JSONKey.subject.rawValue: subject,
            JSONKey.receiver.rawValue: recieversList[0],
            JSONKey.send.rawValue: false,
            JSONKey.encryption.rawValue : encryptionObject,
            JSONKey.encrypted.rawValue : encrypted
        ]
        
        if selfDestructionDate.count > 0 {
            parameters[JSONKey.selfDestructionDate.rawValue] = selfDestructionDate
        }
        
        if delayedDeliveryDate.count > 0 {
            parameters[JSONKey.delayedDeliveryDate.rawValue] = delayedDeliveryDate
        }
        
        if deadManTimer > 0 {
            parameters[JSONKey.deadManDate.rawValue] = deadManTimer
        }
        
        if recieversList[1].count > 0 {
            parameters[JSONKey.carbonCopy.rawValue] = recieversList[1]
        }
        
        if recieversList[2].count > 0 {
            parameters[JSONKey.blindCarbonCopy.rawValue] = recieversList[2]
        }
        
        if let mailbox = mailbox {
            parameters[JSONKey.mailbox.rawValue] = mailbox
        }
        
        let url = EndPoint.baseUrl.rawValue + EndPoint.messages.rawValue + messageID + "/"
        
        DPrint("saveDraftMesssage parameters:", parameters)
        DPrint("saveDraftMesssage url:", url)
        
        AF.request(url, method: .patch, parameters: parameters, encoding: JSONEncoding.default, headers: headers) .responseJSON { (response: AFDataResponse<Any>) in
            DPrint("saveDraftMesssage responce:", response)
            switch(response.result) {
            case .success(let value):
                completionHandler(APIResult.success(value))
            case .failure(let error):
                completionHandler(APIResult.failure(error))
            }
        }
    }
    
    func deleteMessages(token: String, messagesIDIn: String, completionHandler: @escaping (APIResult<Any>) -> Void) {
        
        let headers: HTTPHeaders = [
            "Authorization": "JWT " + token,
            "Accept": "application/json"
        ]
        
        let url = EndPoint.baseUrl.rawValue + EndPoint.messages.rawValue + messagesIDIn
        
        DPrint("deleteMessages url:", url)
        
        AF.request(url, method: .delete, parameters: nil, encoding: JSONEncoding.default, headers: headers) .responseJSON { (response: AFDataResponse<Any>) in
            DPrint("deleteMessages responce:", response)
            switch(response.result) {
            case .success(let value):
                completionHandler(APIResult.success(value))
            case .failure(let error):
                completionHandler(APIResult.failure(error))
            }
        }
    }
    
    func deleteMessage(token: String, messagesID: String, completionHandler: @escaping (APIResult<Any>) -> Void) {
        
        let headers: HTTPHeaders = [
            "Authorization": "JWT " + token,
            "Accept": "application/json"
        ]
        
        let url = EndPoint.baseUrl.rawValue + EndPoint.messages.rawValue + messagesID
        
        DPrint("deleteMessage url:", url)
        
        AF.request(url, method: .delete, parameters: nil, encoding: JSONEncoding.default, headers: headers) .responseJSON { (response: AFDataResponse<Any>) in
            DPrint("deleteMessage responce:", response)
            switch(response.result) {
            case .success(let value):
                completionHandler(APIResult.success(value))
            case .failure(let error):
                completionHandler(APIResult.failure(error))
            }
        }
    }
    
    // MARK: - Mailbox
    func mailboxesList(token: String, completionHandler: @escaping (APIResult<Any>) -> Void) {
        
        let headers: HTTPHeaders = [
            "Authorization": "JWT " + token,
            "Accept": "application/json"
        ]
        
        let url = EndPoint.baseUrl.rawValue + EndPoint.mailboxes.rawValue
        
        DPrint("mailboxes url:", url)
        
        AF.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers) /*.validate()*/ .responseJSON { (response: AFDataResponse<Any>) in
            DPrint("mailboxes responce:", response)
            switch(response.result) {
            case .success(let value):
                completionHandler(APIResult.success(value))
            case .failure(let error):
                completionHandler(APIResult.failure(error))
            }
        }
    }
    
    
    // MARK: - Keys
    func keysList(token: String, completionHandler: @escaping (APIResult<Any>) -> Void) {
        
        let headers: HTTPHeaders = [
            "Authorization": "JWT " + token,
            "Accept": "application/json"
        ]
        
        let url = EndPoint.baseUrl.rawValue + EndPoint.mailboxKeys.rawValue
        
        DPrint("mailboxes url:", url)
        
        AF.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers) /*.validate()*/ .responseJSON { (response: AFDataResponse<Any>) in
            DPrint("mailboxes responce:", response)
            switch(response.result) {
            case .success(let value):
                completionHandler(APIResult.success(value))
            case .failure(let error):
                completionHandler(APIResult.failure(error))
            }
        }
    }
    // MARK: - Subscriptions
    public func purchasePlan(token: String, model: PurchaseModel, completionHandler: @escaping (APIResult<Any>) -> Void) {
        
        let headers: HTTPHeaders = [
            "Authorization": "JWT " + token,
            "Accept": "application/json"
        ]
        
        let parameters: Parameters = [
            JSONKey.customer_identifier.rawValue : model.customer_identifier!,
            JSONKey.payment_identifier.rawValue: model.payment_identifier!,
            JSONKey.payment_method.rawValue: model.payment_method!,
            JSONKey.plan_type.rawValue: model.plan_type!,
            "payment_type": model.payment_type!
        ]
        
        let url = EndPoint.baseUrl.rawValue + EndPoint.subscribePlan.rawValue
        
        DPrint("subscription url:", url)
        
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers) /*.validate()*/ .responseJSON { (response: AFDataResponse<Any>) in
            DPrint("subscription responce:", response)
            switch(response.result) {
            case .success(let value):
                completionHandler(APIResult.success(value))
            case .failure(let error):
                completionHandler(APIResult.failure(error))
            }
        }
    }
    
    // MARK: - Mailbox
    func addAlias(token: String, model: AliasModel, completionHandler: @escaping (APIResult<Any>) -> Void) {
        
        let headers: HTTPHeaders = [
            "Authorization": "JWT " + token,
            "Accept": "application/json"
        ]
        
        let parameters: Parameters = [
            JSONKey.email.rawValue : model.email!,
            JSONKey.privateKey.rawValue: model.privateKey!,
            JSONKey.publicKey.rawValue: model.publicKey!,
            JSONKey.fingerprint.rawValue: model.fingerprint!
        ]
        
        let url = EndPoint.baseUrl.rawValue + EndPoint.mailboxes.rawValue
        
        DPrint("mailboxes url:", url)
        
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers) /*.validate()*/ .responseJSON { (response: AFDataResponse<Any>) in
            DPrint("mailboxes responce:", response)
            switch(response.result) {
            case .success(let value):
                completionHandler(APIResult.success(value))
            case .failure(let error):
                completionHandler(APIResult.failure(error))
            }
        }
    }
    
    
    func addNewKey(token: String, model: NewKeyModel, completionHandler: @escaping (APIResult<Any>) -> Void) {
        
        let headers: HTTPHeaders = [
            "Authorization": "JWT " + token,
            "Accept": "application/json"
        ]
        
        let parameters: Parameters = [
            JSONKey.password.rawValue : model.password!,
            JSONKey.privateKey.rawValue: model.privateKey!,
            JSONKey.publicKey.rawValue: model.publicKey!,
            JSONKey.fingerprint.rawValue: model.fingerprint!,
            JSONKey.keyType.rawValue: model.keyType!,
            JSONKey.mailbox.rawValue: model.mailboxID!
        ]
        
        let url = EndPoint.baseUrl.rawValue + EndPoint.mailboxKeys.rawValue
        
        DPrint("mailboxes url:", url, parameters)
        
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers) /*.validate()*/ .responseJSON { (response: AFDataResponse<Any>) in
            DPrint("mailboxes responce:", response)
            switch(response.result) {
            case .success(let value):
                completionHandler(APIResult.success(value))
            case .failure(let error):
                completionHandler(APIResult.failure(error))
            }
        }
    }
    
    
    func setKeyAsPrimary(token: String, id: Int, mailboxId: Int, completionHandler: @escaping (APIResult<Any>) -> Void) {
        
        let headers: HTTPHeaders = [
            "Authorization": "JWT " + token,
            "Accept": "application/json"
        ]
        
        let parameters: Parameters = [
            JSONKey.idKey.rawValue : id,
            JSONKey.mailBox_Id.rawValue: mailboxId
        ]
        
        let url = EndPoint.baseUrl.rawValue + EndPoint.setPrimaryKey.rawValue
        
        DPrint("mailboxes url:", url, parameters)
        
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers) /*.validate()*/ .responseJSON { (response: AFDataResponse<Any>) in
            DPrint("mailboxes responce:", response)
            switch(response.result) {
            case .success(let value):
                completionHandler(APIResult.success(value))
            case .failure(let error):
                completionHandler(APIResult.failure(error))
            }
        }
    }
    
    func deleteKey(token: String, id: Int, password: String,completionHandler: @escaping (APIResult<Any>) -> Void) {
        
        let headers: HTTPHeaders = [
            "Authorization": "JWT " + token,
            "Accept": "application/json"
        ]
        
        let parameters: Parameters = [
            JSONKey.password.rawValue : password
        ]
        let url = EndPoint.baseUrl.rawValue + EndPoint.mailboxKeys.rawValue + String(id) + "/"
        
        DPrint("mailboxes url:", url)
        
        AF.request(url, method: .delete, parameters: parameters, encoding: JSONEncoding.default, headers: headers) /*.validate()*/ .responseJSON { (response: AFDataResponse<Any>) in
            DPrint("mailboxes responce:", response)
            switch(response.result) {
            case .success(let value):
                completionHandler(APIResult.success(value))
            case .failure(let error):
                completionHandler(APIResult.failure(error))
            }
        }
    }
    
    
    func updateMailbox(token: String, mailboxID: String, userSignature: String, displayName: String, isDefault: Bool, completionHandler: @escaping (APIResult<Any>) -> Void) {
        
        let headers: HTTPHeaders = [
            "Authorization": "JWT " + token,
            "Accept": "application/json"
        ]
        
        var parameters: Parameters = [
            JSONKey.isDefault.rawValue : isDefault
        ]
        
        if userSignature.count > 0 {
            parameters[JSONKey.userSignature.rawValue] = userSignature
        }
     
        if displayName.count > 0 {
            parameters[JSONKey.displayName.rawValue] = displayName
        }
        
        let url = EndPoint.baseUrl.rawValue + EndPoint.mailboxes.rawValue + mailboxID + "/"
        
        DPrint("updateMailbox parameters:", parameters)
        DPrint("updateMailbox url:", url)
        
        AF.request(url, method: .patch, parameters: parameters, encoding: JSONEncoding.default, headers: headers) .responseJSON { (response: AFDataResponse<Any>) in
//
            DPrint("updateMailbox responce:", response)
//
            switch(response.result) {
            case .success(let value):
                completionHandler(APIResult.success(value))
            case .failure(let error):
                completionHandler(APIResult.failure(error))
            }
        }
    }
    
    
    func updateMailboxStatus(token: String, mailboxID: String, isEnable: Bool, completionHandler: @escaping (APIResult<Any>) -> Void) {
        
        let headers: HTTPHeaders = [
            "Authorization": "JWT " + token,
            "Accept": "application/json"
        ]
        
        let parameters: Parameters = [
            JSONKey.isEnable.rawValue : isEnable
        ]
        
        let url = EndPoint.baseUrl.rawValue + EndPoint.mailboxes.rawValue + mailboxID + "/"
        
        DPrint("updateMailbox parameters:", parameters)
        DPrint("updateMailbox url:", url)
        
        AF.request(url, method: .patch, parameters: parameters, encoding: JSONEncoding.default, headers: headers) .responseJSON { (response: AFDataResponse<Any>) in
//
            DPrint("updateMailbox responce:", response)
//
            switch(response.result) {
            case .success(let value):
                completionHandler(APIResult.success(value))
            case .failure(let error):
                completionHandler(APIResult.failure(error))
            }
        }
    }
    
    func publicKeyList(token: String, completionHandler: @escaping (APIResult<Any>) -> Void) {
        
        let headers: HTTPHeaders = [
            "Authorization": "JWT " + token,
            "Accept": "application/json"
        ]

        let url = EndPoint.baseUrl.rawValue + EndPoint.publicKeys.rawValue
        
        DPrint("publicKeyList url:", url)
        
        AF.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers) .responseJSON { (response: AFDataResponse<Any>) in
            DPrint("publicKeyList responce:", response)
            switch(response.result) {
            case .success(let value):
                completionHandler(APIResult.success(value))
            case .failure(let error):
                completionHandler(APIResult.failure(error))
            }
        }
    }
    
    func publicKeyFor(userEmails: Array<String>, token: String, completionHandler: @escaping (APIResult<Any>) -> Void) {
        
        let headers: HTTPHeaders = [
            "Authorization": "JWT " + token,
            "Accept": "application/json"
        ]
        
        let parameters: Parameters = [
            JSONKey.emails.rawValue: userEmails
        ]
        
        DPrint("publicKeyFor parameters:", parameters)
        
        let url = EndPoint.baseUrl.rawValue + EndPoint.publicKeys.rawValue + "/"//+ "?email__in=" + userEmail
        
        DPrint("publicKeyFor url:", url)
        
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers) .responseJSON { (response: AFDataResponse<Any>) in
            DPrint("publicKeyFor responce:", response)
            switch(response.result) {
            case .success(let value):
                completionHandler(APIResult.success(value))
            case .failure(let error):
                completionHandler(APIResult.failure(error))
            }
        }
    }
    
    // MARK: - Keys
    func filterList(token: String, completionHandler: @escaping (APIResult<Any>) -> Void) {
        
        let headers: HTTPHeaders = [
            "Authorization": "JWT " + token,
            "Accept": "application/json"
        ]
        
        let url = EndPoint.baseUrl.rawValue + EndPoint.filterList.rawValue
        
        DPrint("filterList url:", url)
        
        AF.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers) /*.validate()*/ .responseJSON { (response: AFDataResponse<Any>) in
            DPrint("FilterList responce:", response)
            switch(response.result) {
            case .success(let value):
                completionHandler(APIResult.success(value))
            case .failure(let error):
                completionHandler(APIResult.failure(error))
            }
        }
    }
    
    
    
    
    // MARK: - Keys
    func addFilter(filter: Filter ,token: String, completionHandler: @escaping (APIResult<Any>) -> Void) {
        
        let headers: HTTPHeaders = [
            "Authorization": "JWT " + token,
            "Accept": "application/json"
        ]
        let parameters: Parameters = [
            JSONKeysForFilter.name.rawValue: filter.name ?? "",
           
            JSONKeysForFilter.conditions.rawValue:[[                JSONKeysForFilter.condition.rawValue: filter.condition ?? "",
                JSONKeysForFilter.filterText.rawValue: filter.filter_text ?? "",
                JSONKeysForFilter.parameter.rawValue: filter.parameter ?? ""
            ]],
            JSONKeysForFilter.folder.rawValue: filter.folder ?? "",
            JSONKeysForFilter.moveTo.rawValue: filter.move_to ?? true,
            JSONKeysForFilter.read.rawValue: filter.mark_as_read ?? true,
            JSONKeysForFilter.starred.rawValue: filter.mark_as_starred ?? true
        ]
        /*
         "conditions": [{
                 "parameter": "subject",
                 "condition": "contains",
                 "filter_text": "New"
             }]
         */
        let url = EndPoint.baseUrl.rawValue + EndPoint.filterList.rawValue
        
        DPrint("filterList url:", url, parameters)
        
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers) /*.validate()*/ .responseJSON { (response: AFDataResponse<Any>) in
            DPrint("FilterList responce:", response)
            switch(response.result) {
            case .success(let value):
                completionHandler(APIResult.success(value))
            case .failure(let error):
                completionHandler(APIResult.failure(error))
            }
        }
    }
    
    // MARK: - Keys
    func deleteFilter(filterId: String ,token: String, completionHandler: @escaping (APIResult<Any>) -> Void) {
        
        let headers: HTTPHeaders = [
            "Authorization": "JWT " + token,
            "Accept": "application/json"
        ]
        let url = EndPoint.baseUrl.rawValue + EndPoint.filterList.rawValue + filterId + "/"
        
        DPrint("filterList url:", url)
        
        AF.request(url, method: .delete, parameters: nil, encoding: JSONEncoding.default, headers: headers) /*.validate()*/ .responseJSON { (response: AFDataResponse<Any>) in
            DPrint("FilterList responce:", response)
            switch(response.result) {
            case .success(let value):
                completionHandler(APIResult.success(value))
            case .failure(let error):
                completionHandler(APIResult.failure(error))
            }
        }
    }
    
    
    // MARK: - Keys
    func editFilter(filter: Filter ,token: String, completionHandler: @escaping (APIResult<Any>) -> Void) {
        
        let headers: HTTPHeaders = [
            "Authorization": "JWT " + token,
            "Accept": "application/json"
        ]
        let parameters: Parameters = [
            JSONKeysForFilter.id.rawValue: filter.id ?? 0,
            JSONKeysForFilter.name.rawValue: filter.name ?? "",
            JSONKeysForFilter.conditions.rawValue:[[                JSONKeysForFilter.condition.rawValue: filter.condition ?? "",
                JSONKeysForFilter.filterText.rawValue: filter.filter_text ?? "",
                JSONKeysForFilter.parameter.rawValue: filter.parameter ?? ""
            ]],
            JSONKeysForFilter.folder.rawValue: filter.folder ?? "",
            JSONKeysForFilter.moveTo.rawValue: filter.move_to ?? false,
            JSONKeysForFilter.read.rawValue: filter.mark_as_read ?? false,
            JSONKeysForFilter.starred.rawValue: filter.mark_as_starred ?? false
        ]
        let url = EndPoint.baseUrl.rawValue + EndPoint.filterList.rawValue + String((filter.id ?? 0)) + "/"
        
        DPrint("filterList url:", url, parameters)
        
        AF.request(url, method: .patch, parameters: parameters, encoding: JSONEncoding.default, headers: headers) /*.validate()*/ .responseJSON { (response: AFDataResponse<Any>) in
            DPrint("FilterList responce:", response)
            switch(response.result) {
            case .success(let value):
                completionHandler(APIResult.success(value))
            case .failure(let error):
                completionHandler(APIResult.failure(error))
            }
        }
    }
    
    // MARK: - Folders
    
    func customFoldersList(token: String, limit: Int, offset: Int, completionHandler: @escaping (APIResult<Any>) -> Void) {
        
        let headers: HTTPHeaders = [
            "Authorization": "JWT " + token,
            "Accept": "application/json"
        ]
        
        let parameters: Parameters = [
            JSONKey.limit.rawValue: limit,
            JSONKey.offset.rawValue: offset
        ]
        
        DPrint("customFolders parameters:", parameters)
        
        let url = EndPoint.baseUrl.rawValue + EndPoint.customFolders.rawValue
        
        DPrint("customFolders url:", url)
        
        AF.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers) /*.validate()*/ .responseJSON { (response: AFDataResponse<Any>) in
            DPrint("customFolders responce:", response)
            switch(response.result) {
            case .success(let value):
                completionHandler(APIResult.success(value))
            case .failure(let error):
                completionHandler(APIResult.failure(error))
            }
        }
    }
    
    func createCustomFolder(token: String, name: String, color: String, completionHandler: @escaping (APIResult<Any>) -> Void) {
        
        let headers: HTTPHeaders = [
            "Authorization": "JWT " + token,
            "Accept": "application/json"
        ]
        
        let parameters: Parameters = [
            JSONKey.folderName.rawValue: name,
            JSONKey.folderColor.rawValue: color
        ]
        
        DPrint("createCustomFolder parameters:", parameters)
        
        let url = EndPoint.baseUrl.rawValue + EndPoint.customFolders.rawValue
        
        DPrint("createCustomFolder url:", url)
        
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .responseJSON { (response: AFDataResponse<Any>) in
            DPrint("createCustomFolder responce:", response)
            switch(response.result) {
            case .success(let value):
                completionHandler(APIResult.success(value))
            case .failure(let error):
                completionHandler(APIResult.failure(error))
            }
        }
    }
    
    func updateCustomFolder(token: String, folderID: String,  name: String, color: String, completionHandler: @escaping (APIResult<Any>) -> Void) {
        
        let headers: HTTPHeaders = [
            "Authorization": "JWT " + token,
            "Accept": "application/json"
        ]
        
        let parameters: Parameters = [
            JSONKey.folderName.rawValue: name,
            JSONKey.folderColor.rawValue: color
        ]
        
        let url = EndPoint.baseUrl.rawValue + EndPoint.customFolders.rawValue + folderID + "/"
        
        DPrint("updateCustomFolder url:", url)
        
        AF.request(url, method: .patch, parameters: parameters, encoding: JSONEncoding.default, headers: headers) .responseJSON { (response: AFDataResponse<Any>) in
            DPrint("updateCustomFolder responce:", response)
            switch(response.result) {
            case .success(let value):
                completionHandler(APIResult.success(value))
            case .failure(let error):
                completionHandler(APIResult.failure(error))
            }
        }
    }
    
    func deleteCustomFolder(token: String, folderID: String, completionHandler: @escaping (APIResult<Any>) -> Void) {
        
        let headers: HTTPHeaders = [
            "Authorization": "JWT " + token,
            "Accept": "application/json"
        ]
        
        let url = EndPoint.baseUrl.rawValue + EndPoint.customFolders.rawValue + folderID + "/"
        
        DPrint("deleteCustomFolder url:", url)
        
        AF.request(url, method: .delete, parameters: nil, encoding: JSONEncoding.default, headers: headers) .responseJSON { (response: AFDataResponse<Any>) in
            DPrint("deleteCustomFolder responce:", response)
            switch(response.result) {
            case .success(let value):
                completionHandler(APIResult.success(value))
            case .failure(let error):
                completionHandler(APIResult.failure(error))
            }
        }
    }
    
    // MARK: - Contacts
    
    func userContacts(token: String, fetchAll: Bool, offset: Int, completionHandler: @escaping (APIResult<Any>) -> Void) {
        
        let headers: HTTPHeaders = [
            "Authorization": "JWT " + token,
            "Accept": "application/json"
        ]
        
        var params = ""
        
        if !fetchAll {
            params = String(format: "?limit=%d&offset=%d&q=",
                            GeneralConstant.OffsetValue.contactPageLimit.rawValue,
                            offset)
        }
        
        let url = EndPoint.baseUrl.rawValue + EndPoint.contact.rawValue + params
        
        DPrint("userContacts url:", url)
        
        AF.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers) .responseJSON { (response: AFDataResponse<Any>) in
            DPrint("userContacts responce:", response)
            switch(response.result) {
            case .success(let value):
                completionHandler(APIResult.success(value))
            case .failure(let error):
                completionHandler(APIResult.failure(error))
            }
        }
    }
    
    func createContact(token: String, name: String, email: String, phone: String, address: String, note: String, completionHandler: @escaping (APIResult<Any>) -> Void) {
        
        let headers: HTTPHeaders = [
            "Authorization": "JWT " + token,
            "Accept": "application/json"
        ]
        
        let parameters: Parameters = [
            JSONKey.folderName.rawValue: name,
            JSONKey.email.rawValue: email,
            JSONKey.phone.rawValue: phone,
            JSONKey.address.rawValue: address,
            JSONKey.note.rawValue: note
        ]
        
        DPrint("createContact parameters:", parameters)
        
        let url = EndPoint.baseUrl.rawValue + EndPoint.contact.rawValue
        
        DPrint("createContact url:", url)
        
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers) .responseJSON { (response: AFDataResponse<Any>) in
            DPrint("createContact responce:", response)
            switch(response.result) {
            case .success(let value):
                completionHandler(APIResult.success(value))
            case .failure(let error):
                completionHandler(APIResult.failure(error))
            }
        }
    }
    
    func updateContact(token: String, contactID: String, name: String, email: String, phone: String, address: String, note: String, completionHandler: @escaping (APIResult<Any>) -> Void) {
        
        let headers: HTTPHeaders = [
            "Authorization": "JWT " + token,
            "Accept": "application/json"
        ]
        
        let parameters: Parameters = [
            JSONKey.folderName.rawValue: name,
            JSONKey.email.rawValue: email,
            JSONKey.phone.rawValue: phone,
            JSONKey.address.rawValue: address,
            JSONKey.note.rawValue: note,
            JSONKey.encrypted.rawValue: false
        ]
        
        DPrint("updateContact parameters:", parameters)
        
        let url = EndPoint.baseUrl.rawValue + EndPoint.contact.rawValue + contactID + "/"
        
        DPrint("updateContact url:", url)
        
        AF.request(url, method: .patch, parameters: parameters, encoding: JSONEncoding.default, headers: headers) .responseJSON { (response: AFDataResponse<Any>) in
            DPrint("updateContact responce:", response)
            switch(response.result) {
            case .success(let value):
                completionHandler(APIResult.success(value))
            case .failure(let error):
                completionHandler(APIResult.failure(error))
            }
        }
    }
    
    func deleteContacts(token: String, contactsIDIn: String, completionHandler: @escaping (APIResult<Any>) -> Void) {
        
        let headers: HTTPHeaders = [
            "Authorization": "JWT " + token,
            "Accept": "application/json"
        ]
        
        let url = EndPoint.baseUrl.rawValue + EndPoint.contact.rawValue + contactsIDIn
        
        DPrint("deleteContact url:", url)
        
        AF.request(url, method: .delete, parameters: nil, encoding: JSONEncoding.default, headers: headers) .responseJSON { (response: AFDataResponse<Any>) in
            DPrint("deleteContact responce:", response)
            switch(response.result) {
            case .success(let value):
                completionHandler(APIResult.success(value))
            case .failure(let error):
                completionHandler(APIResult.failure(error))
            }
        }
    }
    
    func createEncryptedContact(token: String, encryptedContact: String, encryptedContactHash: String, completionHandler: @escaping (APIResult<Any>) -> Void) {
        
        let headers: HTTPHeaders = [
            "Authorization": "JWT " + token,
            "Accept": "application/json"
        ]
        
        let parameters: Parameters = [
            JSONKey.encryptedData.rawValue: encryptedContact,
            //JSONKey.emailHash.rawValue: encryptedContactHash,
            JSONKey.encrypted.rawValue: true,
        ]
        
        DPrint("createEncryptedContact parameters:", parameters)
        
        let url = EndPoint.baseUrl.rawValue + EndPoint.contact.rawValue
        
        DPrint("createEncryptedContact url:", url)
        
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers) .responseJSON { (response: AFDataResponse<Any>) in
            DPrint("createEncryptedContact responce:", response)
            switch(response.result) {
            case .success(let value):
                completionHandler(APIResult.success(value))
            case .failure(let error):
                completionHandler(APIResult.failure(error))
            }
        }
    }
    
    func updateEncryptedContact(token: String, contactID: String, encryptedContact: String, encryptedContactHash: String, completionHandler: @escaping (APIResult<Any>) -> Void) {
        
        let headers: HTTPHeaders = [
            "Authorization": "JWT " + token,
            "Accept": "application/json"
        ]
        
        let parameters: Parameters = [
            JSONKey.encryptedData.rawValue: encryptedContact,
            //JSONKey.emailHash.rawValue: encryptedContactHash,
            JSONKey.encrypted.rawValue: true,
        ]
        
        DPrint("updateEncryptedContact parameters:", parameters)
        
        let url = EndPoint.baseUrl.rawValue + EndPoint.contact.rawValue + contactID + "/"
        
        DPrint("updateEncryptedContact url:", url)
        
        AF.request(url, method: .patch, parameters: parameters, encoding: JSONEncoding.default, headers: headers) .responseJSON { (response: AFDataResponse<Any>) in
            switch(response.result) {
            case .success(let value):
                completionHandler(APIResult.success(value))
            case .failure(let error):
                completionHandler(APIResult.failure(error))
            }
        }
    }
    
    // MARK: - White/Black lists
    
    func addContactToBlackList(token: String, name: String, email: String, completionHandler: @escaping (APIResult<Any>) -> Void) {
        
        let headers: HTTPHeaders = [
            "Authorization": "JWT " + token,
            "Accept": "application/json"
        ]
        
        let parameters: Parameters = [
            JSONKey.folderName.rawValue: name,
            JSONKey.email.rawValue: email,
        ]
        
        DPrint("addContactToBlackList parameters:", parameters)
        
        let url = EndPoint.baseUrl.rawValue + EndPoint.blackList.rawValue
        
        DPrint("addContactToBlackList url:", url)
        
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers) .responseJSON { (response: AFDataResponse<Any>) in
            DPrint("addContactToBlackList responce:", response)
            switch(response.result) {
            case .success(let value):
                completionHandler(APIResult.success(value))
            case .failure(let error):
                completionHandler(APIResult.failure(error))
            }
        }
    }
    
    func deleteContactFromBlackList(token: String, contactID: String, completionHandler: @escaping (APIResult<Any>) -> Void) {
        
        let headers: HTTPHeaders = [
            "Authorization": "JWT " + token,
            "Accept": "application/json"
        ]
        
        let url = EndPoint.baseUrl.rawValue + EndPoint.blackList.rawValue + contactID + "/"
        
        DPrint("deleteContactFromBlackList url:", url)
        
        AF.request(url, method: .delete, parameters: nil, encoding: JSONEncoding.default, headers: headers) .responseJSON { (response: AFDataResponse<Any>) in
            DPrint("deleteContactFromBlackList responce:", response)
            switch(response.result) {
            case .success(let value):
                completionHandler(APIResult.success(value))
            case .failure(let error):
                completionHandler(APIResult.failure(error))
            }
        }
    }
    
    func addContactToWhiteList(token: String, name: String, email: String, completionHandler: @escaping (APIResult<Any>) -> Void) {
        
        let headers: HTTPHeaders = [
            "Authorization": "JWT " + token,
            "Accept": "application/json"
        ]
        
        let parameters: Parameters = [
            JSONKey.folderName.rawValue: name,
            JSONKey.email.rawValue: email,
            ]
        
        DPrint("addContactToWhiteList parameters:", parameters)
        
        let url = EndPoint.baseUrl.rawValue + EndPoint.whiteList.rawValue
        
        DPrint("addContactToWhiteList url:", url)
        
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers) .responseJSON { (response: AFDataResponse<Any>) in
            DPrint("addContactToWhiteList responce:", response)
            switch(response.result) {
            case .success(let value):
                completionHandler(APIResult.success(value))
            case .failure(let error):
                completionHandler(APIResult.failure(error))
            }
        }
    }
    
    func deleteContactFromWhiteList(token: String, contactID: String, completionHandler: @escaping (APIResult<Any>) -> Void) {
        
        let headers: HTTPHeaders = [
            "Authorization": "JWT " + token,
            "Accept": "application/json"
        ]
        
        let url = EndPoint.baseUrl.rawValue + EndPoint.whiteList.rawValue + contactID + "/"
        
        DPrint("deleteContactFromWhiteList url:", url)
        
        AF.request(url, method: .delete, parameters: nil, encoding: JSONEncoding.default, headers: headers) .responseJSON { (response: AFDataResponse<Any>) in
            DPrint("deleteContactFromWhiteList responce:", response)
            switch(response.result) {
            case .success(let value):
                completionHandler(APIResult.success(value))
            case .failure(let error):
                completionHandler(APIResult.failure(error))
            }
        }
    }
    
    func whiteListContacts(token: String, completionHandler: @escaping (APIResult<Any>) -> Void) {
        
        let headers: HTTPHeaders = [
            "Authorization": "JWT " + token,
            "Accept": "application/json"
        ]
        
        let url = EndPoint.baseUrl.rawValue + EndPoint.whiteList.rawValue
        
        DPrint("whiteListContacts url:", url)
        
        AF.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers) .responseJSON { (response: AFDataResponse<Any>) in
            DPrint("whiteListContacts responce:", response)
            switch(response.result) {
            case .success(let value):
                completionHandler(APIResult.success(value))
            case .failure(let error):
                completionHandler(APIResult.failure(error))
            }
        }
    }
    
    func blackListContacts(token: String, completionHandler: @escaping (APIResult<Any>) -> Void) {
        
        let headers: HTTPHeaders = [
            "Authorization": "JWT " + token,
            "Accept": "application/json"
        ]
        
        let url = EndPoint.baseUrl.rawValue + EndPoint.blackList.rawValue
        
        DPrint("blackListContacts url:", url)
        
        AF.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers) .responseJSON { (response: AFDataResponse<Any>) in
            DPrint("blackListContacts responce:", response)
            switch(response.result) {
            case .success(let value):
                completionHandler(APIResult.success(value))
            case .failure(let error):
                completionHandler(APIResult.failure(error))
            }
        }
    }
    
    // MARK: - Download
    func loadAttachFile(url: String, completionHandler: @escaping (APIResult<Any>) -> Void) {
 
        DPrint("load Attach file at url:", url)
        
        let destination = DownloadRequest.suggestedDownloadDestination(for: .documentDirectory)
        
        AF.download(url, to: destination).downloadProgress(queue: DispatchQueue.global(qos: .utility)) { (progress) in
            DPrint("Progress: \(progress.fractionCompleted)")
            }.responseData { ( response ) in
                completionHandler(APIResult.success(response.fileURL ?? ""))
        }
    }
    
    // MARK: - Attachments
    func createAttachment(token: String, file: Data, fileName: String, mimeType: String, messageID: String, encrypted: Bool, completionHandler: @escaping (APIResult<Any>) -> Void) {
        
        let headers: HTTPHeaders = [
            "Authorization": "JWT " + token,
            "Accept": "application/json"
        ]
        
        let parameters: Parameters = [
            JSONKey.messageID.rawValue: messageID,
            JSONKey.inline.rawValue: false,
            JSONKey.encrypted.rawValue: encrypted,
            JSONKey.fileType.rawValue: mimeType,
            JSONKey.folderName.rawValue:fileName
            
        ]
        
        DPrint("createAttachment parameters:", parameters)
        
        let url = EndPoint.baseUrl.rawValue + EndPoint.createAttachment.rawValue
        
        DPrint("createAttachment url:", url)
        
        AF.upload(multipartFormData: { (multipartFormData) in

            for param in parameters {
                if let value = param.value as? String {
                    multipartFormData.append(value.data(using: .utf8)!, withName: param.key)
                }
                
                if let value = param.value as? Bool {
                    multipartFormData.append(value.description.data(using: .utf8)!, withName: param.key)
                }
            }

            multipartFormData.append(file, withName: JSONKey.fileData.rawValue, fileName: fileName, mimeType: mimeType)

        }, to: url, method: .post , headers: headers)
            .uploadProgress { (progress) in
            DPrint("upload Data:", progress.fractionCompleted * 100)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: attachUploadUpdateNotificationID), object: progress.fractionCompleted)
        }
            .responseJSON(completionHandler: { (response) in
                switch(response.result) {
                case .success(let value):
                    DPrint("upload Data succes value:", value)
                    completionHandler(APIResult.success(value))
                case .failure(let error):
                    completionHandler(APIResult.failure(error))
                }
            })
    }
    
    func deleteAttachment(token: String, attachmentID: String, completionHandler: @escaping (APIResult<Any>) -> Void) {
        
        let headers: HTTPHeaders = [
            "Authorization": "JWT " + token,
            "Accept": "application/json"
        ]
        
        let url = EndPoint.baseUrl.rawValue + EndPoint.deleteAttachment.rawValue + attachmentID + "/"
        
        DPrint("deleteAttachment url:", url)
        
        AF.request(url, method: .delete, parameters: nil, encoding: JSONEncoding.default, headers: headers) .responseJSON { (response: AFDataResponse<Any>) in
            DPrint("deleteAttachment responce:", response)
            switch(response.result) {
            case .success(let value):
                completionHandler(APIResult.success(value))
            case .failure(let error):
                completionHandler(APIResult.failure(error))
            }
        }
    }
    
    func updateAttachment(token: String, attachmentID: String, file: Data, fileName: String, mimeType: String, messageID: Int, encrypted: Bool, completionHandler: @escaping (APIResult<Any>) -> Void) {
        
        let headers: HTTPHeaders = [
            "Authorization": "JWT " + token,
            "Accept": "application/json",
            "Content-type": "multipart/form-data"
        ]
        
        let parameters: Parameters = [
            JSONKey.messageID.rawValue: messageID.description,
            //JSONKey.fileData.rawValue: file,
            JSONKey.inline.rawValue: false,
            JSONKey.encrypted.rawValue: encrypted,
            JSONKey.fileType.rawValue: mimeType,
            JSONKey.folderName.rawValue:fileName
        ]
        
        DPrint("updateAttachment parameters:", parameters)
        
        let url = EndPoint.baseUrl.rawValue + EndPoint.updateAttachment.rawValue  + attachmentID + "/"
        
        DPrint("updateAttachment url:", url)
        
        AF.upload(multipartFormData: { (multipartFormData) in
            for param in parameters {
                if let value = param.value as? String {
                    multipartFormData.append(value.data(using: .utf8)!, withName: param.key)
                }
                if let value = param.value as? Bool {
                    multipartFormData.append(value.description.data(using: .utf8)!, withName: param.key)
                }
            }
            multipartFormData.append(file, withName: JSONKey.fileData.rawValue, fileName: fileName, mimeType: mimeType)
        }, to: url, method: .patch , headers: headers)
            .uploadProgress { (progress) in
            DPrint("updateAttachment upload Data:", progress.fractionCompleted * 100)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: attachUploadUpdateNotificationID), object: progress.fractionCompleted)
        }
            .responseJSON(completionHandler: { (response) in
                switch(response.result) {
                case .success(let value):
                    DPrint("updateAttachment upload Data succes value:", value)
                    completionHandler(APIResult.success(value))
                case .failure(let error):
                    completionHandler(APIResult.failure(error))
                }
        })
    }
    
    // MARK: - Settings
    func updateSettings(token: String,
                        settingsID: Int,
                        recoveryEmail: String,
                        dispalyName: String,
                        savingContacts: Bool,
                        encryptContacts: Bool,
                        encryptAttachment: Bool,
                        encryptSubject: Bool,
                        blockExternalImages: Bool,
                        htmlDisabled: Bool,
                        completionHandler: @escaping (APIResult<Any>) -> Void) {
        
        let headers: HTTPHeaders = [
            "Authorization": "JWT " + token,
            "Accept": "application/json"
        ]
        
        var parameters: Parameters = [
            JSONKey.subjectEncrypted.rawValue: encryptSubject,
            JSONKey.savingContacts.rawValue: savingContacts,
            JSONKey.contactsEncrypted.rawValue: encryptContacts,
            JSONKey.attachmentEncrypted.rawValue: encryptAttachment,
            JSONKey.blockExternalImages.rawValue: blockExternalImages,
            JSONKey.htmlEditor.rawValue: htmlDisabled
        ]
        
        if !recoveryEmail.isEmpty {
            parameters[JSONKey.recoveryEmail.rawValue] = recoveryEmail
        }
        
        if !dispalyName.isEmpty {
            parameters[JSONKey.displayName.rawValue] = dispalyName
        }
        
        DPrint("updateSettings parameters:", parameters)
        
        let url = EndPoint.baseUrl.rawValue + EndPoint.settings.rawValue + "\(settingsID)" + "/"
        
        DPrint("updateSettings url:", url)
        
        AF.request(url, method: .patch, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .responseJSON { (response: AFDataResponse<Any>) in
            DPrint("updateSettings responce:", response)
            switch(response.result) {
            case .success(let value):
                completionHandler(APIResult.success(value))
            case .failure(let error):
                completionHandler(APIResult.failure(error))
            }
        }
    }
    
    // MARK: - Notifications
    func createAppToken(token: String, deviceToken: String, completionHandler: @escaping (APIResult<Any>) -> Void) {
        
        let headers: HTTPHeaders = [
            "Authorization": "JWT " + token,
            "Accept": "application/json"
        ]
        
        let parameters: Parameters = [
            JSONKey.token.rawValue: deviceToken,
            JSONKey.platform.rawValue: Device.PLATFORM
        ]
        
        DPrint("createAppToken parameters:", parameters)
        
        let url = EndPoint.baseUrl.rawValue + EndPoint.appToken.rawValue
        
        DPrint("createAppToken url:", url)
        
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .responseJSON { (response: AFDataResponse<Any>) in
            switch(response.result) {
            case .success(let value):
                completionHandler(APIResult.success(value))
            case .failure(let error):
                completionHandler(APIResult.failure(error))
            }
        }
    }
    
    // MARK: - App Version Check
    func checkAppVersion(onCompletion: @escaping ((String, Bool) -> Void)) {
        let url = "\(EndPoint.baseUrl.rawValue)\(EndPoint.appVersion.rawValue)"
        DPrint("App Version Check URL: \(url)")
        AF.request(url).response { (data) in
            do {
                if let ldata = data.data {
                if let response = try JSONSerialization.jsonObject(with: ldata, options: .mutableLeaves) as? [String: Any],
                   let version = response["version"] as? Double,
                   let isForceUpdate = response["is_force_update"] as? Bool {
                    onCompletion(String(version), isForceUpdate)
                    // onCompletion("1.4.2", true)
                } else {
                    onCompletion("", false)
                }
                } else {
                    onCompletion("", false)
                }
            } catch {
                DPrint(error.localizedDescription)
                onCompletion("", false)
            }
        }
    }
}
