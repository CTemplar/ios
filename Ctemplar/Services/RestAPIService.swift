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
        case messages = "emails/messages/"
        case mailboxes = "emails/mailboxes/"
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
            JSONKey.recaptcha.rawValue: recaptcha
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
    
    //MARK: - Mail
    
    func messagesList(token: String, completionHandler: @escaping (APIResult<Any>) -> Void) {
        
        let headers: HTTPHeaders = [
            "Authorization": "JWT " + token,
            "Accept": "application/json"
        ]
        /*
         let parameters: Parameters = [
         JSONKey.userName.rawValue: userName,
         JSONKey.password.rawValue: password
         ]*/
        
        let url = EndPoint.baseUrl.rawValue + EndPoint.messages.rawValue
        
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
    
    func mailboxesList(token: String, completionHandler: @escaping (APIResult<Any>) -> Void) {
        
        let headers: HTTPHeaders = [
            "Authorization": "JWT " + token,
            "Accept": "application/json"
        ]
        
        let url = EndPoint.baseUrl.rawValue + EndPoint.mailboxes.rawValue
     
        print("mailboxes url:", url)
        
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers) /*.validate()*/ .responseJSON { (response: DataResponse<Any>) in
            
            //print("mailboxes responce:", response)
            
            switch(response.result) {
            case .success(let value):
                completionHandler(APIResult.success(value))
            case .failure(let error):
                completionHandler(APIResult.failure(error))
            }
        }
    }
}
