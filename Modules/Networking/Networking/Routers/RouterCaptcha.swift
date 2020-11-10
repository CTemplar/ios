//
//  RouterCaptcha.swift
//  CTemplar
//
//  Created by Roman K. on 12/6/19.
//  Copyright © 2019 CTemplar. All rights reserved.
//

import Alamofire
import Foundation

public enum RouterCaptcha: BaseRouter {
    case verify(value: String, key: String)
    case get

    public static let group = "/auth/"

    public var method: HTTPMethod {
        switch self {
        case .get:
            return .get
        default:
            return .post
        }
    }

    public var path: String {
        switch self {
        case .get:
            return RouterCaptcha.group + "captcha"
        case .verify:
            return RouterCaptcha.group + "captcha-verify/"
        }
    }
    
    public var usesToken: Bool {
        return false
    }

    public func encoded(_ request: URLRequest) throws -> URLRequest {
        switch self {
        case .get:
            return try JSONEncoding.default.encode(request, with: nil)
        case .verify(let value, let key):
            return try JSONEncoding.default.encode(request, with: [JSONKey.captchaValue.rawValue: value,
                                                                   JSONKey.captchaKey.rawValue: key])
        }
    }
}
