//
//  NetworkService+Places.swift
//  Ctemplar
//
//  Created by Roman K. on 12/6/19.
//  Copyright © 2019 ComeOnSoftware. All rights reserved.
//

import Alamofire
import Foundation

struct LoginDetails {
    let userName: String
    let password: String
    let twoFAcode: String?
}

struct SignupDetails {
    let userName: String
    let password: String
    let privateKey: String
    let publicKey: String
    let fingerprint: String
    let captchaKey: String
    let captchaValue: String
    let recoveryEmail: String
    let fromAddress: String
    let redeemCode: String
    let stripeToken: String
    let memory: String
    let emailCount: String
    let paymentType: String
}

struct ResetPasswordDetails {
    let resetPasswordCode: String
    let userName: String
    let password: String
    let privateKey: String
    let publicKey: String
    let fingerprint: String
    let recoveryEmail: String
}

struct ChangePasswordDetails {
    let token: String
    let oldPassword: String
    let newPassword: String
    let newKeys: [[String : Any]]
    let deleteData: Bool
}

protocol AuthService {
    func loginUser(with details: LoginDetails,
                   completionHandler: @escaping Completion<Void>)
    func checkUser(name: String,
                   completionHandler: @escaping Completion<Void>)
    func signUp(with details: SignupDetails,
                completionHandler: @escaping Completion<Void>)
    func recoveryPasswordCode(for userName: String, recoveryEmail: String, completionHandler: @escaping Completion<Void>)
    func resetPassword(with details: ResetPasswordDetails,
                       completionHandler: @escaping Completion<Void>)
    func changePassword(with details: ChangePasswordDetails,
                        completionHandler: @escaping Completion<Void>)
    func verifyToken(token: String, completionHandler: @escaping Completion<Void>)
    func refreshToken(token: String, completionHandler: @escaping Completion<Void>)
}

extension NetworkService: AuthService {
    func loginUser(with details: LoginDetails,
                   completionHandler: @escaping Completion<Void>) {
        perform(request: RouterAuth.login(details: details),
                completionHandler: completionHandler)
    }
    func checkUser(name: String,
                   completionHandler: @escaping Completion<Void>) {
        perform(request: RouterAuth.check(userName: name),
                completionHandler: completionHandler)
    }
    func signUp(with details: SignupDetails,
                completionHandler: @escaping Completion<Void>) {
        perform(request: RouterAuth.signup(details: details),
                completionHandler: completionHandler)
    }
    func recoveryPasswordCode(for userName: String, recoveryEmail: String, completionHandler: @escaping Completion<Void>) {
        perform(request: RouterAuth.recoveryPasswordCode(userName: userName, recoveryEmail: recoveryEmail),
                completionHandler: completionHandler)
    }
    func resetPassword(with details: ResetPasswordDetails,
                       completionHandler: @escaping Completion<Void>) {
        perform(request: RouterAuth.resetPassword(details: details),
                completionHandler: completionHandler)
    }
    
    func changePassword(with details: ChangePasswordDetails,
                        completionHandler: @escaping Completion<Void>) {
        perform(request: RouterAuth.changePassword(details: details),
                completionHandler: completionHandler)
    }
    
    func verifyToken(token: String, completionHandler: @escaping Completion<Void>) {
        perform(request: RouterAuth.verifyToken(token: token),
                completionHandler: completionHandler)
    }
    
    func refreshToken(token: String, completionHandler: @escaping Completion<Void>) {
        perform(request: RouterAuth.refreshToken(token: token),
                completionHandler: completionHandler)
    }
}
