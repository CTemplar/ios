//
//  RouterAuth.swift
//  Ctemplar
//
//  Created by Roman K. on 12/6/19.
//  Copyright © 2019 ComeOnSoftware. All rights reserved.
//

import Alamofire
import Foundation

enum RouterAuth: BaseRouter {
    case auth(userName: String, password: String, twoFAcode: String?)
    case check(userName: String)

    static let group = "/auth/"

    var method: HTTPMethod {
        switch self {
        case .auth, .check:
            return .post
        }
    }

    var path: String {
        switch self {
        case .auth:
            return RouterAuth.group + "sign-in/"
        case .check:
            return RouterAuth.group + "check-username/"
        }
    }

    func encoded(_ request: URLRequest) throws -> URLRequest {
        switch self {
        case .auth(let username, let password, let code):
            var params: [String: Any] = [
                JSONKey.userName.rawValue: username,
                JSONKey.password.rawValue: password
            ]
            if let code = code {
                params[JSONKey.otp.rawValue] = code
            }
            return try JSONEncoding.default.encode(request, with: params)
        case .check(let username):
            return try JSONEncoding.default.encode(request, with: [JSONKey.userName.rawValue: username])
//        default:
//            return try URLEncoding.default.encode(request, with: [:])
        }
    }
}
