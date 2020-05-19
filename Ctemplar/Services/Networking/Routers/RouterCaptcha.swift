//
//  RouterCaptcha.swift
//  Ctemplar
//
//  Created by Roman K. on 12/6/19.
//  Copyright © 2019 CTemplar. All rights reserved.
//

import Alamofire
import Foundation

enum RouterCaptcha: BaseRouter {
    case verify(value: String, key: String)
    case get

    static let group = "/auth/"

    var method: HTTPMethod {
        switch self {
        case .get:
            return .get
        default:
            return .post
        }
    }

    var path: String {
        switch self {
        case .get:
            return RouterCaptcha.group + "captcha"
        case .verify:
            return RouterCaptcha.group + "captcha-verify/"
        }
    }
    
    var usesToken: Bool {
        return false
    }

    func encoded(_ request: URLRequest) throws -> URLRequest {
        switch self {
        case .get:
            return try JSONEncoding.default.encode(request, with: nil)
        case .verify(let value, let key):
            return try JSONEncoding.default.encode(request, with: [JSONKey.captchaValue.rawValue: value,
                                                                   JSONKey.captchaKey.rawValue: key])
        }
    }
}
