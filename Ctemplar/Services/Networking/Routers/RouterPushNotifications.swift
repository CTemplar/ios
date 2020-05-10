//
//  RouterPushNotifications.swift
//  Ctemplar
//
//  Created by Roman K. on 12/6/19.
//  Copyright © 2019 CTemplar. All rights reserved.
//

import Alamofire
import Foundation

enum RouterPushNotifications: BaseRouter {
    case create(deviceToken: String)
    case delete(deviceToken: String)

    static let group = "/users/"

    var method: HTTPMethod {
        switch self {
        case .create:
            return .post
        case .delete:
            return .delete
        }
    }

    var path: String {
        switch self {
        default:
            return RouterPushNotifications.group + "app-token/"
        }
    }
    
    var usesToken: Bool {
        return true
    }

    func encoded(_ request: URLRequest) throws -> URLRequest {
        switch self {
        case .create(let value):
            return try JSONEncoding.default.encode(request, with: [
                JSONKey.token.rawValue: value,
                JSONKey.platform.rawValue: k_platform
                ])
        case .delete(let value):
            return try JSONEncoding.default.encode(request, with: [JSONKey.token.rawValue: value])
        }
    }
}
