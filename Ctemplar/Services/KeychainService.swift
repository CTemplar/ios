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
        
        var keyName: String {
            guard let identifier = Bundle.main.bundleIdentifier else {
                fatalError()
            }
            return identifier + "." + self.rawValue
        }
    }
    
    let keychain = KeychainSwift()
    
    func saveToken(token: String) {
        
        keychain.set(token, forKey: Consts.token.keyName)
        keychain.set(Date().description, forKey: Consts.tokenSavedTime.keyName)
    }
    
    func getToken() -> String {
        
        guard let token = keychain.get(Consts.token.keyName) else {
            return ""
        }
        
        return token
    }
    
    func getTokenSavedTime() -> String {
        
        //var tokenSavedDate : Date?
        
        guard let tokenSavedTime = keychain.get(Consts.tokenSavedTime.keyName) else {
            return ""
        }
        
        print("tokenSavedTime", tokenSavedTime)
        
        return tokenSavedTime
    }
    
    func saveUsername(name: String) {
        
        keychain.set(name, forKey: Consts.username.keyName)
    }
    
    func getUserName() -> String {
        
        guard let username = keychain.get(Consts.username.keyName) else {
            return ""
        }
        
        return username
    }
    
    func savePassword(password: String) {
        
        keychain.set(password, forKey: Consts.password.keyName)
    }
    
    func getPassword() -> String {
        
        guard let password = keychain.get(Consts.password.keyName) else {
            return ""
        }
        
        return password
    }
    
    func getTwoFAcode() -> String {
        
        guard let code = keychain.get(Consts.twoFAcode.keyName) else {
            return ""
        }
        
        return code
    }
    
    func saveUserCredentials(userName: String, password: String) {
        
        saveUsername(name: userName)
        savePassword(password: password)
    }
    
    func saveAPNDeviceToken(_ token: String) {
           
        keychain.set(token, forKey: Consts.apnToken.keyName)
    }
       
    func getAPNDeviceToken() -> String {
           
        guard let username = keychain.get(Consts.apnToken.keyName) else {
            return ""
        }
           
        return username
    }
    
    func deleteUserCredentialsAndToken() {
        
        keychain.delete(Consts.token.keyName)
        keychain.delete(Consts.tokenSavedTime.keyName)
        keychain.delete(Consts.username.keyName)
        keychain.delete(Consts.password.keyName)
        keychain.delete(Consts.apnToken.keyName)
    }
}

