//
//  RouterAuth.swift
//  Ctemplar
//
//  Created by Roman K. on 12/6/19.
//  Copyright © 2019 CTemplar. All rights reserved.
//

import Alamofire
import Foundation

public enum RouterAuth: BaseRouter {
    case login(details: LoginDetails)
    case signup(details: SignupDetails)
    case check(userName: String)
    case recoveryPasswordCode(userName: String, recoveryEmail: String)
    case resetPassword(details: ResetPasswordDetails)
    case changePassword(details: ChangePasswordDetails)

    public static let group = "/auth/"

    public var method: HTTPMethod {
        switch self {
        default:
            return .post
        }
    }

    public var path: String {
        switch self {
        case .login:
            return RouterAuth.group + "sign-in/"
        case .signup:
            return RouterAuth.group + "sign-up/"
        case .check:
            return RouterAuth.group + "check-username/"
        case .recoveryPasswordCode:
            return RouterAuth.group + "recover/"
        case .resetPassword:
            return RouterAuth.group + "reset/"
        case .changePassword:
            return RouterAuth.group + "change-password/"
        }
    }
    
    public var usesToken: Bool {
        switch self {
        case .changePassword:
            return true
        default:
            return false
        }
    }

    public func encoded(_ request: URLRequest) throws -> URLRequest {
        switch self {
        case .login(let details):
            let params: [String: Any] = [
                JSONKey.userName.rawValue: details.userName,
                JSONKey.password.rawValue: details.password,
            ]
//            if let code = details.twoFAcode, !code.isEmpty {
//                params[JSONKey.otp.rawValue] = code
//            }
            return try JSONEncoding.default.encode(request, with: params)
        case .signup(let details):
            let params: [String: Any] = [
                JSONKey.userName.rawValue: details.userName,
                JSONKey.password.rawValue: details.password,
                JSONKey.privateKey.rawValue: details.privateKey,
                JSONKey.publicKey.rawValue: details.publicKey,
                JSONKey.fingerprint.rawValue: details.fingerprint,
                JSONKey.recoveryEmail.rawValue: details.recoveryEmail,
                JSONKey.inviteCode.rawValue: details.inviteCode,
                JSONKey.language.rawValue: details.language
            ]
            return try JSONEncoding.default.encode(request, with: params)
        case .check(let username):
            return try JSONEncoding.default.encode(request, with: [JSONKey.userName.rawValue: username])
        case .recoveryPasswordCode(let username, let recoveryEmail):
            return try JSONEncoding.default.encode(request, with: [JSONKey.userName.rawValue: username,
                                                                   JSONKey.recoveryEmail.rawValue: recoveryEmail])
        case .resetPassword(let details):
            let params: [String: Any] = [
                JSONKey.resetPasswordCode.rawValue: details.resetPasswordCode,
                JSONKey.userName.rawValue: details.userName,
                JSONKey.password.rawValue: details.password,
                JSONKey.privateKey.rawValue: details.privateKey,
                JSONKey.publicKey.rawValue: details.publicKey,
                JSONKey.fingerprint.rawValue: details.fingerprint,
                JSONKey.recoveryEmail.rawValue : details.recoveryEmail
            ]
            return try JSONEncoding.default.encode(request, with: params)
        case .changePassword(let details):
            let params: [String: Any] = [
                JSONKey.oldPassword.rawValue: details.oldHashedPassword,
                JSONKey.password.rawValue: details.newHashedPassword,
                JSONKey.confirmPassword.rawValue: details.newHashedPassword,
                JSONKey.deleteData.rawValue: details.deleteData,
                JSONKey.newKeys.rawValue: details.newKeys
            ]
            return try JSONEncoding.default.encode(request, with: params)
        }
    }
}
