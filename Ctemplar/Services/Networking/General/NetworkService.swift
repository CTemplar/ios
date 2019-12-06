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
    private let additionalHeaders = ["accept": "application/json"]

    lazy var session: SessionManager = {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = additionalHeaders
        return SessionManager(configuration: configuration)
    }()
}

extension NetworkService {
//    func handler<T: Codable>(for completion: @escaping Completion<T>) -> (DataResponse<Data>) -> Void {
//        return { response in
//            let mappedResponse = response.flatMap { data in
//                try JSONDecoder().decode(T.self, from: data)
//            }
//            completion(mappedResponse.result)
//        }
//    }
}
