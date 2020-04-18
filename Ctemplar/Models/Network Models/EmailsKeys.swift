//
//  EmailsKeys.swift
//  Ctemplar
//
//  Created by Majid Hussain on 18/04/2020.
//  Copyright © 2020 AreteSol. All rights reserved.
//

import UIKit
import ObjectivePGP

struct EmailKey {
    var keyId = 0
    var email = ""
    var isEnabled = false
    var publicKey = ""
    var sortOrder = 0
    
    init(dict: [String: Any]) {
        keyId = dict["id"] as? Int ?? 0
        email = dict["email"] as? String ?? ""
        isEnabled = dict["is_enabled"] as? Bool ?? false
        publicKey = dict["public_key"] as? String ?? ""
        sortOrder = dict["sort_order"] as? Int ?? 0
    }
}

struct EmailsKeys {
    var encrypt = false
    var keys = [EmailKey]()
    
    var pgpKeys: [Key] = []
    
    init(dict: [String : Any]) {
        encrypt = dict["encrypt"] as? Bool ?? false
        if let keysArray = dict["keys"] as? [[String: Any]] {
            keys = keysArray.map({ EmailKey(dict: $0)})
        }
    }
}
