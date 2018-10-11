//
//  EmailMessagesList.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 09.10.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation

struct EmailMessagesList {
    
    var next: String? = nil
    var pageConut: Int? = nil
    var previous: String? = nil
    var messagesList : Array<EmailMessage>? = nil
    var totalCount: Int? = nil
    
    init() {
        
    }
    
    init(dictionary: [String: Any]) {
        
        self.next = dictionary["next"] as? String
        self.pageConut = dictionary["page_count"] as? Int
        self.previous = dictionary["previous"] as? String
        
        if let resultsArray = dictionary["results"] as? Array<Any> {
            self.messagesList = self.parsResultsFromList(array: resultsArray)
        }
        
        self.totalCount = dictionary["total_count"] as? Int
    }
    
    func parsResultsFromList(array: Array<Any>) -> Array<EmailMessage>{
        
        var objectsArray: Array<EmailMessage> = []
        
        for object in array {            
            if let objectDictionary = object as? Dictionary<String, Any> {//[String : Any] {
                let messageResult = EmailMessage(dictionary: objectDictionary)
                objectsArray.append(messageResult)
            }
        }
        
        return objectsArray
    }
}
