//
//  UserMyself.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 15.11.2018.
//  Copyright © 2018 CTemplar. All rights reserved.
//

import Foundation

struct UserMyself {
    
    var totalCount: Int? = nil
    var next: String? = nil
    var pageConut: Int? = nil
    var previous: String? = nil
    
    var mailboxesList : Array<Mailbox>? = nil
    var foldersList : Array<Folder>? = nil
    var contactsList : Array<Contact>? = nil
    var contactsWhiteList : Array<Contact>? = nil
    var contactsBlackList : Array<Contact>? = nil
    
    var username : String? = nil
    
    var isTrial : Bool? = nil
    var isPrime : Bool? = nil
    
    var settings : Settings = Settings()
        
    init() {
        
    }
    
    init(dictionary: [String: Any]) {
        
        //print("user:", dictionary)
        
        self.totalCount = dictionary["total_count"] as? Int
        self.next = dictionary["next"] as? String
        self.pageConut = dictionary["page_count"] as? Int
        self.previous = dictionary["previous"] as? String
        
        if let resultsArray = dictionary["results"] as? Array<Any> {
            self.parsResults(array: resultsArray)
        }
    }
    
    mutating func parsResults(array: Array<Any>) {
        
        var localMailboxesList : Array<Mailbox>? = []
        var localFoldersList : Array<Folder>? = []
        var localContactsList : Array<Contact>? = []
        var localWhiteContactsList : Array<Contact>? = []
        var localBlackContactsList : Array<Contact>? = []
        
        for item in array {
            
            let dictionary = item as! Dictionary<String, Any>
            print("dict keys:", dictionary.keys)
            
            for (key, value) in dictionary {
                if key == "mailboxes" {
                    let array = value as! Array<Any>
                    for item in array {
                        let mailboxDict = item as! [String : Any]
                        let mailbox = Mailbox(dictionary: mailboxDict)
                        localMailboxesList?.append(mailbox)
                    }
                }
                
                if key == "custom_folders" {
                    let array = value as! Array<Any>                    
                    for item in array {
                        let folderDict = item as! [String : Any]
                        let folder = Folder(dictionary: folderDict)
                        localFoldersList?.append(folder)
                    }
                }
                
                if key == "username" {
                    self.username = value as? String
                }
                
                if key == "contacts" {
                   let array = value as! Array<Any>
                    for item in array {
                        let contactDict = item as! [String : Any]
                        let contact = Contact(dictionary: contactDict)
                        localContactsList?.append(contact)
                    }
                }
                
                if key == "blacklist" {
                    let array = value as! Array<Any>
                    for item in array {
                        let contactDict = item as! [String : Any]
                        let contact = Contact(dictionary: contactDict)
                        localBlackContactsList?.append(contact)
                    }
                }
                
                if key == "whitelist" {
                    let array = value as! Array<Any>
                    for item in array {
                        let contactDict = item as! [String : Any]
                        let contact = Contact(dictionary: contactDict)
                        localWhiteContactsList?.append(contact)
                    }
                }
                
                if key == "is_trial" {
                    self.isTrial = value as? Bool
                }
                
                if key == "is_prime" {
                    self.isPrime = value as? Bool
                }
                
                if key == "settings" {                   
                    let settingsDict = value as! [String : Any]
                    self.settings = Settings(dictionary: settingsDict)
                }
            }
        }
        
        self.mailboxesList = localMailboxesList
        self.foldersList = localFoldersList
        self.contactsList = localContactsList
        self.contactsWhiteList = localWhiteContactsList
        self.contactsBlackList = localBlackContactsList
    }
}
