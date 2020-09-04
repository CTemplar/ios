import Foundation

public struct Attachment: Equatable {
    // MARK: Properties
    public var contentID: Int?
    public var contentUrl: String?
    public var attachmentID: Int?
    public var inline: Bool?
    public var messageID: Int?
    public var encrypted: Bool?
    public var localUrl: String?
    
    // MARK: - Constructor
    public init() {
    }
    
    init(dictionary: [String: Any]) {
        self.contentID = dictionary["content_id"] as? Int
        self.contentUrl = dictionary["document"] as? String
        self.attachmentID = dictionary["id"] as? Int
        self.inline = dictionary["is_inline"] as? Bool
        self.messageID = dictionary["message"] as? Int
        self.encrypted = dictionary["is_encrypted"] as? Bool
        self.localUrl = dictionary["localUrl"] as? String
    }
    
    // MARK: - Parser
    public func toDictionary() -> [String: String] {
        return ["content_id": contentID?.description ?? "",
                "document"  : contentUrl ?? "",
                "is_inline" : inline?.description ?? "",
                "id"        : attachmentID?.description ?? "",
                "message"   : messageID?.description ?? "",
                "is_encrypted": encrypted?.description ?? "",
                "localUrl"  : localUrl ?? ""
        ]
    }
    
    public static func ==(lhs: Attachment, rhs: Attachment) -> Bool {
        if let id1 = lhs.attachmentID, let id2 = rhs.attachmentID {
            return id1 == id2
        }
        return false
    }
}
