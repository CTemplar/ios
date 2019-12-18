//
//  RouterUser.swift
//  Ctemplar
//
//  Created by Roman K. on 12/6/19.
//  Copyright © 2019 ComeOnSoftware. All rights reserved.
//

import Alamofire
import Foundation

enum RouterUser: BaseRouter {
    case myself

    static let group = "/users/"

    var method: HTTPMethod {
        switch self {
        default:
            return .get
        }
    }

    var path: String {
        switch self {
        case .myself:
            return RouterUser.group + "myself/"
        }
    }
    
    var usesToken: Bool {
        return true
    }

    func encoded(_ request: URLRequest) throws -> URLRequest {
        switch self {
        case .myself:
            return try JSONEncoding.default.encode(request, with: nil)
        }
    }
}
