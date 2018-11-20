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
        case unreadCounter = "emails/unread/"
        case customFolders = "emails/custom-folder/"
        case userMyself = "users/myself/"
        case contact = "users/contacts/"
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
            
            print("messagesList responce:", response)
            
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
    
    func createMessage(token: String, content: String, subject: String, recieversList: Array<String>, folder: String, mailboxID: Int, send: Bool, completionHandler: @escaping (APIResult<Any>) -> Void) {
    
        let headers: HTTPHeaders = [
            "Authorization": "JWT " + token,
            "Accept": "application/json"
        ]
        
        let parameters: Parameters = [
            JSONKey.content.rawValue: content,
            JSONKey.subject.rawValue: subject,
            JSONKey.receiver.rawValue: recieversList,
            //JSONKey.sender.rawValue: "dmitry5@dev.ctemplar.com",
            JSONKey.folder.rawValue: folder,
            JSONKey.mailbox.rawValue: mailboxID,
            JSONKey.send.rawValue: send
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
            
            //print("userContacts responce:", response)
            
            switch(response.result) {
            case .success(let value):
                completionHandler(APIResult.success(value))
            case .failure(let error):
                completionHandler(APIResult.failure(error))
            }
        }
    }
    
    func createContacts(token: String, name: String, email: String, phone: String, address: String, note: String, completionHandler: @escaping (APIResult<Any>) -> Void) {
        
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
        
        print("createContacts parameters:", parameters)
        
        let url = EndPoint.baseUrl.rawValue + EndPoint.contact.rawValue
        
        print("createContacts url:", url)
        
        Alamofire.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers) .responseJSON { (response: DataResponse<Any>) in
            
            print("createContacts responce:", response)
            
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
}
