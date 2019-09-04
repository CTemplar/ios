//
//  ContactsList.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 20.11.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import UIKit

struct ContactsList {
    
    var totalCount: Int? = nil
    var next: String? = nil
    var pageConut: Int? = nil
    var previous: String? = nil
    
    var contactsList : Array<Contact>? = nil
    
    init() {
        
    }
    
    init(dictionary: [String: Any]) {
        
        self.totalCount = dictionary["total_count"] as? Int
        self.next = dictionary["next"] as? String
        self.pageConut = dictionary["page_count"] as? Int
        self.previous = dictionary["previous"] as? String
        
        if let resultsArray = dictionary["results"] as? Array<Any> {        
            self.contactsList = self.parsResultsFromList(array: resultsArray)            
        }
    }
    
    func parsResultsFromList(array: Array<Any>) -> Array<Contact>{
        
        var objectsArray: Array<Contact> = []
        
        for object in array {
            if let objectDictionary = object as? Dictionary<String, Any> {
                let contactsResult = Contact(dictionary: objectDictionary)
                
                if contactsResult.isEncrypted! {
                    if let unwrappedData = contactsResult.encryptedData {
                        let encryptedDictionary = self.decryptContactData(encryptedData: unwrappedData)
                        let encryptedContact = Contact(encryptedDictionary: encryptedDictionary)
                        objectsArray.append(encryptedContact)
                    }
                } else {                
                    objectsArray.append(contactsResult)
                }
            }
        }
        
        return objectsArray
    }
    
    func decryptContactData(encryptedData: String) -> [String:Any] {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let pgpService = appDelegate.applicationManager.pgpService
        
        //let queue = DispatchQueue.global(qos: .userInitiated)
        
       // queue.async {
            
            let decryptedContent = pgpService.decryptMessage(encryptedContet: encryptedData)
            //DispatchQueue.main.async {
                let dictionary = self.convertStringToDictionary(text: decryptedContent)
                return dictionary
                
            //}
       // }
    }
    
    func convertStringToDictionary(text: String) -> [String:Any] {
        
        var dicitionary = [String:Any]()
        
        if let data = text.data(using: String.Encoding.utf8) {
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:Any] {
                   // print("convertStringToDictionary:", json as Any)
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
