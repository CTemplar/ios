import Foundation

public struct EmailMessage {
    // MARK: Properties
    public private (set) var attachments: Array<Attachment>?
    public private (set) var bcc: Array<Any>?
    public private (set) var cc: Array<Any>?
    public private (set) var children: Array<EmailMessage>?
    public private (set) var content: String?
    public private (set) var createdAt: String?
    public private (set) var deadManDuration: Int?
    public private (set) var delayedDelivery: String?
    public private (set) var destructDay: String?
    public private (set) var encryption: EncryptionObject?
    public private (set) var folder: String?
    public private (set) var hasChildren: Bool?
    public private (set) var childrenCount: Int?
    public private (set) var hash: String?
    public private (set) var messsageID: Int?
    public private (set) var isEncrypted: Bool?
    public private (set) var isProtected: Bool?
    public private (set) var isHtml: Bool?
    public private (set) var isSubjectEncrypted: Bool?
    public private (set) var mailbox: String?
    public private (set) var parent: String?
    public private (set) var read: Bool?
    public private (set) var receivers: Array<Any>?
    public private (set) var receivers_display: [String] = []
    public private (set) var send: String?
    public private (set) var sender: String?
    public private (set) var sender_display: String?
    public private (set) var sentAt: String?
    public private (set) var starred: Bool?
    public private (set) var subject: String?
    public private (set) var incomingHeader: String?
    public private (set) var updated: String?
    public private (set) var forwardAttachmentsMessage: Int?
    
    // MARK: - Constructor
    public init() {}
    
    public init(dictionary: [String: Any]) {
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
        let encryptionDictionary = dictionary["encryption"] as? Dictionary<String, Any>
        if encryptionDictionary != nil {
            self.encryption = self.parsEncryptionFrom(dictionary: encryptionDictionary!)
        }
        self.folder = dictionary["folder"] as? String
        self.hasChildren = dictionary["has_children"] as? Bool
        self.childrenCount = dictionary["children_count"] as? Int
        self.hash = dictionary["hash"] as? String
        self.messsageID = dictionary["id"] as? Int
        self.isEncrypted = dictionary["is_encrypted"] as? Bool
        self.isProtected = dictionary["is_protected"] as? Bool
        self.isHtml = dictionary["is_html"] as? Bool
        self.isSubjectEncrypted = dictionary["is_subject_encrypted"] as? Bool
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
        self.forwardAttachmentsMessage = dictionary["forward_attachments_of_message"] as? Int
        if let senderDisplayDict = dictionary["sender_display"] as? [String: Any] {
            if let displayName = senderDisplayDict["name"] as? String {
                self.sender_display = displayName
            }
        }
        if let receiversDisplayArray = dictionary["receiver_display"] as? [[String: Any]] {
            receivers_display = receiversDisplayArray.map({ $0["name"] as? String ?? "" })
        }
    }
    
    // MARK: - Parser
    public func parsResultsFromList(array: Array<Any>) -> Array<EmailMessage>{
        var objectsArray: Array<EmailMessage> = []
        for object in array {
            if let objectDictionary = object as? Dictionary<String, Any> {
                let messageResult = EmailMessage(dictionary: objectDictionary)
                objectsArray.append(messageResult)
            }
        }
        return objectsArray
    }
    
    public func parsAttachmentsFromList(array: Array<Any>) -> Array<Attachment>{
        var objectsArray: Array<Attachment> = []
        for object in array {
            if let objectDictionary = object as? Dictionary<String, Any> {
                let attachmentResult = Attachment(dictionary: objectDictionary)
                objectsArray.append(attachmentResult)
            }
        }
        return objectsArray
    }
    
    public func parsEncryptionFrom(dictionary: Dictionary<String, Any>) -> EncryptionObject {
        let attachmentResult = EncryptionObject(dictionary: dictionary)
        return attachmentResult
    }
}
// MARK: - Update
public extension EmailMessage {
    mutating func update(_ readStatus: Bool) {
        self.read = readStatus
    }
    
    mutating func update(isStarred: Bool) {
        self.starred = isStarred
    }
    
    mutating func update(attachments: [Attachment]?) {
        self.attachments = attachments
    }
    
    mutating func update(bcc: [String]?) {
        self.bcc = bcc
    }
    
    mutating func update(cc: [String]?) {
        self.cc = cc
    }
    
    mutating func update(children: [EmailMessage]) {
        self.children = children
    }
    
    mutating func update(content: String?) {
        self.content = content
    }
    
    mutating func update(createdAt: String?) {
        self.createdAt = createdAt
    }
    
    mutating func update(deadManDuration: Int?) {
        self.deadManDuration = deadManDuration
    }
    
    mutating func update(delayedDelivery: String?) {
        self.delayedDelivery = delayedDelivery
    }
    
    mutating func update(destructDay: String?) {
        self.destructDay = destructDay
    }
    
    mutating func update(encryption: EncryptionObject?) {
        self.encryption = encryption
    }
    
    mutating func update(folder: String?) {
        self.folder = folder
    }
    
    mutating func update(hasChildren: Bool?) {
        self.hasChildren = hasChildren
    }
    
    mutating func update(childrenCount: Int?) {
        self.childrenCount = childrenCount
    }
    
    mutating func update(hash: String?) {
        self.hash = hash
    }
    
    mutating func update(messsageID: Int?) {
        self.messsageID = messsageID
    }
    
    mutating func update(isEncrypted: Bool?) {
        self.isEncrypted = isEncrypted
    }
    
    mutating func update(isProtected: Bool?) {
        self.isProtected = isProtected
    }
    
    mutating func update(isHtml: Bool?) {
        self.isHtml = isHtml
    }
    
    mutating func update(isSubjectEncrypted: Bool?) {
        self.isSubjectEncrypted = isSubjectEncrypted
    }
    
    mutating func update(mailbox: String?) {
        self.mailbox = mailbox
    }
    
    mutating func update(parent: String?) {
        self.parent = parent
    }
    
    mutating func update(receivers: [Any]?) {
        self.receivers = receivers
    }
    
    mutating func update(receiversDisplay: [String]) {
        self.receivers_display = receiversDisplay
    }
    
    mutating func update(send: String?) {
        self.send = send
    }
    
    mutating func update(senderDisplay: String?) {
        self.sender_display = senderDisplay
    }
    
    mutating func update(sender: String?) {
        self.sender = sender
    }
    
    mutating func update(sentAt: String?) {
        self.sentAt = sentAt
    }
    
    mutating func update(subject: String?) {
        self.subject = subject
    }
    
    mutating func update(incomingHeader: String?) {
        self.incomingHeader = incomingHeader
    }
    
    mutating func update(updated: String?) {
        self.updated = updated
    }
    
    mutating func update(forwardAttachmentsMessage: Int?) {
        self.forwardAttachmentsMessage = forwardAttachmentsMessage
    }
    
    mutating func update(isHtml: Bool) {
        self.isHtml = isHtml
    }
}
