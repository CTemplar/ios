//
//  APIService.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 01.10.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation

enum APIResult<T>
{
    case success(T)
    case failure(Error)
}

enum APIResponse: String {
    case password         = "password"
    case username         = "username"
    case non_field_errors = "non_field_errors"
    case token            = "token"
}

class APIService {
    
    let restAPIService = RestAPIService()
    
    //MARK: - authentication
    
    func authenticateUser(userName: String, password: String, completionHandler: @escaping (APIResult<Any>) -> Void) {
        
        restAPIService.authenticateUser(userName: userName, password: password, completionHandler: completionHandler)
    }
}
