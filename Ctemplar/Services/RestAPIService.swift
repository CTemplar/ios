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
    
    func signUp(userName: String, password: String, privateKey: String, publicKey: String, fingerprint: String, recaptcha: String, recoveryEmail: String,fromAddress: String, redeemCode: String, stripeToken: String, memory: String, emailCount: String, paymentType: String, completionHandler: @escaping (APIResult<Any>) -> Void) {
        
        let parameters: Parameters = [
            JSONKey.userName.rawValue: userName,
            JSONKey.password.rawValue: password,
            JSONKey.privateKey.rawValue: privateKey,
            JSONKey.publicKey.rawValue: publicKey,
            //JSONKey.fingerprint.rawValue: fingerprint,
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
}
