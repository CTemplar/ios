//
//  Contact.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 15.11.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import UIKit

struct Contact: Hashable {
    
    var email : String? = nil
    var contactName : String? = nil
    var contactID : Int? = nil
    var phone : String? = nil
    var address : String? = nil
    var note : String? = nil
    var isEncrypted : Bool? = nil
    var emailHash : String? = nil
    var encryptedData : String? = nil
    
    init() {
        
    }
    
    init(dictionary: [String: Any]) {
        
        self.email = dictionary["email"] as? String
        self.contactName = dictionary["name"] as? String
        self.contactID = dictionary["id"] as? Int
        self.phone = dictionary["phone"] as? String
        self.address = dictionary["address"] as? String
        self.note = dictionary["note"] as? String
        self.isEncrypted = dictionary["is_encrypted"] as? Bool
        self.emailHash = dictionary["email_hash"] as? String
        self.encryptedData = dictionary["encrypted_data"] as? String
        
        if self.isEncrypted ?? false {
            if let unwrappedData = self.encryptedData {
                //let dictionary = self.decryptContactData(encryptedData: unwrappedData)
                //self.setup(encryptedDictionary: dictionary)
            }
        }
    }
    
    init(encryptedDictionary: [String: Any]) {
        
        self.email = encryptedDictionary["email"] as? String
        self.contactName = encryptedDictionary["name"] as? String
        self.contactID = encryptedDictionary["id"] as? Int
        self.phone = encryptedDictionary["phone"] as? String
        self.address = encryptedDictionary["address"] as? String
        self.note = encryptedDictionary["note"] as? String
        self.isEncrypted = encryptedDictionary["is_encrypted"] as? Bool
        self.emailHash = encryptedDictionary["email_hash"] as? String
        self.encryptedData = encryptedDictionary["encrypted_data"] as? String
    }
    
    func decryptContactData(encryptedData: String) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let pgpService = appDelegate.applicationManager.pgpService
        
        let queue = DispatchQueue.global(qos: .userInitiated)
        
        queue.async {
            
            let decryptedContent = pgpService.decryptMessage(encryptedContet: encryptedData)
            DispatchQueue.main.async {
                //print("decryptedContent:", decryptedContent)
                let dictionary = self.convertStringToDictionary(text: decryptedContent)
                //self.setup(encryptedDictionary: dictionary)                
            }
        }
        
    }
    
    func convertStringToDictionary(text: String) -> [String:Any] {
        
        var dicitionary = [String:Any]()
        
        if let data = text.data(using: String.Encoding.utf8) {
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:Any] {
                    print("convertStringToDictionary:", json as Any)
                    dicitionary = json
                }
                return dicitionary
                
            } catch {
                print("convertStringToDictionary: Something went wrong")
                return dicitionary
            }
        }
        
        return dicitionary
    }
}

