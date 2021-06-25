import Foundation

public struct UserPGPKey {
    public let privateKey: String
    public let publicKey: String
    public let fingerprint: String
}

public struct AliasModel {
    public var email:String?
    public var privateKey:String?
    public var publicKey:String?
    public var fingerprint:String?
    
    public init(email: String, privateKey: String, publicKey: String, fingerprint: String) {
        self.email = email
        self.privateKey = privateKey
        self.publicKey = publicKey
        self.fingerprint = fingerprint
    }
    
}

public struct NewKeyModel {
    public var password:String?
    public var privateKey:String?
    public var publicKey:String?
    public var fingerprint:String?
    public var keyType:String?
    public var mailboxID:Int?
    
    public init(password: String, privateKey: String, publicKey: String, fingerprint: String, mailboxID: Int, keyType:String) {
        self.password = password
        self.privateKey = privateKey
        self.publicKey = publicKey
        self.fingerprint = fingerprint
        self.keyType = keyType
        self.mailboxID = mailboxID
    }
}
