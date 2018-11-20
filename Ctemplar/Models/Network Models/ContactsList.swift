//
//  ContactsList.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 20.11.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation

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
            //self.parsResults(array: resultsArray)
            self.contactsList = self.parsResultsFromList(array: resultsArray)            
        }
    }
    /*
    mutating func parsResults(array: Array<Any>) {
        
        var localContactsList : Array<Contact>? = []
        
        for item in array {
            
            let dictionary = item as! Dictionary<String, Any>
            print("dict keys:", dictionary.keys)
            
            for (key, value) in dictionary {
                
                if key == "contacts" {
                    let array = value as! Array<Any>
                    for item in array {
                        let contactDict = item as! [String : Any]
                        let contact = Contact(dictionary: contactDict)
                        localContactsList?.append(contact)
                    }
                }
            }
        }
        
        self.contactsList = localContactsList
    }*/
    
    func parsResultsFromList(array: Array<Any>) -> Array<Contact>{
        
        var objectsArray: Array<Contact> = []
        
        for object in array {
            if let objectDictionary = object as? Dictionary<String, Any> {
                let contactsResult = Contact(dictionary: objectDictionary)
                objectsArray.append(contactsResult)
            }
        }
        
        return objectsArray
    }
}
