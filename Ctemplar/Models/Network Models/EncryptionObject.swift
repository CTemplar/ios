//
//  EncryptionObject.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 03.12.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation

struct EncryptionObject: Encodable {
    
    var created : String? = nil
    var expires : String? = nil
    var encryptionObjectID : Int? = nil
    var messageID : Int? = nil
    var password : String? = nil
    var passwordHint : String? = nil
    var privateKey : String? = nil
    var publicKey : String? = nil
    var randomSecret : String? = nil
    
    init() {
        
    }
    
    init(dictionary: [String: Any]) {
        
        self.created = dictionary["created"] as? String
        self.expires = dictionary["expires"] as? String
        self.encryptionObjectID = dictionary["id"] as? Int
        self.messageID = dictionary["message"] as? Int
        self.password = dictionary["password"] as? String
        self.passwordHint = dictionary["password_hint"] as? String
        self.privateKey = dictionary["private_key"] as? String
        self.publicKey = dictionary["public_key"] as? String
        self.randomSecret = dictionary["random_secret"] as? String
    }
    
    init(password: String, passwordHint: String) {
        
        self.password = password
        self.passwordHint = passwordHint
    }
    
    mutating func setPGPKeys(publicKey: String, privateKey: String) {
        
        self.publicKey = publicKey
        self.privateKey = privateKey
    }
    
    func encodeToJson() -> String {
    
        var encodedString : String = ""
        
        let encoder = JSONEncoder()
        
        let data = try? encoder.encode(self)
        
        if (data != nil) {
            encodedString = String(data: data!, encoding: .utf8)!
            print("Encoded:", encodedString)
        } else {
            print("erorr Encoding")
        }
        
        return encodedString
    }
    
    func toDictionary() -> [String : String] {
        
        return ["password"          : self.password ?? "",
                "password_hint"     : self.passwordHint ?? "",
                "created"           : self.created ?? "",
                "expires"           : self.expires ?? "", //formatDateToStringExpirationTime
                "id"                : self.encryptionObjectID?.description ?? "",
                "message"           : self.messageID?.description ?? "",
                "private_key"       : self.privateKey ?? "",
                "public_key"        : self.publicKey ?? "",
                "random_secret"     : self.randomSecret ?? ""
                ]
    }
    
    func toShortDictionary() -> [String : String] {
        
        return ["password"          : self.password ?? "",
                "password_hint"     : self.passwordHint ?? "",
        ]
    }
}
