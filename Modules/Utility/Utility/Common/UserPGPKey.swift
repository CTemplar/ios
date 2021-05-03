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
