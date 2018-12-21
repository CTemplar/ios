//
//  UserMyself.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 15.11.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
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
    
    var username : String? = nil
    
    var isTrial : Bool? = nil
    var isPrime : Bool? = nil
        
    init() {
        
    }
    
    init(dictionary: [String: Any]) {
        
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
                
                if key == "is_trial" {
                    self.isTrial = value as? Bool
                }
                
                if key == "is_prime" {
                    self.isPrime = value as? Bool
                }
                
                if key == "settings" {
                    print("settings value:", value)
                }
            }
        }
        
        self.mailboxesList = localMailboxesList
        self.foldersList = localFoldersList
        self.contactsList = localContactsList
    }
}

/*
 "allocated_storage" = 204800;
 autoresponder = 0;
 "default_font" = "<null>";
 "display_name" = dmitry8;
 "domain_count" = 0;
 "email_count" = 1;
 "emails_per_page" = 20;
 "embed_content" = 1;
 "from_address" = "<null>";
 id = 173;
 "is_pending_payment" = 0;
 language = English;
 newsletter = 1;
 "recovery_email" = "";
 "recurrence_billing" = 0;
 "redeem_code" = "<null>";
 "save_contacts" = 1;
 "show_snippets" = 1;
 "stripe_customer_code" = "<null>";
 timezone = "<null>";
 "used_storage" = 14172;
 
 */
