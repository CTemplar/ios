//
//  RouterUser.swift
//  CTemplar
//
//  Created by Roman K. on 12/6/19.
//  Copyright © 2019 CTemplar. All rights reserved.
//

import Alamofire
import Foundation

public enum RouterUser: BaseRouter {
    case myself

    public static let group = "/users/"

    public var method: HTTPMethod {
        switch self {
        default:
            return .get
        }
    }

    public var path: String {
        switch self {
        case .myself:
            return RouterUser.group + "myself/"
        }
    }
    
    public var usesToken: Bool {
        return true
    }

    public func encoded(_ request: URLRequest) throws -> URLRequest {
        switch self {
        case .myself:
            return try JSONEncoding.default.encode(request, with: nil)
        }
    }
}
