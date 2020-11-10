//
//  MailResult.swift
//  CTemplar
//
//  Created by romkh on 19.12.2019.
//  Copyright © 2019 CTemplar. All rights reserved.
//

import Foundation

public struct CustomFolder: Codable {
    public let color: String
    public let id: Int
    public let name: String
    public let sortOrder: Int
    private enum CodingKeys: String, CodingKey {
        case color, name, id
        case sortOrder = "sort_order"
    }
}

public struct MailboxR: Codable {
    public let displayName: String?
    public let email: String
    public let fingerprint: String
    public let id: Int
    public let isDefault: Bool
    public let isEnabled: Bool
    public let privateKey: String?
    public let publicKey: String?
    public let signature: String?
    public let sortOrder: Int?
    
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
