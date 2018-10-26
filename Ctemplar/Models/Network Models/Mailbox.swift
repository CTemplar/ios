//
//  Mailbox.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 10.10.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation

struct Mailbox {
    
    var displayName : String? = nil
    var email : String? = nil
    var fingerprint : String? = nil
    var resultID : Int? = nil
    var isDefault : Bool? = nil
    var isEnabled : Bool? = nil
    var privateKey : String? = nil
    var publicKey : String? = nil
    var signature : String? = nil
    
    init() {
        
    }
    
    init(dictionary: [String: Any]) {
        
        self.displayName = dictionary["display_name"] as? String
        self.email = dictionary["email"] as? String
        self.fingerprint = dictionary["fingerprint"] as? String
        self.resultID = dictionary["id"] as? Int
        self.isDefault = dictionary["is_default"] as? Bool
        self.isEnabled = dictionary["is_enabled"] as? Bool
        self.privateKey = dictionary["private_key"] as? String
        self.publicKey = dictionary["public_key"] as? String
        self.signature = dictionary["signature"] as? String
    }
}
