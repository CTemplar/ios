//
//  PageResult.swift
//  CTemplar
//
//  Created by romkh on 19.12.2019.
//  Copyright © 2019 CTemplar. All rights reserved.
//

import Foundation

struct ContentPageResult<T: Codable>: Codable {
    let next: String?
    let previous: String?
    let pageCount: Int
    let totalCount: Int
    let results: T
    
    private enum CodingKeys: String, CodingKey {
        case results, next, previous
        case pageCount = "page_count"
        case totalCount = "total_count"
    }
}
