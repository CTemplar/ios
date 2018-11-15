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
    
    var username : String? = nil
        
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
            }
        }
        
        self.mailboxesList = localMailboxesList
        self.foldersList = localFoldersList
    }
}
