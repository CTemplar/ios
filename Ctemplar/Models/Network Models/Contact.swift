//
//  Contact.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 15.11.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation

struct Contact {
    
    var email : String? = nil
    var contactName : String? = nil
    var contactID : Int? = nil
    
    init() {
        
    }
    
    init(dictionary: [String: Any]) {
        
        self.email = dictionary["email"] as? String
        self.contactName = dictionary["name"] as? String
        self.contactID = dictionary["id"] as? Int
    }
}

/*
 address = "<null>";
 email = "dmitry8@dev.ctemplar.com";
 id = 1600;
 name = dmitry8;
 note = "<null>";
 phone = "<null>";
 phone2 = "<null>";
 provider = "<null>";
 */
