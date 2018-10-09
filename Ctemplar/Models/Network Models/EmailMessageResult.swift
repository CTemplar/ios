//
//  EmailMessageResults.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 09.10.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation

struct EmailMessageResult {
    
    var attachments: Array<Any>? = nil
    var bcc: Array<Any>? = nil
    var cc: Array<Any>? = nil
    var content : String? = nil
    var createdAt : String? = nil
    
    init() {
        
    }
    
    init(dictionary: [String: Any]) {
        
        self.attachments = dictionary["attachments"] as? Array<Any>
        self.bcc = dictionary["bcc"] as? Array<Any>
        self.cc = dictionary["cc"] as? Array<Any>
        self.content = dictionary["content"] as? String
        self.createdAt = dictionary["created_at"] as? String
    }
}

/*
 "created_at" = "2018-10-04T15:47:47.228191Z";
 "dead_man_duration" = "<null>";
 "delayed_delivery" = "<null>";
 "destruct_date" = "<null>";
 encryption = "<null>";
 folder = inbox;
 "has_children" = 0;
 hash = a7b6f6d378c549dbb8222f4598ce0789;
 id = 658;
 "is_encrypted" = 0;
 "is_protected" = 1;
 mailbox = 49;
 parent = "<null>";
 read = 0;
 receiver =     (
 "newuser5@dev.ctemplar.com"
 );
 send = 0;
 sender = "dmitry3@dev.ctemplar.com";
 "sent_at" = "<null>";
 starred = 0;
 subject = "Test subj";
 updated = "2018-10-04T15:47:47.228217Z";
 */
