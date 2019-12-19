//
//  MailResult.swift
//  Ctemplar
//
//  Created by romkh on 19.12.2019.
//  Copyright © 2019 ComeOnSoftware. All rights reserved.
//

import Foundation

struct CustomFolder: Codable {
    let color: String
    let id: Int
    let name: String
    let sortOrder: Int
    private enum CodingKeys: String, CodingKey {
        case color, name, id
        case sortOrder = "sort_order"
    }
}

struct MailboxR: Codable {
    let displayName: String?
    let email: String
    let fingerprint: String
    let id: Int
    let isDefault: Bool
    let isEnabled: Bool
    let privateKey: String?
    let publicKey: String?
    let signature: String?
    let sortOrder: Int?
    
    private enum CodingKeys: String, CodingKey {
        case email, fingerprint, id, signature
        case displayName = "display_name"
        case isDefault = "is_default"
        case isEnabled = "is_enabled"
        case privateKey = "private_key"
        case publicKey = "public_key"
        case sortOrder = "sort_order"
    }
}
