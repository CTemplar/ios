//
//  NetworkService.swift
//  Ctemplar
//
//  Created by Roman K. on 12/6/19.
//  Copyright © 2019 CTemplar. All rights reserved.
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
    func handler<T: Codable>(for completion: @escaping Completion<T>) -> (AFDataResponse<Data>) -> Void {
        return { response in
            let mapped = response
                .tryMap{ try JSONDecoder().decode(T.self, from: $0) }
                .tryMapError(self.errorHadler(for: response))
            completion(mapped.result)
        }
    }
    
    func handler(for completion: @escaping Completion<Void>) -> (AFDataResponse<Data>) -> Void {
        return { response in
            let mapped = response
                .tryMap({_ in ()})
                .tryMapError(self.errorHadler(for: response))
            completion(mapped.result)
        }
    }
    
    func errorHadler(for response: AFDataResponse<Data>) -> ((Error) -> Error) {
        return { initial in
            if let data = response.data,
                let errorInfo = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                for value in errorInfo.values {
                    if let array = value as? [Any], let message = array.first as? String {
                        return AppError.serverError(value: message)
                    }
                }
                return initial
            }
            return initial
        }
    }
    
    func perform(request: URLRequestConvertible, completionHandler: @escaping Completion<Void>) {
        if let router = request as? BaseRouter, router.usesToken {
            checkToken {
                guard let result = try? $0.get(),
                    var request = try? request.asURLRequest() else {
                        completionHandler(.failure(AppError.cryptoFailed))
                        return
                }
                request.addValue("JWT " + result.token, forHTTPHeaderField: "Authorization")
                self.session.request(request)
                    .validate(statusCode: 200..<300)
                    .responseData(completionHandler: self.handler(for: completionHandler))
            }
        } else {
            session.request(request)
                .validate(statusCode: 200..<300)
                .responseData(completionHandler: handler(for: completionHandler))
        }
    }
    func perform<T: Codable>(request: URLRequestConvertible, completionHandler: @escaping Completion<T>) {
        if let router = request as? BaseRouter, router.usesToken {
            checkToken {
                guard let result = try? $0.get(),
                    var request = try? request.asURLRequest() else {
                        completionHandler(.failure(AppError.cryptoFailed))
                        return
                }
                request.addValue("JWT " + result.token, forHTTPHeaderField: "Authorization")
                self.session.request(request)
                    .validate(statusCode: 200..<300)
                    .responseData(completionHandler: self.handler(for: completionHandler))
            }
        } else {
            session.request(request)
                .validate(statusCode: 200..<300)
                .responseData(completionHandler: handler(for: completionHandler))
        }
    }
}
