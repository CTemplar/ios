import Foundation

public struct Mailbox {
    // MARK: Properties
    public private (set) var displayName: String?
    public private (set) var email: String?
    public private (set) var fingerprint: String?
    public private (set) var mailboxID: Int?
    public private (set) var isDefault: Bool?
    public private (set) var isEnabled: Bool?
    public private (set) var privateKey: String?
    public private (set) var publicKey: String?
    public private (set) var signature: String?
    
    // MARK: Constructor
    public init() {}
    
    public init(dictionary: [String: Any]) {
        self.displayName = dictionary["display_name"] as? String
        self.email = dictionary["email"] as? String
        self.fingerprint = dictionary["fingerprint"] as? String
        self.mailboxID = dictionary["id"] as? Int
        self.isDefault = dictionary["is_default"] as? Bool
        self.isEnabled = dictionary["is_enabled"] as? Bool
        self.privateKey = dictionary["private_key"] as? String
        self.publicKey = dictionary["public_key"] as? String
        self.signature = dictionary["signature"] as? String
    }
}
