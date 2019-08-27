//
//  EmailMessage.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 09.10.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation

struct EmailMessage {
    
    var attachments: Array<Attachment>? = nil
    var bcc: Array<Any>? = nil
    var cc: Array<Any>? = nil
    var children: Array<EmailMessage>? = nil
    var content : String? = nil
    var createdAt : String? = nil
    var deadManDuration : Int? = nil
    var delayedDelivery : String? = nil
    var destructDay : String? = nil
    var encryption : EncryptionObject? = nil
    var folder : String? = nil
    var hasChildren : Bool? = nil
    var childrenCount: Int? = nil
    var hash : String? = nil
    var messsageID : Int? = nil
    var isEncrypted : Bool? = nil
    var isProtected : Bool? = nil
    var mailbox : String? = nil
    var parent : String? = nil
    var read : Bool? = nil
    var receivers : Array<Any>? = nil
    var send : String? = nil
    var sender : String? = nil
    var sentAt : String? = nil
    var starred : Bool? = nil
    var subject : String? = nil
    var incomingHeader : String? = nil
    var updated : String? = nil
    
    init() {
        
    }
    
    init(dictionary: [String: Any]) {
        
        print("email dict:", dictionary)
        
        if let attachmentsArray = dictionary["attachments"] as? Array<Any> {
            self.attachments = self.parsAttachmentsFromList(array: attachmentsArray)
        }
        self.bcc = dictionary["bcc"] as? Array<Any>
        self.cc = dictionary["cc"] as? Array<Any>
        
        if let childrenArray = dictionary["children"] as? Array<Any> {
            self.children = self.parsResultsFromList(array: childrenArray)
        }
        self.content = dictionary["content"] as? String
        self.createdAt = dictionary["created_at"] as? String
        self.deadManDuration = dictionary["dead_man_duration"] as? Int
        self.delayedDelivery = dictionary["delayed_delivery"] as? String
        self.destructDay = dictionary["destruct_date"] as? String
        //self.encryption = dictionary["encryption"] as? String
        let encryptionDictionary = dictionary["encryption"] as? Dictionary<String, Any>
        if encryptionDictionary != nil {
            //print("encryptionDictionary:", encryptionDictionary as Any)
            self.encryption = self.parsEncryptionFrom(dictionary: encryptionDictionary!)
        }
        self.folder = dictionary["folder"] as? String
        self.hasChildren = dictionary["has_children"] as? Bool
        self.childrenCount = dictionary["children_count"] as? Int
        self.hash = dictionary["hash"] as? String
        self.messsageID = dictionary["id"] as? Int
        self.isEncrypted = dictionary["is_encrypted"] as? Bool
        self.isProtected = dictionary["is_protected"] as? Bool
        self.mailbox = dictionary["mailbox"] as? String        
        self.parent = dictionary["parent"] as? String
        self.read = dictionary["read"] as? Bool
        self.receivers = dictionary["receiver"] as? Array<Any>
        self.send = dictionary["send"] as? String
        self.sender = dictionary["sender"] as? String
        self.sentAt = dictionary["sent_at"] as? String
        self.starred = dictionary["starred"] as? Bool
        self.subject = dictionary["subject"] as? String
        self.incomingHeader = dictionary["incoming_headers"] as? String
        self.updated = dictionary["updated"] as? String
    }
    
    func parsResultsFromList(array: Array<Any>) -> Array<EmailMessage>{
        
        var objectsArray: Array<EmailMessage> = []
        
        for object in array {
            if let objectDictionary = object as? Dictionary<String, Any> {
                let messageResult = EmailMessage(dictionary: objectDictionary)
                objectsArray.append(messageResult)
            }
        }
        
        return objectsArray
    }
    
    func parsAttachmentsFromList(array: Array<Any>) -> Array<Attachment>{
        
        var objectsArray: Array<Attachment> = []
        
        for object in array {
            if let objectDictionary = object as? Dictionary<String, Any> {
                let attachmentResult = Attachment(dictionary: objectDictionary)
                objectsArray.append(attachmentResult)
            }
        }
        
        return objectsArray
    }
    
    func parsEncryptionFrom(dictionary: Dictionary<String, Any>) -> EncryptionObject {
        
        let attachmentResult = EncryptionObject(dictionary: dictionary)
        return attachmentResult
    }
}
