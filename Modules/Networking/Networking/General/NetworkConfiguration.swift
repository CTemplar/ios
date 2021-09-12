//
//  NetworkConfiguration.swift
//  Ctemplar
//
//  Created by Roman K. on 12/6/19.
//  Copyright © 2019 CTemplar. All rights reserved.
//

import Foundation

public struct NetworkConfiguration {
    #if DEBUG
    // static let baseUrl = "https://devapi.ctemplar.net"
    static let baseUrl =  "https://api.ctemplar.com"
    #else
    static let baseUrl =  "https://api.ctemplar.com"//"https://devapi.ctemplar.net"//"https://api.ctemplar.com"
    #endif
}
