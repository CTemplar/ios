//
//  UnreadMessagesCounter.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 08.11.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation

struct UnreadMessagesCounter {
    
    var folderName: String? = nil
    var unreadMessagesCount: Int? = nil
    
    init() {
        
    }
    
    init(key: String, value: Any) {
        
        self.folderName = key
        self.unreadMessagesCount = value as? Int
    }
}
