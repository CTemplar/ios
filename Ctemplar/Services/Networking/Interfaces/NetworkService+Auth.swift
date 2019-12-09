//
//  NetworkService+Places.swift
//  Ctemplar
//
//  Created by Roman K. on 12/6/19.
//  Copyright © 2019 ComeOnSoftware. All rights reserved.
//

import Alamofire
import Foundation

protocol AuthService {
    func authUser(userName: String,
                  password: String,
                  twoFAcode: String?,
                  completionHandler: @escaping Completion<Void>)
    func checkUser(name: String,
                   completionHandler: @escaping Completion<Void>)
}

extension NetworkService: AuthService {
    func authUser(userName: String,
                  password: String,
                  twoFAcode: String?,
                  completionHandler: @escaping Completion<Void>) {
        perform(request: RouterAuth.auth(userName: userName, password: password, twoFAcode: twoFAcode),
                completionHandler: completionHandler)
    }
    func checkUser(name: String,
                   completionHandler: @escaping Completion<Void>) {
        perform(request: RouterAuth.check(userName: name),
                completionHandler: completionHandler)
    }
}
