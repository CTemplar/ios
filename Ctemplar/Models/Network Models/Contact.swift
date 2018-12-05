//
//  Contact.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 15.11.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation

struct Contact: Hashable {
    
    var email : String? = nil
    var contactName : String? = nil
    var contactID : Int? = nil
    var phone : String? = nil
    var address : String? = nil
    var note : String? = nil
    
    init() {
        
    }
    
    init(dictionary: [String: Any]) {
        
        self.email = dictionary["email"] as? String
        self.contactName = dictionary["name"] as? String
        self.contactID = dictionary["id"] as? Int
        self.phone = dictionary["phone"] as? String
        self.address = dictionary["address"] as? String
        self.note = dictionary["note"] as? String
    }
}

