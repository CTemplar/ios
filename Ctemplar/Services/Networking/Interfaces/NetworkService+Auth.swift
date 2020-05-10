//
//  NetworkService+Auth.swift
//  Ctemplar
//
//  Created by Roman K. on 12/6/19.
//  Copyright © 2019 CTemplar. All rights reserved.
//

import Alamofire
import Foundation

struct LoginDetails {
    var userName: String
    var password: String
    var twoFAcode: String?
}

struct SignupDetails {
    var userName: String
    var password: String
    var privateKey: String
    var publicKey: String
    var fingerprint: String
    var captchaKey: String
    var captchaValue: String
    var recoveryEmail: String
    var fromAddress: String
    var redeemCode: String
    var stripeToken: String
    var memory: String
    var emailCount: String
    var paymentType: String
}

struct ResetPasswordDetails {
    var resetPasswordCode: String
    var userName: String
    var password: String
    var privateKey: String
    var publicKey: String
    var fingerprint: String
    var recoveryEmail: String
}

struct ChangePasswordDetails {
    var username: String
    var oldHashedPassword: String
    var newHashedPassword: String
    var newKeys: [[String : Any]]
    var deleteData: Bool
}

protocol AuthService {
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
    func loginUser(with details: LoginDetails,
                   completionHandler: @escaping Completion<LoginResult>) {
        perform(request: RouterAuth.login(details: details),
                completionHandler: completionHandler)
    }
    func checkUser(name: String,
                   completionHandler: @escaping Completion<CheckUserResult>) {
        perform(request: RouterAuth.check(userName: name),
                completionHandler: completionHandler)
    }
    func signUp(with details: SignupDetails,
                completionHandler: @escaping Completion<TokenResult>) {
        perform(request: RouterAuth.signup(details: details),
                completionHandler: completionHandler)
    }
    func recoveryPasswordCode(for userName: String, recoveryEmail: String, completionHandler: @escaping Completion<Void>) {
        perform(request: RouterAuth.recoveryPasswordCode(userName: userName, recoveryEmail: recoveryEmail),
                completionHandler: completionHandler)
    }
    func resetPassword(with details: ResetPasswordDetails,
                       completionHandler: @escaping Completion<TokenResult>) {
        perform(request: RouterAuth.resetPassword(details: details),
                completionHandler: completionHandler)
    }
    
    func changePassword(with details: ChangePasswordDetails,
                        completionHandler: @escaping Completion<Void>) {
        perform(request: RouterAuth.changePassword(details: details),
                     completionHandler: completionHandler)
    }
}
