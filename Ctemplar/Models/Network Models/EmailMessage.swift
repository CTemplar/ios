//
//  EmailMessage.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 09.10.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation

struct EmailMessage {
    
    var attachments: Array<Any>? = nil
    var bcc: Array<Any>? = nil
    var cc: Array<Any>? = nil
    var content : String? = nil
    var createdAt : String? = nil
    var deadManDuration : String? = nil
    var delayedDelivery : String? = nil
    var destructDay : String? = nil
    var encryption : String? = nil
    var folder : String? = nil
    var hasChildren : String? = nil
    var hash : String? = nil
    var resultID : String? = nil
    var isEncrypted : String? = nil
    var isProtected : String? = nil
    var mailbox : String? = nil
    var parent : String? = nil
    var read : Bool? = nil
    var receiver : Array<Any>? = nil
    var send : String? = nil
    var sender : String? = nil
    var sentAt : String? = nil
    var starred : String? = nil
    var subject : String? = nil
    var updated : String? = nil
    
    init() {
        
    }
    
    init(dictionary: [String: Any]) {
        
        self.attachments = dictionary["attachments"] as? Array<Any>
        self.bcc = dictionary["bcc"] as? Array<Any>
        self.cc = dictionary["cc"] as? Array<Any>
        self.content = dictionary["content"] as? String
        self.createdAt = dictionary["created_at"] as? String
        self.deadManDuration = dictionary["dead_man_duration"] as? String
        self.delayedDelivery = dictionary["delayed_delivery"] as? String
        self.destructDay = dictionary["destruct_date"] as? String
        self.encryption = dictionary["encryption"] as? String
        self.folder = dictionary["folder"] as? String
        self.hasChildren = dictionary["has_children"] as? String
        self.hash = dictionary["hash"] as? String
        self.resultID = dictionary["id"] as? String
        self.isEncrypted = dictionary["is_encrypted"] as? String
        self.isProtected = dictionary["is_protected"] as? String
        self.mailbox = dictionary["mailbox"] as? String        
        self.parent = dictionary["parent"] as? String
        self.read = dictionary["read"] as? Bool
        self.receiver = dictionary["receiver"] as? Array<Any>
        self.send = dictionary["send"] as? String
        self.sender = dictionary["sender"] as? String
        self.sentAt = dictionary["sent_at"] as? String
        self.starred = dictionary["starred"] as? String
        self.subject = dictionary["subject"] as? String
        self.updated = dictionary["updated"] as? String
    }
}
