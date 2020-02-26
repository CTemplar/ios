//
//  RestAPIService.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 01.10.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import Alamofire

enum EndPoint: String {
    #if DEVELOPMENT
    case baseUrl = "https://devapi.ctemplar.com/"
    #else
    case baseUrl = "https://mail.ctemplar.com/api/" //"https://api.ctemplar.com/"
    #endif
    case signIn = "auth/sign-in/"
    case signUp = "auth/sign-up/"
    case checkUsername = "auth/check-username/"
    case recoveryCode = "auth/recover/"
    case resetPassword = "auth/reset/"
    case changePassword = "auth/change-password/"
    case verifyToken = "auth/verify/"
    case refreshToken = "auth/refresh/"
    case signOut = "auth/sign-out/"
    case messages = "emails/messages/"
    case mailboxes = "emails/mailboxes/"
    case publicKeys = "emails/keys/"
    case unreadCounter = "emails/unread/"
    case customFolders = "emails/custom-folder/"
    case userMyself = "users/myself/"
    case contact = "users/contacts/"
    case createAttachment = "emails/attachments/create/"
    case deleteAttachment = "emails/attachments/"
    case updateAttachment = "emails/attachments/update/"
    case settings = "users/settings/"
    case blackList = "users/blacklist/"
    case whiteList = "users/whitelist/"
    case captcha = "auth/captcha"
    case verifyCaptcha = "auth/captcha-verify/"
    case appToken = "users/app-token/"
}

enum JSONKey: String {
    case userName = "username"
    case password = "password"
    case oldPassword = "old_password"
    case confirmPassword = "confirm_password"
    case deleteData = "delete_data"
    case newKeys = "new_keys"
    case privateKey = "private_key"
    case publicKey = "public_key"
    case fingerprint = "fingerprint"
    case recaptcha = "recaptcha"
    case recoveryEmail = "recovery_email"
    case apnsToken = "device_token"
    case fromAddress = "from_address"
    case redeemCode = "redeem_code"
    case stripeToken = "stripe_token"
    case memory = "memory"
    case emailCount = "email_count"
    case paymentType = "payment_type"
    case resetPasswordCode = "code"
    case token = "token"
    case idIn = "id__in"
    case folder = "folder"
    case content = "content"
    case starred = "starred"
    case read = "read"
    case limit = "limit"
    case offset = "offset"
    case folderName = "name"
    case folderColor = "color"
    case receiver = "receiver"
    case carbonCopy = "cc"
    case blindCarbonCopy = "bcc"
    case sender = "sender"
    case mailbox = "mailbox"
    case send = "send"
    case subject = "subject"
    case email = "email"
    case emails = "emails"
    case address = "address"
    case note = "note"
    case phone = "phone"
    case encrypted = "is_encrypted"
    case encryption = "encryption"
    case messageID = "message"
    case fileData = "document"
    case inline = "is_inline"
    case attachments = "attachments"
    case parent = "parent"
    case selfDestructionDate = "destruct_date"
    case delayedDeliveryDate = "delayed_delivery"
    case deadManDate = "dead_man_duration"
    case displayName = "display_name"
    case savingContacts = "save_contacts"
    case isDefault = "is_default"
    case userSignature = "signature"
    case signUpCaptchaKey = "captcha_key"
    case signUpCaptchaValue = "captcha_value"
    case captchaKey = "key"
    case captchaValue = "value"
    case otp = "otp"
    case emailHash = "email_hash"
    case encryptedData = "encrypted_data"
    case contactsEncrypted = "is_contacts_encrypted"
    case attachmentEncrypted = "is_attachments_encrypted"
    case platform = "platform"
    case forwardAttachmentsMessage = "forward_attachments_of_message"
}

class RestAPIService {
    
    //FAILURE: Error Domain=kCFErrorDomainCFNetwork Code=303 "(null)" UserInfo={NSErrorPeerAddressKey=<CFData 0x604000292b10 [0x1137a5c80]>{length = 16, capacity = 16, bytes = 0x100201bb681237e50000000000000000}, _kCFStreamErrorCodeKey=-2201, _kCFStreamErrorDomainKey=4}
    
