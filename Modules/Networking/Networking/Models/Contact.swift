import Foundation

public struct Contact: Hashable {
    // MARK: Properties
    public private (set) var email: String?
    public private (set) var contactName: String?
    public private (set) var contactID: Int?
    public private (set) var phone: String?
    public private (set) var address: String?
    public private (set) var note: String?
    public private (set) var isEncrypted: Bool?
    public private (set) var emailHash: String?
    public private (set) var encryptedData: String?
    public private (set) var isSelected: Bool = false
    
    // MARK: Constructor
    public init() {}
    
    public init(dictionary: [String: Any]) {
        self.email = dictionary["email"] as? String
        self.contactName = dictionary["name"] as? String
        self.contactID = dictionary["id"] as? Int
        self.phone = dictionary["phone"] as? String
        self.address = dictionary["address"] as? String
        self.note = dictionary["note"] as? String
        self.isEncrypted = dictionary["is_encrypted"] as? Bool
        self.emailHash = dictionary["email_hash"] as? String
        self.encryptedData = dictionary["encrypted_data"] as? String
    }
    
    public init(encryptedDictionary: [String: Any], contactId: Int, encryptedData: String) {
        self.email = encryptedDictionary["email"] as? String
        self.contactName = encryptedDictionary["name"] as? String
        self.contactID = contactId
        self.phone = encryptedDictionary["phone"] as? String
        self.address = encryptedDictionary["address"] as? String
        self.note = encryptedDictionary["note"] as? String
        self.isEncrypted = true
        self.emailHash = encryptedDictionary["email_hash"] as? String
        self.encryptedData = encryptedData
    }
    
    public init(decryptedDictionary: [String: Any], contactId: Int) {
        self.email = decryptedDictionary["email"] as? String
        self.contactName = decryptedDictionary["name"] as? String
        self.contactID = contactId
        self.phone = decryptedDictionary["phone"] as? String
        self.address = decryptedDictionary["address"] as? String
        self.note = decryptedDictionary["note"] as? String
        self.isEncrypted = false
        self.emailHash = decryptedDictionary["email_hash"] as? String
    }
    
    public mutating func update(isSelected: Bool) {
        self.isSelected = isSelected
    }
}
