//
//  RouterAuth.swift
//  Ctemplar
//
//  Created by Roman K. on 12/6/19.
//  Copyright © 2019 ComeOnSoftware. All rights reserved.
//

import Alamofire
import Foundation

enum RouterToken: BaseRouter {
    case verifyToken(token: String)
    case refreshToken(token: String)

    static let group = "/auth/"

    var method: HTTPMethod {
        switch self {
        default:
            return .post
        }
    }

    var path: String {
        switch self {
        case .verifyToken:
            return RouterAuth.group + "verify/"
        case .refreshToken:
            return RouterAuth.group + "refresh/"
        }
    }
    
    var usesToken: Bool {
        return false
    }

    func encoded(_ request: URLRequest) throws -> URLRequest {
        switch self {
        case .verifyToken(let token):
            return try JSONEncoding.default.encode(request, with: [JSONKey.token.rawValue: token])
        case .refreshToken(let token):
            return try JSONEncoding.default.encode(request, with: [JSONKey.token.rawValue: token])
        }
    }
}
