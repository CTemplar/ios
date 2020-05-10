//
//  FoldersList.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 06.11.2018.
//  Copyright © 2018 CTemplar. All rights reserved.
//

import Foundation

struct FolderList {
    
    var next: String? = nil
    var pageConut: Int? = nil
    var previous: String? = nil
    var foldersList : Array<Folder>? = nil
    var totalCount: Int? = nil
    
    init() {
        
    }
    
    init(dictionary: [String: Any]) {
        
        self.next = dictionary["next"] as? String
        self.pageConut = dictionary["page_count"] as? Int
        self.previous = dictionary["previous"] as? String
        
        if let resultsArray = dictionary["results"] as? Array<Any> {
            self.foldersList = self.parsResultsFromList(array: resultsArray)
        }
        
        self.totalCount = dictionary["total_count"] as? Int
    }
    
    func parsResultsFromList(array: Array<Any>) -> Array<Folder>{
        
        var objectsArray: Array<Folder> = []
        
        for object in array {
            if let objectDictionary = object as? Dictionary<String, Any> {
                let folderResult = Folder(dictionary: objectDictionary)
                objectsArray.append(folderResult)
            }
        }
        
        return objectsArray
    }
}
