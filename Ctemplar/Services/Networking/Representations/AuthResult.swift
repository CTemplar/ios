//
//  AuthResult.swift
//  Ctemplar
//
//  Created by romkh on 11.12.2019.
//  Copyright © 2019 CTemplar. All rights reserved.
//

import Foundation

struct LoginResult: Codable {
    let token: String?
    let status: Bool
    let isTwoFAEnabled: Bool
    
    private enum CodingKeys: String, CodingKey {
        case token, status
        case isTwoFAEnabled = "is_2fa_enabled"
    }
}

struct CheckUserResult: Codable {
    let exists: Bool
}

struct TokenResult: Codable {
    let token: String
}

struct CaptchaResult: Codable {
    let image: String
    let key: String
    
    private enum CodingKeys: String, CodingKey {
        case image = "captcha_image"
        case key = "captcha_key"
    }
}

struct StatusResult: Codable {
    let status: Bool
}
