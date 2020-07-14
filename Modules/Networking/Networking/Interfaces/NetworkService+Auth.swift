//
//  NetworkService+Auth.swift
//  Ctemplar
//
//  Created by Roman K. on 12/6/19.
//  Copyright © 2019 CTemplar. All rights reserved.
//

import Alamofire
import Foundation
import Utility

public struct LoginDetails {
    public var userName: String
    public var password: String
    public var twoFACode: String
    
    public init() {
        userName = ""
        password = ""
        twoFACode = ""
    }
    
    public init(userName: String, password: String, twoFACode: String) {
        self.userName = userName
        self.password = password
        self.twoFACode = twoFACode
    }
}

public struct SignupDetails {
    public var userName: String
    public var password: String
    public var privateKey: String
    public var publicKey: String
    public var fingerprint: String
    public var captchaKey: String
    public var captchaValue: String
    public var recoveryEmail: String
    public var fromAddress: String
    public var redeemCode: String
    public var inviteCode: String
    public var stripeToken: String
    public var memory: String
    public var emailCount: String
    public var paymentType: String
    public var language: String
    
    public init(userName: String, password: String, privateKey: String, publicKey: String, fingerprint: String, language: String, captchaKey: String = "", captchaValue: String = "", recoveryEmail: String = "", fromAddress: String = "", redeemCode: String = "", inviteCode: String = "", stripeToken: String = "", memory: String = "", emailCount: String = "", paymentType: String = "") {
        self.userName = userName
        self.password = password
        self.privateKey = privateKey
        self.publicKey = publicKey
        self.fingerprint = fingerprint
        self.captchaKey = captchaKey
        self.captchaValue = captchaValue
        self.recoveryEmail = recoveryEmail
        self.fromAddress = fromAddress
        self.redeemCode = redeemCode
        self.inviteCode = inviteCode
        self.stripeToken = stripeToken
        self.memory = memory
        self.emailCount = emailCount
        self.paymentType = paymentType
        self.language = language
    }
}

public struct ResetPasswordDetails {
    public var resetPasswordCode: String
    public var userName: String
    public var password: String
    public var privateKey: String
    public var publicKey: String
    public var fingerprint: String
    public var recoveryEmail: String
    
    public init(resetPasswordCode: String, userName: String, password: String, privateKey: String, publicKey: String, fingerprint: String, recoveryEmail: String) {
        self.resetPasswordCode = resetPasswordCode
        self.userName = userName
        self.password = password
        self.privateKey = privateKey
        self.publicKey = publicKey
        self.fingerprint = fingerprint
        self.recoveryEmail = recoveryEmail
    }
}

public struct ChangePasswordDetails {
    public var username: String
    public var oldHashedPassword: String
    public var newHashedPassword: String
    public var newKeys: [[String : Any]]
    public var deleteData: Bool
    
    public init(username: String, oldHashedPassword: String, newHashedPassword: String, newKeys: [[String : Any]], deleteData: Bool) {
        self.username = username
        self.oldHashedPassword = oldHashedPassword
        self.newHashedPassword = newHashedPassword
        self.newKeys = newKeys
        self.deleteData = deleteData
    }
}

public protocol AuthService {
    func loginUser(with details: LoginDetails,
                   completionHandler: @escaping Completion<LoginResult>)
    func checkUser(name: String,
                   completionHandler: @escaping Completion<CheckUserResult>)
    func signUp(with details: SignupDetails,
                completionHandler: @escaping Completion<TokenResult>)
    func recoveryPasswordCode(for userName: String, recoveryEmail: String, completionHandler: @escaping Completion<Void>)
    func resetPassword(with details: ResetPasswordDetails,
                       completionHandler: @escaping Completion<TokenResult>)
    func changePassword(with details: ChangePasswordDetails,
                        completionHandler: @escaping Completion<Void>)
}

extension NetworkService: AuthService {
    public func loginUser(with details: LoginDetails,
                   completionHandler: @escaping Completion<LoginResult>) {
        perform(request: RouterAuth.login(details: details),
                shouldRefreshToken: false,
                completionHandler: completionHandler)
    }
    
    public func checkUser(name: String,
                   completionHandler: @escaping Completion<CheckUserResult>) {
        perform(request: RouterAuth.check(userName: name),
                completionHandler: completionHandler)
    }
    
    public func signUp(with details: SignupDetails,
                completionHandler: @escaping Completion<TokenResult>) {
        perform(request: RouterAuth.signup(details: details),
                completionHandler: completionHandler)
    }
    
    public func recoveryPasswordCode(for userName: String, recoveryEmail: String, completionHandler: @escaping Completion<Void>) {
        perform(request: RouterAuth.recoveryPasswordCode(userName: userName, recoveryEmail: recoveryEmail),
                completionHandler: completionHandler)
    }
    
    public func resetPassword(with details: ResetPasswordDetails,
                       completionHandler: @escaping Completion<TokenResult>) {
        perform(request: RouterAuth.resetPassword(details: details),
                completionHandler: completionHandler)
    }
    
    public func changePassword(with details: ChangePasswordDetails,
                        completionHandler: @escaping Completion<Void>) {
        perform(request: RouterAuth.changePassword(details: details),
                     completionHandler: completionHandler)
    }
}
