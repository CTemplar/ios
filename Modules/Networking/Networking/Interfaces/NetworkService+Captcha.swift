//
//  NetworkService+Captcha.swift
//  CTemplar
//
//  Created by Roman K. on 12/6/19.
//  Copyright © 2019 CTemplar. All rights reserved.
//

import Alamofire
import Foundation
import Utility

public protocol CaptchaService {
    func getCaptcha(with completionHandler: @escaping Completion<CaptchaResult>)
    func verifyCaptcha(with value: String, key: String, completionHandler: @escaping Completion<StatusResult>)
}

extension NetworkService: CaptchaService {
    public func getCaptcha(with completionHandler: @escaping Completion<CaptchaResult>) {
        perform(request: RouterCaptcha.get,
                completionHandler: completionHandler)
    }
    
    public func verifyCaptcha(with value: String, key: String, completionHandler: @escaping Completion<StatusResult>) {
        perform(request: RouterCaptcha.verify(value: value, key: key),
                completionHandler: completionHandler)
    }
}
