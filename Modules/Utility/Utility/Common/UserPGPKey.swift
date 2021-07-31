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

public struct PurchaseModel {
    public var customer_identifier:String?
    public var payment_identifier:String?
    public var payment_method:String?
    public var payment_type:String?
    public var plan_type:String?

    public init(customer_identifier: String, payment_identifier: String, payment_method: String, payment_type: String, plan_type: String) {
        self.customer_identifier = customer_identifier
        self.payment_method = payment_method
        self.payment_identifier = payment_identifier
        self.payment_type = payment_type
        self.plan_type = plan_type
    }
    
}
