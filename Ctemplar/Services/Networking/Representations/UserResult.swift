//
//  UserResult.swift
//  Ctemplar
//
//  Created by Roman Kharchenko on 2019-12-18.
//  Copyright © 2019 ComeOnSoftware. All rights reserved.
//

import Foundation

struct MyselfResult: Codable {
    let username: String
    let id: Int
    let isPrime: Bool
    let joinedDate: String
    let paymentTransaction: String?
    
    private enum CodingKeys: String, CodingKey {
        case username, id
        case isPrime = "is_prime"
        case joinedDate = "joined_date"
        case paymentTransaction = "payment_transaction"
    }
}
