import Foundation
import PGPFramework

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
    public var keyType: String?
    public private (set) var keyID: Int?
    public var extraKeys: Array<Mailbox>?
    // MARK: Constructor
    public init() {}
    
    public init(dictionary: [String: Any], _ isfromExtraKeys: Bool = false) {
        self.displayName = dictionary["display_name"] as? String
        self.email = dictionary["email"] as? String
        self.fingerprint = dictionary["fingerprint"] as? String
        if(isfromExtraKeys == true) {
            self.mailboxID = dictionary["mailbox"] as? Int
            self.keyID = dictionary["id"] as? Int
        }
        else {
            self.mailboxID = dictionary["id"] as? Int
        }
        self.isDefault = dictionary["is_default"] as? Bool
        self.isEnabled = dictionary["is_enabled"] as? Bool
        self.privateKey = dictionary["private_key"] as? String
        self.publicKey = dictionary["public_key"] as? String
        self.signature = dictionary["signature"] as? String
        self.keyType = dictionary["key_type"] as? String
        self.keyType = dictionary["key_type"] as? String
       
        
    }
    
    
    public static func getKeysModel(keysArray: Array<Mailbox>) {
        var array = Array<KeysModel>()
        for key in keysArray {
            var keyModel = KeysModel()
            keyModel.displayName = key.displayName
            keyModel.email = key.email
            keyModel.fingerprint = key.fingerprint
            keyModel.mailboxID = key.mailboxID
            keyModel.isDefault = key.isDefault
            keyModel.isEnabled = key.isEnabled
            keyModel.privateKey = key.privateKey
            keyModel.publicKey = key.publicKey
            keyModel.signature = key.signature
            array.append(keyModel)
        }
            if let data = try? JSONEncoder().encode(array) {
                UserDefaults.standard.set(data, forKey: "keysArray")
                UserDefaults.standard.synchronize()
            }
        }
}
