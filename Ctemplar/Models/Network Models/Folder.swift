//
//  Folder.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 06.11.2018.
//  Copyright © 2018 CTemplar. All rights reserved.
//

import Foundation

struct Folder {
    
    var color : String? = nil
    var folderName : String? = nil
    var folderID : Int? = nil
    
    init() {
        
    }
    
    init(dictionary: [String: Any]) {
        
        self.color = dictionary["color"] as? String
        self.folderName = dictionary["name"] as? String
        self.folderID = dictionary["id"] as? Int
    }
}
