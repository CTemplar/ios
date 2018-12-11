//
//  RestAPIService.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 01.10.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import Alamofire

class RestAPIService {
    
    enum EndPoint: String {
        case baseUrl = "https://devapi.ctemplar.com/"
        case signIn = "auth/sign-in/"
        case signUp = "auth/sign-up/"
        case checkUsername = "auth/check-username/"
        case recoveryCode = "auth/recover/"
        case resetPassword = "auth/reset/"
        case verifyToken = "auth/verify/"
        case messages = "emails/messages/"
        case mailboxes = "emails/mailboxes/"
        case publicKeys = "emails/keys/"
        case unreadCounter = "emails/unread/"
        case customFolders = "emails/custom-folder/"
        case userMyself = "users/myself/"
        case contact = "users/contacts/"
        case createAttachment = "emails/attachments/create/"
        case deleteAttachment = "emails/attachments/"
    }
    
    enum JSONKey: String {
        case userName = "username"
        case password = "password"
        case privateKey = "private_key"
        case publicKey = "public_key"
        case fingerprint = "fingerprint"
        case recaptcha = "recaptcha"
        case recoveryEmail = "recovery_email"
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
        case sender = "sender"
        case mailbox = "mailbox"
        case send = "send"
        case subject = "subject"
        case email = "email"
        case address = "address"
        case note = "note"
        case phone = "phone"
        case encrypted = "is_encrypted"
        case encryption = "encryption"
        case messageID = "message"
        case fileData = "document"
        case inline = "is_inline"
        case attachments = "attachments"
    }
        
