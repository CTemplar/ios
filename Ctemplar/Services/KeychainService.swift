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
        case username = "username"
        case password = "password"
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
    
    func saveUsername(name: String) {
        
        keychain.set(name, forKey: Consts.username.rawValue)
    }
    
    func getUserName() -> String {
        
        guard let token = keychain.get(Consts.username.rawValue) else {
            return ""
        }
        
        return token
    }
    
    func savePassword(password: String) {
        
        keychain.set(password, forKey: Consts.password.rawValue)
    }
    
    func getPassword() -> String {
        
        guard let token = keychain.get(Consts.password.rawValue) else {
            return ""
        }
        
        return token
    }
    
    func saveUserCredentials(userName: String, password: String) {
        
        saveUsername(name: userName)
        savePassword(password: password)
    }
    
    func deleteUserCredentialsAndToken() {
        
        keychain.delete(Consts.token.rawValue)
        keychain.delete(Consts.username.rawValue)
        keychain.delete(Consts.password.rawValue)
    }
}

