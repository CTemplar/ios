//
//  AuthResult.swift
//  CTemplar
//
//  Created by romkh on 11.12.2019.
//  Copyright © 2019 CTemplar. All rights reserved.
//

import Foundation

public struct LoginResult: Codable {
    public let token: String?
    public let status: Bool
    public let isTwoFAEnabled: Bool
    
    private enum CodingKeys: String, CodingKey {
        case token, status
        case isTwoFAEnabled = "is_2fa_enabled"
    }
}

public struct CheckUserResult: Codable {
    public let exists: Bool
}

public struct TokenResult: Codable {
    public let token: String
}

public struct CaptchaResult: Codable {
    public let image: String
    public let key: String
    
    private enum CodingKeys: String, CodingKey {
        case image = "captcha_image"
        case key = "captcha_key"
    }
}

public struct StatusResult: Codable {
    public let status: Bool
}
