//
//  LoginResult.swift
//  Ctemplar
//
//  Created by romkh on 11.12.2019.
//  Copyright © 2019 ComeOnSoftware. All rights reserved.
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
