import Foundation

public struct EmailKey {
    public private (set) var keyId = 0
    public private (set) var email = ""
    public private (set) var isEnabled = false
    public private (set) var publicKey = ""
    public private (set) var sortOrder = 0
    
    public init(dict: [String: Any]) {
        keyId = dict["id"] as? Int ?? 0
        email = dict["email"] as? String ?? ""
        isEnabled = dict["is_enabled"] as? Bool ?? false
        publicKey = dict["public_key"] as? String ?? ""
        sortOrder = dict["sort_order"] as? Int ?? 0
    }
}

public struct EmailsKeys {
    public private (set) var encrypt = false
    public private (set) var keys = [EmailKey]()
    public private (set) var pgpKeys: [PGPKey] = []
    
    public init(dict: [String : Any]) {
        encrypt = dict["encrypt"] as? Bool ?? false
        if let keysArray = dict["keys"] as? [[String: Any]] {
            keys = keysArray.map({ EmailKey(dict: $0)})
        }
    }
    
    public mutating func updatePGPkeys(by key: PGPKey?) {
        if let key = key {
            self.pgpKeys.append(key)
        }
    }
}
