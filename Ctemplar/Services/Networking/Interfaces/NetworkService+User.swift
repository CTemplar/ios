//
//  NetworkService+User.swift
//  Ctemplar
//
//  Created by Roman K. on 12/6/19.
//  Copyright © 2019 CTemplar. All rights reserved.
//

import Alamofire
import Foundation

protocol UserService {
    func getMyself(with completionHandler: @escaping Completion<MyselfResult>)
}

extension NetworkService: UserService {
    func getMyself(with completionHandler: @escaping Completion<MyselfResult>) {
        let pageCompletion: Completion<ContentPageResult<[MyselfResult]>> = { pageResult in
            let mapped = pageResult.flatMap({ (result: ContentPageResult<[MyselfResult]>) -> AppResult<MyselfResult> in
                if let value = result.results.first {
                    return .success(value)
                } else {
                    return .failure(AppError.downcastingFailed)
                }
            })
            completionHandler(mapped)
        }
        perform(request: RouterUser.myself,
                completionHandler: pageCompletion)
    }
}
