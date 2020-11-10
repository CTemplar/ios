//
//  RouterToken.swift
//  CTemplar
//
//  Created by Roman K. on 12/6/19.
//  Copyright © 2019 CTemplar. All rights reserved.
//

import Alamofire
import Foundation

public enum RouterToken: BaseRouter {
    case verify(value: String)
    case refresh(value: String)

    public static let group = "/auth/"

    public var method: HTTPMethod {
        switch self {
        default:
            return .post
        }
    }

    public var path: String {
        switch self {
        case .verify:
            return RouterToken.group + "verify/"
        case .refresh:
            return RouterToken.group + "refresh/"
        }
    }
    
    public var usesToken: Bool {
        return false
    }

    public func encoded(_ request: URLRequest) throws -> URLRequest {
        switch self {
        case .verify(let value):
            return try JSONEncoding.default.encode(request, with: [JSONKey.token.rawValue: value])
        case .refresh(let value):
            return try JSONEncoding.default.encode(request, with: [JSONKey.token.rawValue: value])
        }
    }
}