    func refreshToken(token: String, completionHandler: @escaping (APIResult<Any>) -> Void) {
        
        let headers: HTTPHeaders = [
            "Accept": "application/json"
        ]
        
        let parameters: Parameters = [
            JSONKey.token.rawValue: token
        ]
        
        let url = EndPoint.baseUrl.rawValue + EndPoint.refreshToken.rawValue
        
        print("verifyToken parameters:", parameters)
        print("refreshToken url:", url)
        
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers) .responseJSON { (response: AFDataResponse<Any>) in
            
            print("refreshToken responce:", response)
            
            switch(response.result) {
            case .success(let value):
                completionHandler(APIResult.success(value))
            case .failure(let error):
                completionHandler(APIResult.failure(error))
            }
        }
    }
    
    //MARK: - Authentication
    
    func signOut(token: String, deviceToken: String, completionHandler: @escaping (APIResult<Any>) -> Void) {
        let headers: HTTPHeaders = [
            "Authorization": "JWT " + token,
            "Accept": "application/json"
        ]
        
        let url = EndPoint.baseUrl.rawValue + EndPoint.signOut.rawValue  + "?platform=ios&device_token=" + deviceToken
        
        AF.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
            switch response.result {
            case .success(let value):
                completionHandler(APIResult.success(value))
            case .failure(let error):
                completionHandler(APIResult.failure(error))
            }
        }
    }
    
    //MARK: - User
    
    func userMyself(token: String, completionHandler: @escaping (APIResult<Any>) -> Void) {
        
        let headers: HTTPHeaders = [
            "Authorization": "JWT " + token,
            "Accept": "application/json"
        ]
        
        let url = EndPoint.baseUrl.rawValue + EndPoint.userMyself.rawValue
        
        print("userMyself url:", url)
        
        AF.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers) /*.validate()*/ .responseJSON { (response: AFDataResponse<Any>) in
//
            print("userMyself responce:", response)
//
            switch(response.result) {
            case .success(let value):
                completionHandler(APIResult.success(value))
            case .failure(let error):
                completionHandler(APIResult.failure(error))
            }
        }
    }
    
    //MARK: - Mail
    
    func messagesList(token: String, folder: String, messagesIDIn: String, filter: String, seconds: Int, offset: Int, pageLimit: Int = k_pageLimit, completionHandler: @escaping (APIResult<Any>) -> Void) {
        
        let headers: HTTPHeaders = [
            "Authorization": "JWT " + token,
            "Accept": "application/json"
        ]
        
        var timeParameter = ""
        
        if seconds > 0 {
            timeParameter = "&seconds=" + seconds.description
        }
        
        var limitParams = ""
        
        if offset > -1 {
            limitParams = String(format: "?limit=%d&offset=%d", pageLimit, offset)
        }
        
        //timeParameter = "?seconds=100000000"
        
        var url = EndPoint.baseUrl.rawValue + EndPoint.messages.rawValue + limitParams + folder + messagesIDIn + timeParameter + filter//"?starred=1"// "?read=0"
        //let url = EndPoint.baseUrl.rawValue + EndPoint.messages.rawValue + "?seconds=" + seconds
        //let url = "https://devapi.ctemplar.com/emails/messages/?limit=20&offset=0&folder=inbox&read=false&seconds=30"
        //https://devapi.ctemplar.com/emails/messages/?limit=20&offset=0&starred=true
        url = url.replacingOccurrences(of: " ", with: "%20")
        //print("messagesList parameters:", parameters)
        print("messagesList url:", url)
        
        AF.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers) /*.validate()*/ .responseJSON { (response: AFDataResponse<Any>) in
//
            print("messagesList responce:", response)
//
            switch(response.result) {
            case .success(let value):
                completionHandler(APIResult.success(value))
            case .failure(let error):
                completionHandler(APIResult.failure(error))
            }
        }
    }
    
    func updateMessages(token: String, messageID: String, messagesIDIn: String, folder: String, starred: Bool, read: Bool, updateFolder: Bool, updateStarred: Bool, updateRead: Bool, completionHandler: @escaping (APIResult<Any>) -> Void) {
        
        let headers: HTTPHeaders = [
            "Authorization": "JWT " + token,
            "Accept": "application/json"
        ]
        
        /*
        let parameters: Parameters = [
            JSONKey.folder.rawValue: folder,
            JSONKey.starred.rawValue: starred,
            JSONKey.read.rawValue: read
        ]*/
        
        let configureParameters : NSMutableDictionary = [:]
        
        if updateFolder {
            configureParameters[JSONKey.folder.rawValue] = folder
        }
        
        if updateStarred {
            configureParameters[JSONKey.starred.rawValue] = starred
        }
        
        if updateRead{
            configureParameters[JSONKey.read.rawValue] = read
        }
        
        let parameters: Parameters = configureParameters as! Parameters
        
        let url = EndPoint.baseUrl.rawValue + EndPoint.messages.rawValue + messageID + messagesIDIn
        
        print("updateMessages parameters:", parameters)
        print("updateMessages url:", url)
        
        AF.request(url, method: .patch, parameters: parameters, encoding: JSONEncoding.default, headers: headers) /*.validate()*/ .responseJSON { (response: AFDataResponse<Any>) in
//
            print("updateMessages responce:", response)
//
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
        
        print("unreadMessagesCounter url:", url)
        
        AF.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers) /*.validate()*/ .responseJSON { (response: AFDataResponse<Any>) in
//
            //print("unreadMessagesCounter responce:", response)
//
            switch(response.result) {
            case .success(let value):
                completionHandler(APIResult.success(value))
            case .failure(let error):
                completionHandler(APIResult.failure(error))
            }
        }
    }
    
    func createMessage(token: String, parentID: String, content: String, subject: String, recieversList: [[String]], folder: String, mailboxID: Int, send: Bool, encrypted: Bool, encryptionObject: [String : String], attachments: Array<[String : String]>, completionHandler: @escaping (APIResult<Any>) -> Void) {
    
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
            JSONKey.encrypted.rawValue : encrypted,
            JSONKey.encryption.rawValue : encryptionObject,
            JSONKey.attachments.rawValue : attachments,
            JSONKey.parent.rawValue : parentID
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
        
        let url = EndPoint.baseUrl.rawValue + EndPoint.messages.rawValue
        
        print("createMessage url:", url)
        print("createMessage parameters:", parameters)
        
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers) .responseJSON { (response: AFDataResponse<Any>) in
//
            print("createMessage responce:", response)
//
            switch(response.result) {
            case .success(let value):
                completionHandler(APIResult.success(value))
            case .failure(let error):
                completionHandler(APIResult.failure(error))
            }
        }
    }
    
    func updateSendingMessage(token: String, messageID: String, mailboxID: Int, sender: String, encryptedMessage: String, subject: String, recieversList: [[String]], folder: String, send: Bool, encryptionObject: [String : String], encrypted: Bool, attachments: Array<[String : String]>, selfDestructionDate: String, delayedDeliveryDate: String, deadManTimer: Int, completionHandler: @escaping (APIResult<Any>) -> Void) {
        
        let headers: HTTPHeaders = [
            "Authorization": "JWT " + token,
            "Accept": "application/json"
        ]
        
        var parameters: Parameters = [
            JSONKey.content.rawValue : encryptedMessage,
            JSONKey.folder.rawValue: folder,
            JSONKey.mailbox.rawValue: mailboxID,
            JSONKey.sender.rawValue: sender,
            JSONKey.subject.rawValue: subject,
            JSONKey.receiver.rawValue: recieversList[0],
            JSONKey.send.rawValue: send,
            JSONKey.encryption.rawValue : encryptionObject,
            JSONKey.encrypted.rawValue : encrypted,
            JSONKey.attachments.rawValue : attachments,
            //JSONKey.selfDestructionDate.rawValue : selfDestructionDate,
            //JSONKey.delayedDeliveryDate.rawValue : delayedDeliveryDate,
            //JSONKey.deadManDate.rawValue : deadManDate
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
        
        print("updateSendingMessage parameters:", parameters)
        print("updateSendingMessage url:", url)
        
        AF.request(url, method: .patch, parameters: parameters, encoding: JSONEncoding.default, headers: headers) .responseJSON { (response: AFDataResponse<Any>) in
//
            print("updateSendingMessage responce:", response)
//
            switch(response.result) {
            case .success(let value):
                completionHandler(APIResult.success(value))
            case .failure(let error):
                completionHandler(APIResult.failure(error))
            }
        }
    }
    
    func saveDraftMesssage(token: String, messageID: String, messageContent: String, subject: String, recieversList: [[String]], folder: String, encryptionObject: [String : String], encrypted: Bool, selfDestructionDate: String, delayedDeliveryDate: String, deadManTimer: Int, completionHandler: @escaping (APIResult<Any>) -> Void) {
        
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
        
        let url = EndPoint.baseUrl.rawValue + EndPoint.messages.rawValue + messageID + "/"
        
        print("saveDraftMesssage parameters:", parameters)
        print("saveDraftMesssage url:", url)
        
        AF.request(url, method: .patch, parameters: parameters, encoding: JSONEncoding.default, headers: headers) .responseJSON { (response: AFDataResponse<Any>) in
//
            print("saveDraftMesssage responce:", response)
//
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
        
        //print("messagesList parameters:", parameters)
        print("deleteMessages url:", url)
        
        AF.request(url, method: .delete, parameters: nil, encoding: JSONEncoding.default, headers: headers) .responseJSON { (response: AFDataResponse<Any>) in
//
            print("deleteMessages responce:", response)
//
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
        
        //print("messagesList parameters:", parameters)
        print("deleteMessage url:", url)
        
        AF.request(url, method: .delete, parameters: nil, encoding: JSONEncoding.default, headers: headers) .responseJSON { (response: AFDataResponse<Any>) in
//
            print("deleteMessage responce:", response)
//
            switch(response.result) {
            case .success(let value):
                completionHandler(APIResult.success(value))
            case .failure(let error):
                completionHandler(APIResult.failure(error))
            }
        }
    }
    
    //MARK: - Mailbox
    
    func mailboxesList(token: String, completionHandler: @escaping (APIResult<Any>) -> Void) {
        
        let headers: HTTPHeaders = [
            "Authorization": "JWT " + token,
            "Accept": "application/json"
        ]
        
        let url = EndPoint.baseUrl.rawValue + EndPoint.mailboxes.rawValue
        
        print("mailboxes url:", url)
        
        AF.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers) /*.validate()*/ .responseJSON { (response: AFDataResponse<Any>) in
//
            print("mailboxes responce:", response)
//
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
        
        print("updateMailbox parameters:", parameters)
        print("updateMailbox url:", url)
        
        AF.request(url, method: .patch, parameters: parameters, encoding: JSONEncoding.default, headers: headers) .responseJSON { (response: AFDataResponse<Any>) in
//
            print("updateMailbox responce:", response)
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
        //?email__in=atif2@ctemplar.com,atif3@ctemplar.com
        let url = EndPoint.baseUrl.rawValue + EndPoint.publicKeys.rawValue //+ "?email__in=dmitry5@dev.ctemplar.com"
        
        print("publicKeyList url:", url)
        
        AF.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers) .responseJSON { (response: AFDataResponse<Any>) in
//
            print("publicKeyList responce:", response)
//
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
        
        print("publicKeyFor parameters:", parameters)
        
        let url = EndPoint.baseUrl.rawValue + EndPoint.publicKeys.rawValue + "/"//+ "?email__in=" + userEmail
        
        print("publicKeyFor url:", url)
        
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers) .responseJSON { (response: AFDataResponse<Any>) in
//
            print("publicKeyFor responce:", response)
//
            switch(response.result) {
            case .success(let value):
                completionHandler(APIResult.success(value))
            case .failure(let error):
                completionHandler(APIResult.failure(error))
            }
        }
    }
    
    //MARK: - Folders
    
    func customFoldersList(token: String, limit: Int, offset: Int, completionHandler: @escaping (APIResult<Any>) -> Void) {
        
        let headers: HTTPHeaders = [
            "Authorization": "JWT " + token,
            "Accept": "application/json"
        ]
        
        let parameters: Parameters = [
            JSONKey.limit.rawValue: limit,
            JSONKey.offset.rawValue: offset
        ]
        
        print("customFolders parameters:", parameters)
        
        let url = EndPoint.baseUrl.rawValue + EndPoint.customFolders.rawValue
        
        print("customFolders url:", url)
        
        AF.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers) /*.validate()*/ .responseJSON { (response: AFDataResponse<Any>) in
//
            print("customFolders responce:", response)
//
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
        
        print("createCustomFolder parameters:", parameters)
        
        let url = EndPoint.baseUrl.rawValue + EndPoint.customFolders.rawValue
        
        print("createCustomFolder url:", url)
        
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers) /*.validate()*/ .responseJSON { (response: AFDataResponse<Any>) in
//
            print("createCustomFolder responce:", response)
//
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
        
        print("updateCustomFolder url:", url)
        
        AF.request(url, method: .patch, parameters: parameters, encoding: JSONEncoding.default, headers: headers) .responseJSON { (response: AFDataResponse<Any>) in
//
            print("updateCustomFolder responce:", response)
//
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
        
        print("deleteCustomFolder url:", url)
        
        AF.request(url, method: .delete, parameters: nil, encoding: JSONEncoding.default, headers: headers) .responseJSON { (response: AFDataResponse<Any>) in
//
            print("deleteCustomFolder responce:", response)
//
            switch(response.result) {
            case .success(let value):
                completionHandler(APIResult.success(value))
            case .failure(let error):
                completionHandler(APIResult.failure(error))
            }
        }
    }
    
    //MARK: - Contacts
    
    func userContacts(token: String, fetchAll: Bool, offset: Int, completionHandler: @escaping (APIResult<Any>) -> Void) {
        
        let headers: HTTPHeaders = [
            "Authorization": "JWT " + token,
            "Accept": "application/json"
        ]
        
        var params = ""
        
        if !fetchAll {
            params = String(format: "?limit=%d&offset=%d&q=", k_contactPageLimit, offset)
        }
        
        let url = EndPoint.baseUrl.rawValue + EndPoint.contact.rawValue + params
        
        print("userContacts url:", url)
        
        AF.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers) .responseJSON { (response: AFDataResponse<Any>) in
//
            print("userContacts responce:", response)
//
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
        
        print("createContact parameters:", parameters)
        
        let url = EndPoint.baseUrl.rawValue + EndPoint.contact.rawValue
        
        print("createContact url:", url)
        
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers) .responseJSON { (response: AFDataResponse<Any>) in
//
            print("createContact responce:", response)
//
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
        
        print("updateContact parameters:", parameters)
        
        let url = EndPoint.baseUrl.rawValue + EndPoint.contact.rawValue + contactID + "/"
        
        print("updateContact url:", url)
        
        AF.request(url, method: .patch, parameters: parameters, encoding: JSONEncoding.default, headers: headers) .responseJSON { (response: AFDataResponse<Any>) in
//
            print("updateContact responce:", response)
//
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
        
        print("deleteContact url:", url)
        
        AF.request(url, method: .delete, parameters: nil, encoding: JSONEncoding.default, headers: headers) .responseJSON { (response: AFDataResponse<Any>) in
//
            print("deleteContact responce:", response)
//
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
        
        print("createEncryptedContact parameters:", parameters)
        
        let url = EndPoint.baseUrl.rawValue + EndPoint.contact.rawValue
        
        print("createEncryptedContact url:", url)
        
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers) .responseJSON { (response: AFDataResponse<Any>) in
//
            print("createEncryptedContact responce:", response)
//
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
        
        print("updateEncryptedContact parameters:", parameters)
        
        let url = EndPoint.baseUrl.rawValue + EndPoint.contact.rawValue + contactID + "/"
        
        print("updateEncryptedContact url:", url)
        
        AF.request(url, method: .patch, parameters: parameters, encoding: JSONEncoding.default, headers: headers) .responseJSON { (response: AFDataResponse<Any>) in
//
           // print("updateEncryptedContact responce:", response)
//
            switch(response.result) {
            case .success(let value):
                completionHandler(APIResult.success(value))
            case .failure(let error):
                completionHandler(APIResult.failure(error))
            }
        }
    }
    
    //MARK: - White/Black lists
    
    func addContactToBlackList(token: String, name: String, email: String, completionHandler: @escaping (APIResult<Any>) -> Void) {
        
        let headers: HTTPHeaders = [
            "Authorization": "JWT " + token,
            "Accept": "application/json"
        ]
        
        let parameters: Parameters = [
            JSONKey.folderName.rawValue: name,
            JSONKey.email.rawValue: email,
        ]
        
        print("addContactToBlackList parameters:", parameters)
        
        let url = EndPoint.baseUrl.rawValue + EndPoint.blackList.rawValue
        
        print("addContactToBlackList url:", url)
        
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers) .responseJSON { (response: AFDataResponse<Any>) in
//
            print("addContactToBlackList responce:", response)
//
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
        
        print("deleteContactFromBlackList url:", url)
        
        AF.request(url, method: .delete, parameters: nil, encoding: JSONEncoding.default, headers: headers) .responseJSON { (response: AFDataResponse<Any>) in
//
            print("deleteContactFromBlackList responce:", response)
//
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
        
        print("addContactToWhiteList parameters:", parameters)
        
        let url = EndPoint.baseUrl.rawValue + EndPoint.whiteList.rawValue
        
        print("addContactToWhiteList url:", url)
        
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers) .responseJSON { (response: AFDataResponse<Any>) in
//
            print("addContactToWhiteList responce:", response)
//
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
        
        print("deleteContactFromWhiteList url:", url)
        
        AF.request(url, method: .delete, parameters: nil, encoding: JSONEncoding.default, headers: headers) .responseJSON { (response: AFDataResponse<Any>) in
//
            print("deleteContactFromWhiteList responce:", response)
//
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
        
        print("whiteListContacts url:", url)
        
        AF.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers) .responseJSON { (response: AFDataResponse<Any>) in
//
            print("whiteListContacts responce:", response)
//
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
        
        print("blackListContacts url:", url)
        
        AF.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers) .responseJSON { (response: AFDataResponse<Any>) in
//
            print("blackListContacts responce:", response)
//
            switch(response.result) {
            case .success(let value):
                completionHandler(APIResult.success(value))
            case .failure(let error):
                completionHandler(APIResult.failure(error))
            }
        }
    }
    
    //MARK: - Download
    
    func loadAttachFile(url: String, completionHandler: @escaping (APIResult<Any>) -> Void) {
 
        print("load Attach file at url:", url)
        
        let destination = DownloadRequest.suggestedDownloadDestination(for: .documentDirectory)
        
        AF.download(url, to: destination).downloadProgress(queue: DispatchQueue.global(qos: .utility)) { (progress) in
            print("Progress: \(progress.fractionCompleted)")
            } /*.validate()*/.responseData { ( response ) in
                //print(response.destinationURL!)
                completionHandler(APIResult.success(response.fileURL!/*.lastPathComponent*/))
        }
    }
    
    //MARK: - Attachments
    
    func createAttachment(token: String, file: Data, fileName: String, mimeType: String, messageID: String, encrypted: Bool, completionHandler: @escaping (APIResult<Any>) -> Void) {
        
        let headers: HTTPHeaders = [
            "Authorization": "JWT " + token,
            "Accept": "application/json"
        ]
        
        let parameters: Parameters = [
            JSONKey.messageID.rawValue: messageID,
            //JSONKey.fileData.rawValue: file,
            JSONKey.inline.rawValue: false,
            JSONKey.encrypted.rawValue: encrypted
        ]
        
        print("createAttachment parameters:", parameters)
        
        let url = EndPoint.baseUrl.rawValue + EndPoint.createAttachment.rawValue
        
        print("createAttachment url:", url)
        
        AF.upload(multipartFormData: { (multipartFormData) in

            for param in parameters {
                if let value = param.value as? String {
                    multipartFormData.append(value.data(using: .utf8)!, withName: param.key)
                }
                if let value = param.value as? Bool {
                    multipartFormData.append(value.description.data(using: .utf8)!, withName: param.key)
                }
            }

            multipartFormData.append(file, withName: JSONKey.fileData.rawValue, fileName: fileName, mimeType: mimeType) //"image/jpg"

        }, to: url, method: .post , headers: headers)
            .uploadProgress { (progress) in
            print("upload Data:", progress.fractionCompleted * 100)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: k_attachUploadUpdateNotificationID), object: progress.fractionCompleted)
        }
            .responseJSON(completionHandler: { (response) in
                switch(response.result) {
                case .success(let value):
                    print("upload Data succes value:", value)
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
        
        print("deleteAttachment url:", url)
        
        AF.request(url, method: .delete, parameters: nil, encoding: JSONEncoding.default, headers: headers) .responseJSON { (response: AFDataResponse<Any>) in
//
            print("deleteAttachment responce:", response)
//
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
            "Accept": "application/json"
        ]
        
        let parameters: Parameters = [
            JSONKey.messageID.rawValue: messageID.description,
            //JSONKey.fileData.rawValue: file,
            JSONKey.inline.rawValue: false,
            JSONKey.encrypted.rawValue: encrypted
        ]
        
        print("updateAttachment parameters:", parameters)
        
        let url = EndPoint.baseUrl.rawValue + EndPoint.updateAttachment.rawValue  + attachmentID + "/"
        
        print("updateAttachment url:", url)
        
        AF.upload(multipartFormData: { (multipartFormData) in
//
            for param in parameters {
                if let value = param.value as? String {
                    multipartFormData.append(value.data(using: .utf8)!, withName: param.key)
                }
//
                if let value = param.value as? Bool {
                    multipartFormData.append(value.description.data(using: .utf8)!, withName: param.key)
                }
            }
//
            multipartFormData.append(file, withName: JSONKey.fileData.rawValue, fileName: fileName, mimeType: mimeType) //"image/jpg"
//
        }, to: url, method: .patch , headers: headers)
            .uploadProgress { (progress) in
            print("updateAttachment upload Data:", progress.fractionCompleted * 100)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: k_attachUploadUpdateNotificationID), object: progress.fractionCompleted)
        }
            .responseJSON(completionHandler: { (response) in
                switch(response.result) {
                case .success(let value):
                    print("updateAttachment upload Data succes value:", value)
                    completionHandler(APIResult.success(value))
                case .failure(let error):
                    completionHandler(APIResult.failure(error))
                }
        })/*, encodingCompletion: { (result) in
//
            print("updateAttachment upload Data result:", result)
//
            switch result {
            case .success(let upload, _, _):
//
                upload.uploadProgress(closure: { (progress) in
                    print("updateAttachment upload Data:", progress.fractionCompleted * 100)
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: k_attachUploadUpdateNotificationID), object: progress.fractionCompleted)
                })
//
                upload.responseJSON(completionHandler: { (response) in
                    switch(response.result) {
                    case .success(let value):
                        print("updateAttachment upload Data succes value:", value)
                        completionHandler(APIResult.success(value))
                    case .failure(let error):
                        completionHandler(APIResult.failure(error))
                    }
                })
//
            case .failure(let error):
                print("upload Data error:", error)
            }
        }*/
    }
    
    //MARK: - Settings
    
    func updateSettings(token: String, settingsID: String, recoveryEmail: String, dispalyName: String, savingContacts: Bool, encryptContacts: Bool, encryptAttachment: Bool, completionHandler: @escaping (APIResult<Any>) -> Void) {
        
        let headers: HTTPHeaders = [
            "Authorization": "JWT " + token,
            "Accept": "application/json"
        ]
        
        var parameters: Parameters = [
            JSONKey.savingContacts.rawValue : savingContacts,
            JSONKey.contactsEncrypted.rawValue : encryptContacts,
            JSONKey.attachmentEncrypted.rawValue : encryptAttachment
        ]
        
        if recoveryEmail.count > 0 {
            parameters[JSONKey.recoveryEmail.rawValue] = recoveryEmail
        }
        
        if dispalyName.count > 0 {
            parameters[JSONKey.displayName.rawValue] = dispalyName
        }
        
        print("updateSettings parameters:", parameters)
        
        let url = EndPoint.baseUrl.rawValue + EndPoint.settings.rawValue + settingsID + "/"
        
        print("updateSettings url:", url)
        
        AF.request(url, method: .patch, parameters: parameters, encoding: JSONEncoding.default, headers: headers) /*.validate()*/ .responseJSON { (response: AFDataResponse<Any>) in
//
            print("updateSettings responce:", response)
//
            switch(response.result) {
            case .success(let value):
                completionHandler(APIResult.success(value))
            case .failure(let error):
                completionHandler(APIResult.failure(error))
            }
        }
    }
    
    //MARK: - Notifications
    
    func createAppToken(token: String, deviceToken: String, completionHandler: @escaping (APIResult<Any>) -> Void) {
        
        let headers: HTTPHeaders = [
            "Authorization": "JWT " + token,
            "Accept": "application/json"
        ]
        
        let parameters: Parameters = [
            JSONKey.token.rawValue: deviceToken,
            JSONKey.platform.rawValue: k_platform
        ]
        
        print("createAppToken parameters:", parameters)
        
        let url = EndPoint.baseUrl.rawValue + EndPoint.appToken.rawValue
        
        print("createAppToken url:", url)
        
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers) /*.validate()*/ .responseJSON { (response: AFDataResponse<Any>) in
            
            //print("createAppToken responce:", response)
            
            switch(response.result) {
            case .success(let value):
                completionHandler(APIResult.success(value))
            case .failure(let error):
                completionHandler(APIResult.failure(error))
            }
        }
    }
}
