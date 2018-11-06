//
//  UnreadMessages.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 06.11.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation

struct UnreadMessages {
    
    var archive: Int? = nil
    var draft: Int? = nil
    var inbox: Int? = nil
    var spam: Int? = nil
    var starred: Int? = nil
    var trash: Int? = nil
    
    init() {
        
    }
    
    init(dictionary: [String: Any]) {
        
        self.archive = dictionary["archive"] as? Int
        self.draft = dictionary["draft"] as? Int
        self.inbox = dictionary["inbox"] as? Int
        self.spam = dictionary["spam"] as? Int
        self.starred = dictionary["starred"] as? Int
        self.trash = dictionary["trash"] as? Int
    }
}
