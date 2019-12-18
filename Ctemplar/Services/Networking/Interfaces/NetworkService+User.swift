//
//  NetworkService+User.swift
//  Ctemplar
//
//  Created by Roman K. on 12/6/19.
//  Copyright © 2019 ComeOnSoftware. All rights reserved.
//

import Alamofire
import Foundation

protocol UserService {
    func getMyself(with completionHandler: @escaping Completion<MyselfResult>)
}

extension NetworkService: UserService {
    func getMyself(with completionHandler: @escaping Completion<MyselfResult>) {
        perform(request: RouterUser.myself,
                completionHandler: completionHandler)
    }
}