    func authenticateUser(userName: String, password: String, completionHandler: @escaping (APIResult<Any>) -> Void) {
        
        let headers: HTTPHeaders = [
            "Accept": "application/json"
        ]
        
        let parameters: Parameters = [
            JSONKey.userName.rawValue: userName,
            JSONKey.password.rawValue: password
        ]
        
        let url = EndPoint.baseUrl.rawValue + EndPoint.signIn.rawValue
        
        print("authenticateUser parameters:", parameters)
        print("authenticateUser url:", url)
        
        Alamofire.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers) /*.validate()*/ .responseJSON { (response: DataResponse<Any>) in
            
            print("authenticateUser responce:", response)
            
            switch(response.result) {
            case .success(let value):
                completionHandler(APIResult.success(value))                
            case .failure(let error):
                completionHandler(APIResult.failure(error))
            }
        }
    }
    
    func checkUser(name: String, completionHandler: @escaping (APIResult<Any>) -> Void) {
        
        let headers: HTTPHeaders = [
            "Accept": "application/json"
        ]
        
        let parameters: Parameters = [
            JSONKey.userName.rawValue: name
        ]
        
        let url = EndPoint.baseUrl.rawValue + EndPoint.checkUsername.rawValue
        
        print("checkUser parameters:", parameters)
        print("checkUser url:", url)
        
        Alamofire.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers) .responseJSON { (response: DataResponse<Any>) in
            
            print("checkUser responce:", response)
            
            switch(response.result) {
            case .success(let value):
                completionHandler(APIResult.success(value))
            case .failure(let error):
                completionHandler(APIResult.failure(error))
            }
        }
    }
    
    func signUp(userName: String, password: String, privateKey: String, publicKey: String, fingerprint: String, recaptcha: String, recoveryEmail: String,fromAddress: String, redeemCode: String, stripeToken: String, memory: String, emailCount: String, paymentType: String, completionHandler: @escaping (APIResult<Any>) -> Void) {
        
        let parameters: Parameters = [
            JSONKey.userName.rawValue: userName,
            JSONKey.password.rawValue: password,
            JSONKey.privateKey.rawValue: privateKey,
            JSONKey.publicKey.rawValue: publicKey,
            JSONKey.fingerprint.rawValue: fingerprint,
            JSONKey.recaptcha.rawValue: recaptcha,
            JSONKey.recoveryEmail.rawValue: recoveryEmail
        ]
        
        let url = EndPoint.baseUrl.rawValue + EndPoint.signUp.rawValue
        
        print("signUp parameters:", parameters)
        print("signUp url:", url)
        
        Alamofire.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil) /*.validate()*/ .responseJSON { (response: DataResponse<Any>) in
            
            print("signUp responce:", response)
            
            switch(response.result) {
            case .success(let value):
                completionHandler(APIResult.success(value))
            case .failure(let error):
                completionHandler(APIResult.failure(error))
            }
        }        
    }
    
    func recoveryPasswordCode(userName: String, recoveryEmail: String, completionHandler: @escaping (APIResult<Any>) -> Void) {
        
        let headers: HTTPHeaders = [
            "Accept": "application/json"
        ]
        
        let parameters: Parameters = [
            JSONKey.userName.rawValue: userName,
            JSONKey.recoveryEmail.rawValue: recoveryEmail
        ]
        
        let url = EndPoint.baseUrl.rawValue + EndPoint.recoveryCode.rawValue
        
        print("recoveryPasswordCode parameters:", parameters)
        print("recoveryPasswordCode url:", url)
        
        Alamofire.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers) /*.validate()*/ .responseJSON { (response: DataResponse<Any>) in
            
            print("recoveryPasswordCode responce:", response)
            
            switch(response.result) {
            case .success(let value):
                completionHandler(APIResult.success(value))
            case .failure(let error):
                completionHandler(APIResult.failure(error))
            }
        }
    }
    
    func resetPassword(resetPasswordCode: String, userName: String, password: String, privateKey: String, publicKey: String, fingerprint: String, recoveryEmail: String, completionHandler: @escaping (APIResult<Any>) -> Void) {
        
        let headers: HTTPHeaders = [
            "Accept": "application/json"
        ]
        
        let parameters: Parameters = [
            JSONKey.resetPasswordCode.rawValue: resetPasswordCode,
            JSONKey.userName.rawValue: userName,
            JSONKey.password.rawValue: password,
            JSONKey.privateKey.rawValue: privateKey,
            JSONKey.publicKey.rawValue: publicKey,
            JSONKey.fingerprint.rawValue: fingerprint,
            JSONKey.recoveryEmail.rawValue : recoveryEmail            
        ]
        
        let url = EndPoint.baseUrl.rawValue + EndPoint.recoveryCode.rawValue
        
        print("resetPassword parameters:", parameters)
        print("resetPassword url:", url)
        
        Alamofire.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers) /*.validate()*/ .responseJSON { (response: DataResponse<Any>) in
            
            print("resetPassword responce:", response)
            
            switch(response.result) {
            case .success(let value):
                completionHandler(APIResult.success(value))
            case .failure(let error):
                completionHandler(APIResult.failure(error))
            }
        }
    }
    
    func verifyToken(token: String, completionHandler: @escaping (APIResult<Any>) -> Void) {
        
        let headers: HTTPHeaders = [
            "Accept": "application/json"
        ]
        
        let parameters: Parameters = [
            JSONKey.token.rawValue: token
        ]
        
        let url = EndPoint.baseUrl.rawValue + EndPoint.verifyToken.rawValue
        
        //print("verifyToken parameters:", parameters)
        print("verifyToken url:", url)
        
        Alamofire.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers) .responseJSON { (response: DataResponse<Any>) in
            
            print("verifyToken responce:", response)
            
            switch(response.result) {
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
        
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers) /*.validate()*/ .responseJSON { (response: DataResponse<Any>) in
            
            //print("userMyself responce:", response)
            
            switch(response.result) {
            case .success(let value):
                completionHandler(APIResult.success(value))
            case .failure(let error):
                completionHandler(APIResult.failure(error))
            }
        }
    }
    
    //MARK: - Mail
    
    func messagesList(token: String, folder: String, messagesIDIn: String, seconds: Int, completionHandler: @escaping (APIResult<Any>) -> Void) {
        
        let headers: HTTPHeaders = [
            "Authorization": "JWT " + token,
            "Accept": "application/json"
        ]
        
         //let parameters: Parameters = [
         //   JSONKey.filter.rawValue: "inbox"
         //]
        
        var timeParameter = ""
        
        if seconds > 0 {
            timeParameter = "&seconds=" + seconds.description
        }
        
        let url = EndPoint.baseUrl.rawValue + EndPoint.messages.rawValue + folder + messagesIDIn + timeParameter//"?starred=1"// "?read=0"
        //let url = EndPoint.baseUrl.rawValue + EndPoint.messages.rawValue + "?seconds=" + seconds
        //let url = "https://devapi.ctemplar.com/emails/messages/?limit=20&offset=0&folder=inbox&read=false&seconds=30"
        
        //print("messagesList parameters:", parameters)
        print("messagesList url:", url)
        
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers) /*.validate()*/ .responseJSON { (response: DataResponse<Any>) in
            
            //print("messagesList responce:", response)
            
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
        
        Alamofire.request(url, method: .patch, parameters: parameters, encoding: JSONEncoding.default, headers: headers) /*.validate()*/ .responseJSON { (response: DataResponse<Any>) in
            
            print("updateMessages responce:", response)
            
            switch(response.result) {
            case .success(let value):
                completionHandler(APIResult.success(value))
            case .failure(let error):
                completionHandler(APIResult.failure(error))
            }
        }
    }
    
    func mailboxesList(token: String, completionHandler: @escaping (APIResult<Any>) -> Void) {
        
        let headers: HTTPHeaders = [
            "Authorization": "JWT " + token,
            "Accept": "application/json"
        ]
        
        let url = EndPoint.baseUrl.rawValue + EndPoint.mailboxes.rawValue
     
        print("mailboxes url:", url)
        
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers) /*.validate()*/ .responseJSON { (response: DataResponse<Any>) in
            
            print("mailboxes responce:", response)
            
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
        
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers) /*.validate()*/ .responseJSON { (response: DataResponse<Any>) in
            
            print("unreadMessagesCounter responce:", response)
            
            switch(response.result) {
            case .success(let value):
                completionHandler(APIResult.success(value))
            case .failure(let error):
                completionHandler(APIResult.failure(error))
            }
        }
    }
    
    func createMessage(token: String, content: String, subject: String, recieversList: Array<String>, folder: String, mailboxID: Int, send: Bool, encrypted: Bool, encryptionObject: [String : String], completionHandler: @escaping (APIResult<Any>) -> Void) {
    
        let headers: HTTPHeaders = [
            "Authorization": "JWT " + token,
            "Accept": "application/json"
        ]
        
        let parameters: Parameters = [
            JSONKey.content.rawValue: content,
            JSONKey.subject.rawValue: subject,
            JSONKey.receiver.rawValue: recieversList,
            JSONKey.folder.rawValue: folder,
            JSONKey.mailbox.rawValue: mailboxID,
            JSONKey.send.rawValue: send,
            JSONKey.encrypted.rawValue : encrypted,
            JSONKey.encryption.rawValue : encryptionObject
        ]
        
        let url = EndPoint.baseUrl.rawValue + EndPoint.messages.rawValue
        
        print("createMessage url:", url)
        print("createMessage parameters:", parameters)
        
        Alamofire.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers) .responseJSON { (response: DataResponse<Any>) in
            
            print("createMessage responce:", response)
            
            switch(response.result) {
            case .success(let value):
                completionHandler(APIResult.success(value))
            case .failure(let error):
                completionHandler(APIResult.failure(error))
            }
        }
    }
    
    func updateSendingMessage(token: String, messageID: String, encryptedMessage: String, subject: String, recieversList: Array<String>, folder: String, send: Bool, encryptionObject: [String : String], encrypted: Bool, attachments: Array<[String : String]>, completionHandler: @escaping (APIResult<Any>) -> Void) {
        
        let headers: HTTPHeaders = [
            "Authorization": "JWT " + token,
            "Accept": "application/json"
        ]
        
        let parameters: Parameters = [
            JSONKey.content.rawValue : encryptedMessage,
            JSONKey.folder.rawValue: folder,
            JSONKey.subject.rawValue: subject,
            JSONKey.receiver.rawValue: recieversList,
            JSONKey.send.rawValue: send,
            JSONKey.encryption.rawValue : encryptionObject,
            JSONKey.encrypted.rawValue : encrypted,
            JSONKey.attachments.rawValue : attachments
        ]
        
        let url = EndPoint.baseUrl.rawValue + EndPoint.messages.rawValue + messageID + "/"
        
        print("updateSendingMessage parameters:", parameters)
        print("updateSendingMessage url:", url)
        
        Alamofire.request(url, method: .patch, parameters: parameters, encoding: JSONEncoding.default, headers: headers) .responseJSON { (response: DataResponse<Any>) in
            
            print("updateSendingMessage responce:", response)
            
            switch(response.result) {
            case .success(let value):
                completionHandler(APIResult.success(value))
            case .failure(let error):
                completionHandler(APIResult.failure(error))
            }
        }
    }
    
    func updateAttachmentsForMessage(token: String, messageID: String, folder: String, attachments: Array<[String : String]>, completionHandler: @escaping (APIResult<Any>) -> Void) {
        
        let headers: HTTPHeaders = [
            "Authorization": "JWT " + token,
            "Accept": "application/json"
        ]
        
        let parameters: Parameters = [
            
            JSONKey.folder.rawValue: folder,
            JSONKey.attachments.rawValue : attachments
        ]
        
        let url = EndPoint.baseUrl.rawValue + EndPoint.messages.rawValue + messageID + "/"
        
        print("updateAttachmentsForMessage parameters:", parameters)
        print("updateAttachmentsForMessage url:", url)
        
        Alamofire.request(url, method: .patch, parameters: parameters, encoding: JSONEncoding.default, headers: headers) .responseJSON { (response: DataResponse<Any>) in
            
            print("updateAttachmentsForMessage responce:", response)
            
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
        
        Alamofire.request(url, method: .delete, parameters: nil, encoding: JSONEncoding.default, headers: headers) .responseJSON { (response: DataResponse<Any>) in
            
            print("deleteMessages responce:", response)
            
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
        
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers) .responseJSON { (response: DataResponse<Any>) in
            
            print("publicKeyList responce:", response)
            
            switch(response.result) {
            case .success(let value):
                completionHandler(APIResult.success(value))
            case .failure(let error):
                completionHandler(APIResult.failure(error))
            }
        }
    }
    
    func publicKeyFor(userEmail: String, token: String, completionHandler: @escaping (APIResult<Any>) -> Void) {
        
        let headers: HTTPHeaders = [
            "Authorization": "JWT " + token,
            "Accept": "application/json"
        ]
        
        let url = EndPoint.baseUrl.rawValue + EndPoint.publicKeys.rawValue + "?email__in=" + userEmail
        
        print("publicKeyFor url:", url)
        
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers) .responseJSON { (response: DataResponse<Any>) in
            
            print("publicKeyFor responce:", response)
            
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
        
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers) /*.validate()*/ .responseJSON { (response: DataResponse<Any>) in
            
            print("customFolders responce:", response)
            
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
        
        Alamofire.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers) /*.validate()*/ .responseJSON { (response: DataResponse<Any>) in
            
            print("createCustomFolder responce:", response)
            
            switch(response.result) {
            case .success(let value):
                completionHandler(APIResult.success(value))
            case .failure(let error):
                completionHandler(APIResult.failure(error))
            }
        }
    }
    
    //MARK: - Contacts
    
    func userContacts(token: String, contactsIDIn: String, completionHandler: @escaping (APIResult<Any>) -> Void) {
        
        let headers: HTTPHeaders = [
            "Authorization": "JWT " + token,
            "Accept": "application/json"
        ]
        
        let url = EndPoint.baseUrl.rawValue + EndPoint.contact.rawValue + contactsIDIn
        
        print("userContacts url:", url)
        
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers) .responseJSON { (response: DataResponse<Any>) in
            
            print("userContacts responce:", response)
            
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
        
        Alamofire.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers) .responseJSON { (response: DataResponse<Any>) in
            
            print("createContact responce:", response)
            
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
            JSONKey.note.rawValue: note
        ]
        
        print("updateContact parameters:", parameters)
        
        let url = EndPoint.baseUrl.rawValue + EndPoint.contact.rawValue + contactID + "/"
        
        print("updateContact url:", url)
        
        Alamofire.request(url, method: .patch, parameters: parameters, encoding: JSONEncoding.default, headers: headers) .responseJSON { (response: DataResponse<Any>) in
            
            print("updateContact responce:", response)
            
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
        
        Alamofire.request(url, method: .delete, parameters: nil, encoding: JSONEncoding.default, headers: headers) .responseJSON { (response: DataResponse<Any>) in
            
            print("deleteContact responce:", response)
            
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
        
        Alamofire.download(url, to: destination).downloadProgress(queue: DispatchQueue.global(qos: .utility)) { (progress) in
            print("Progress: \(progress.fractionCompleted)")
            } /*.validate()*/.responseData { ( response ) in
                print(response.destinationURL!)
                completionHandler(APIResult.success(response.destinationURL!/*.lastPathComponent*/))
        }
    }
    
    //MARK: - Attachments
    
    func createAttachment(token: String, file: Data, fileName: String, mimeType: String, messageID: String, completionHandler: @escaping (APIResult<Any>) -> Void) {
        
        let headers: HTTPHeaders = [
            "Authorization": "JWT " + token,
            "Accept": "application/json"
        ]
        
        let parameters: Parameters = [
            JSONKey.messageID.rawValue: messageID,
            //JSONKey.fileData.rawValue: file,
            JSONKey.inline.rawValue: false
        ]
        
        print("createAttachment parameters:", parameters)
        
        let url = EndPoint.baseUrl.rawValue + EndPoint.createAttachment.rawValue
        
        print("createAttachment url:", url)
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            
            for param in parameters {
                if let value = param.value as? String {
                    multipartFormData.append(value.data(using: .utf8)!, withName: param.key)
                }
            }
            
            multipartFormData.append(file, withName: JSONKey.fileData.rawValue, fileName: fileName, mimeType: mimeType) //"image/jpg"
            
        }, to: url, method: .post , headers: headers, encodingCompletion: { (result) in
            
            print("upload Data result:", result)
            
            switch result {
            case .success(let upload, _, _):
                
                upload.uploadProgress(closure: { (progress) in
                    print("upload Data", progress.fractionCompleted * 100)
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: k_attachUploadUpdateNotificationID), object: progress.fractionCompleted)
                })
                
                upload.responseJSON(completionHandler: { (response) in
                   
                    switch(response.result) {
                    case .success(let value):
                        completionHandler(APIResult.success(value))
                    case .failure(let error):
                        completionHandler(APIResult.failure(error))
                    }
                })
                
            case .failure(let error):
                print("upload Data error:", error)
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
        
        Alamofire.request(url, method: .delete, parameters: nil, encoding: JSONEncoding.default, headers: headers) .responseJSON { (response: DataResponse<Any>) in
            
            print("deleteAttachment responce:", response)
            
            switch(response.result) {
            case .success(let value):
                completionHandler(APIResult.success(value))
            case .failure(let error):
                completionHandler(APIResult.failure(error))
            }
        }
    }
}
