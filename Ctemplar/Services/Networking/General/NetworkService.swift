//
//  NetworkService.swift
//  Ctemplar
//
//  Created by Roman K. on 12/6/19.
//  Copyright © 2019 ComeOnSoftware. All rights reserved.
//

import Alamofire
import Foundation

protocol NetworkServiceDelegate: class {
}

public class NetworkService {
    private let additionalHeaders = ["Accept": "application/json"]

    lazy var session: Session = {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = additionalHeaders
        return Session(configuration: configuration)
    }()
}

extension NetworkService {
    func handler<T: Codable>(for completion: @escaping Completion<T>) -> (AFDataResponse<Any>) -> Void {
        return { response in
            let mapped = response.tryMap({ (any: Any) -> T in
                if let value = any as? T {
                    return value
                } else {
                    throw AppError.downcastingFailed
                }
            })
            completion(mapped.result)
        }
    }
    
    func handler(for completion: @escaping Completion<Void>) -> (AFDataResponse<Any>) -> Void {
        return { response in
            completion(response.tryMap({_ in ()}).result)
        }
    }
    
    func perform(request: URLRequestConvertible, completionHandler: @escaping Completion<Void>) {
        session.request(request)
            .validate(statusCode: 200..<300)
            .responseJSON(completionHandler: handler(for: completionHandler))
    }
    func perform<T: Codable>(request: URLRequestConvertible, completionHandler: @escaping Completion<T>) {
        session.request(request)
            .validate(statusCode: 200..<300)
            .responseJSON(completionHandler: handler(for: completionHandler))
    }
}
