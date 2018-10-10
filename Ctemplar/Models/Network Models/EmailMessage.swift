//
//  EmailMessage.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 09.10.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation

struct EmailMessage {
    
    var next: String? = nil
    var pageConut: Int? = nil
    var messageResultsList : Array<EmailMessageResult>? = nil
    var totalCount: Int? = nil
    
    init() {
        
    }
    
    init(dictionary: [String: Any]) {
        
        self.next = dictionary["next"] as? String
        self.pageConut = dictionary["page_count"] as? Int
        
        if let resultsArray = dictionary["results"] as? Array<Any> {
            self.messageResultsList = self.parsResultsFromList(array: resultsArray)
        }
        
        self.totalCount = dictionary["total_count"] as? Int
    }
    
    func parsResultsFromList(array: Array<Any>) -> Array<EmailMessageResult>{
        
        var objectsArray: Array<EmailMessageResult> = []
        
        for object in array {            
            if let objectDictionary = object as? Dictionary<String, Any> {//[String : Any] {
                let messageResult = EmailMessageResult(dictionary: objectDictionary)
                objectsArray.append(messageResult)
            }
        }
        
        return objectsArray
    }
}
