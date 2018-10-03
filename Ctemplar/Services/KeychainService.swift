//
//  KeychainService.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 03.10.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import KeychainSwift

class KeychainService
{
    enum Consts: String {
        case token = "token"
    }
    
    let keychain = KeychainSwift()
    
    func saveToken(token: String) {
        
        keychain.set(token, forKey: Consts.token.rawValue)
    }
    
    func getToken() -> String {
        
        guard let token = keychain.get(Consts.token.rawValue) else {
            return ""
        }
        
        return token
    }
}

