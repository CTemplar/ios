//
//  Mailbox.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 10.10.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation

struct Mailbox {
    
    var previous: String? = nil
    var totalCount: Int? = nil
    var next: String? = nil
    var pageConut: Int? = nil
    var mailboxesResultsList : Array<MailboxResult>? = nil
    
    
    init() {
        
    }
    
    init(dictionary: [String: Any]) {
        
        self.previous = dictionary["previous"] as? String
        self.next = dictionary["next"] as? String
        self.totalCount = dictionary["total_count"] as? Int
        self.pageConut = dictionary["page_count"] as? Int
        
        if let resultsArray = dictionary["results"] as? Array<Any> {
            self.mailboxesResultsList = self.parsResultsFromList(array: resultsArray)
        }
    }
    
    func parsResultsFromList(array: Array<Any>) -> Array<MailboxResult>{
        
        var objectsArray: Array<MailboxResult> = []
        
        for object in array {
            if let objectDictionary = object as? Dictionary<String, Any> {//[String : Any] {
                let messageResult = MailboxResult(dictionary: objectDictionary)
                objectsArray.append(messageResult)
            }
        }
        
        return objectsArray
    }
}

/*
 results
 page_count
 previous
 total_count
 */
