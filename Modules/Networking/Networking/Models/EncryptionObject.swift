import Foundation
import Utility

public struct EncryptionObject: Encodable {
    // MARK: Properties
    public var created: String?
    public var expires: String?
    public var encryptionObjectID: Int?
    public var messageID: Int?
    public var password: String?
    public var passwordHint: String?
    public var privateKey: String?
    public var publicKey: String?
    public var randomSecret: String?
    public var expiryHours: Int?
    
    // MARK: - Constructor
    public init() {}

    public init(dictionary: [String: Any]) {
        self.created = dictionary["created"] as? String
        self.expires = dictionary["expires"] as? String
        self.encryptionObjectID = dictionary["id"] as? Int
        self.messageID = dictionary["message"] as? Int
        self.password = dictionary["password"] as? String
        self.passwordHint = dictionary["password_hint"] as? String
        self.privateKey = dictionary["private_key"] as? String
        self.publicKey = dictionary["public_key"] as? String
        self.randomSecret = dictionary["random_secret"] as? String
        self.expiryHours = dictionary["expiry_hours"] as? Int
    }
    
    public init(password: String, passwordHint: String, expiryHours: Int) {
        self.password = password
        self.passwordHint = passwordHint
        self.expiryHours = expiryHours
    }
    
    // MARK: - Helpers
    public mutating func setPGPKeys(publicKey: String, privateKey: String) {
        self.publicKey = publicKey
        self.privateKey = privateKey
    }
    
    func encodeToJson() -> String {
        var encodedString = ""
        let encoder = JSONEncoder()
        let data = try? encoder.encode(self)
        if let data = data {
            encodedString = String(data: data, encoding: .utf8) ?? ""
            DPrint("Encoded:", encodedString)
        } else {
            DPrint("erorr Encoding")
        }
        return encodedString
    }
    
    // MARK: - Parser
    public func toDictionary() -> [String: String] {
        return ["password": password ?? "",
                "password_hint": passwordHint ?? "",
                "created" : created ?? "",
                "expires" : expires ?? "",
                "id": encryptionObjectID?.description ?? "",
                "message" : messageID?.description ?? "",
                "private_key": privateKey ?? "",
                "public_key" : publicKey ?? "",
                "random_secret": randomSecret ?? "",
                "expiry_hours" : expiryHours?.description ?? ""
                ]
    }
    
    public func toShortDictionary() -> [String: String] {
        return ["password": password ?? "",
                "password_hint": passwordHint ?? "",
                "expiry_hours" : "\(expiryHours ?? 120)"
        ]
    }
}
