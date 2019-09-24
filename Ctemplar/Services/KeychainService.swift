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
        case tokenSavedTime = "tokenSavedTime"
        case username = "username"
        case password = "password"
        case twoFAcode = "twoFAcode"
        case apnToken = "apnToken"
    }
    
    let keychain = KeychainSwift()
    
    func saveToken(token: String) {
        
        keychain.set(token, forKey: Consts.token.rawValue)
        keychain.set(Date().description, forKey: Consts.tokenSavedTime.rawValue)
    }
    
    func getToken() -> String {
        
        guard let token = keychain.get(Consts.token.rawValue) else {
            return ""
        }
        
        return token
    }
    
    func getTokenSavedTime() -> String {
        
        //var tokenSavedDate : Date?
        
        guard let tokenSavedTime = keychain.get(Consts.tokenSavedTime.rawValue) else {
            return ""
        }
        
        print("tokenSavedTime", tokenSavedTime)
        
        return tokenSavedTime
    }
    
    func saveUsername(name: String) {
        
        keychain.set(name, forKey: Consts.username.rawValue)
    }
    
    func getUserName() -> String {
        
        guard let username = keychain.get(Consts.username.rawValue) else {
            return ""
        }
        
        return username
    }
    
    func savePassword(password: String) {
        
        keychain.set(password, forKey: Consts.password.rawValue)
    }
    
    func getPassword() -> String {
        
        guard let password = keychain.get(Consts.password.rawValue) else {
            return ""
        }
        
        return password
    }
    
    func getTwoFAcode() -> String {
        
        guard let code = keychain.get(Consts.twoFAcode.rawValue) else {
            return ""
        }
        
        return code
    }
    
    func saveUserCredentials(userName: String, password: String) {
        
        saveUsername(name: userName)
        savePassword(password: password)
    }
    
    func saveAPNDeviceToken(_ token: String) {
           
        keychain.set(token, forKey: Consts.apnToken.rawValue)
    }
       
    func getAPNDeviceToken() -> String {
           
        guard let username = keychain.get(Consts.apnToken.rawValue) else {
            return ""
        }
           
        return username
    }
    
    func deleteUserCredentialsAndToken() {
        
        keychain.delete(Consts.token.rawValue)
        keychain.delete(Consts.tokenSavedTime.rawValue)
        keychain.delete(Consts.username.rawValue)
        keychain.delete(Consts.password.rawValue)
        keychain.delete(Consts.apnToken.rawValue)
    }
}

