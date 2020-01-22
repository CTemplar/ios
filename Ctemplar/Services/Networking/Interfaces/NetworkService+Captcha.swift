//
//  NetworkService+Captcha.swift
//  Ctemplar
//
//  Created by Roman K. on 12/6/19.
//  Copyright © 2019 ComeOnSoftware. All rights reserved.
//

import Alamofire
import Foundation

protocol CaptchaService {
    func getCaptcha(with completionHandler: @escaping Completion<CaptchaResult>)
    func verifyCaptcha(with value: String, key: String, completionHandler: @escaping Completion<StatusResult>)
}

extension NetworkService: CaptchaService {
    func getCaptcha(with completionHandler: @escaping Completion<CaptchaResult>) {
        perform(request: RouterCaptcha.get,
                completionHandler: completionHandler)
    }
    
    func verifyCaptcha(with value: String, key: String, completionHandler: @escaping Completion<StatusResult>) {
        perform(request: RouterCaptcha.verify(value: value, key: key),
                completionHandler: completionHandler)
    }
}
