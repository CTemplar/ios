//
//  RouterToken.swift
//  Ctemplar
//
//  Created by Roman K. on 12/6/19.
//  Copyright © 2019 ComeOnSoftware. All rights reserved.
//

import Alamofire
import Foundation

enum RouterToken: BaseRouter {
    case verify(value: String)
    case refresh(value: String)

    static let group = "/auth/"

    var method: HTTPMethod {
        switch self {
        default:
            return .post
        }
    }

    var path: String {
        switch self {
        case .verify:
            return RouterToken.group + "verify/"
        case .refresh:
            return RouterToken.group + "refresh/"
        }
    }
    
    var usesToken: Bool {
        return false
    }

    func encoded(_ request: URLRequest) throws -> URLRequest {
        switch self {
        case .verify(let value):
            return try JSONEncoding.default.encode(request, with: [JSONKey.token.rawValue: value])
        case .refresh(let value):
            return try JSONEncoding.default.encode(request, with: [JSONKey.token.rawValue: value])
        }
    }
}
