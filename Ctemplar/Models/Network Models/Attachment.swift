//
//  Attachment.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 20.11.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation

struct Attachment {
    
    var contentID : Int? = nil
    var contentUrl : String? = nil
    var attachmentID : Int? = nil
    var inline : Bool? = nil
    var message : String? = nil
    
    init() {
        
    }
    
    init(dictionary: [String: Any]) {
        
        self.contentID = dictionary["content_id"] as? Int
        self.contentUrl = dictionary["document"] as? String
        self.attachmentID = dictionary["id"] as? Int
        self.inline = dictionary["is_inline"] as? Bool
        self.message = dictionary["message"] as? String
    }
}
