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
    static let baseUrl = "https://devapi.ctemplar.net" // "https://devapi.ctemplar.net"
    #else
    static let baseUrl =  "https://api.ctemplar.com"
    #endif
}
