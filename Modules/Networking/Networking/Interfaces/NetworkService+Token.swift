//
//  NetworkService+Token.swift
//  Ctemplar
//
//  Created by Roman K. on 12/6/19.
//  Copyright © 2019 CTemplar. All rights reserved.
//

import Alamofire
import Foundation
import Utility

protocol TokenService {
    func verifyToken(token: String, completionHandler: @escaping Completion<Void>)
    func refreshToken(token: String, completionHandler: @escaping Completion<TokenResult>)
}

extension NetworkService: TokenService {
    func verifyToken(token: String, completionHandler: @escaping Completion<Void>) {
        perform(request: RouterToken.verify(value: token),
                completionHandler: completionHandler)
    }
    
    func refreshToken(token: String, completionHandler: @escaping Completion<TokenResult>) {
        perform(request: RouterToken.refresh(value: token),
                completionHandler: completionHandler)
    }
}

extension TokenService {
    func checkToken(completion: @escaping Completion<TokenResult>) {
        let tokenSavedTime = UtilityManager.shared.keychainService.getTokenSavedTime()
        let existing = UtilityManager.shared.keychainService.getToken()
        let refreshToken = {
            guard !existing.isEmpty else {
                completion(.failure(AppError.serverError(value: "Something went wrong")))
                return
            }
            self.refreshToken(token: existing, completionHandler: completion)
        }
        guard !tokenSavedTime.isEmpty else {
            refreshToken()
            return
        }
        guard let tokenSavedDate = UtilityManager.shared.formatterService
            .formatTokenTimeStringToDate(date: tokenSavedTime) else {
                completion(.failure(AppError.serverError(value: "Something went wrong")))
                return
        }
        let minutesCount = tokenSavedDate.minutesCountForTokenExpiration()
        if minutesCount > TokenConstant.tokenMinutesExpiration.rawValue {
            refreshToken()
        } else {
            completion(.success(TokenResult(token: existing)))
        }
    }
}
