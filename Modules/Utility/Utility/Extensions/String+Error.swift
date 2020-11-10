//
//  String+Error.swift
//  CTemplar
//
//  Created by Majid Hussain on 10/05/2020.
//  Copyright © 2020 CTemplar. All rights reserved.
//

import Foundation

public extension String {
    func isSignatureDecodingError() -> Bool{
        if self.lowercased() == "error decoding signature." {
            return true
        }
        return false
    }
}
