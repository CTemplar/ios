//
//  Contact.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 15.11.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import UIKit

struct Contact: Hashable {
    
    var email : String? = nil
    var contactName : String? = nil
    var contactID : Int? = nil
    var phone : String? = nil
    var address : String? = nil
    var note : String? = nil
    var isEncrypted : Bool? = nil
    var emailHash : String? = nil
    var encryptedData : String? = nil
    
    init() {
        
    }
    
    init(dictionary: [String: Any]) {
        
        self.email = dictionary["email"] as? String
        self.contactName = dictionary["name"] as? String
        self.contactID = dictionary["id"] as? Int
        self.phone = dictionary["phone"] as? String
        self.address = dictionary["address"] as? String
        self.note = dictionary["note"] as? String
        self.isEncrypted = dictionary["is_encrypted"] as? Bool
        self.emailHash = dictionary["email_hash"] as? String
        self.encryptedData = dictionary["encrypted_data"] as? String
    }
}

