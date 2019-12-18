//
//  BaseRouter.swift
//  Ctemplar
//
//  Created by Roman K. on 12/6/19.
//  Copyright © 2019 ComeOnSoftware. All rights reserved.
//

import Alamofire
import Foundation

protocol BaseRouter: URLRequestConvertible {
    var method: HTTPMethod { get }
    var path: String { get }
    var usesToken: Bool { get }
    func encoded(_ request: URLRequest) throws -> URLRequest
}

extension BaseRouter {
    func asURLRequest() throws -> URLRequest {
        let url = try NetworkConfiguration.baseUrl.asURL()

        var urlRequest = URLRequest(url: url.appendingPathComponent(path))
        urlRequest.httpMethod = method.rawValue
        urlRequest = try encoded(urlRequest)

        return urlRequest
    }
}
