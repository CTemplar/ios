import Foundation
import KeychainSwift

public class KeychainService {
    public enum Consts: String {
        case token = "token"
        case tokenSavedTime = "tokenSavedTime"
        case username = "username"
        case password = "password"
        case twoFAenabled = "twoFAenabled"
        case apnToken = "apnToken"
        case rememberMe = "rememberMe"
        
        public var keyName: String {
            guard let identifier = Bundle.main.bundleIdentifier else {
                fatalError()
            }
            return identifier + "." + self.rawValue
        }
    }
    
    public let keychain = KeychainSwift()
    
    public func saveToken(token: String) {
        keychain.set(token, forKey: Consts.token.keyName)
        keychain.set(Date().description, forKey: Consts.tokenSavedTime.keyName)
    }
    
    public func getToken() -> String {
        guard let token = keychain.get(Consts.token.keyName) else {
            return ""
        }
        return token
    }
    
    public func getTokenSavedTime() -> String {
        guard let tokenSavedTime = keychain.get(Consts.tokenSavedTime.keyName) else {
            return ""
        }
        DPrint("tokenSavedTime", tokenSavedTime)
        return tokenSavedTime
    }
    
    public func saveUsername(name: String) {
        keychain.set(name, forKey: Consts.username.keyName)
    }
    
    public func getUserName() -> String {
        guard let username = keychain.get(Consts.username.keyName) else {
            return ""
        }
        return username
    }
    
    public func savePassword(password: String) {
        keychain.set(password, forKey: Consts.password.keyName)
    }
    
    public func getPassword() -> String {
        guard let password = keychain.get(Consts.password.keyName) else {
            return ""
        }
        return password
    }
    
    public func saveTwoFAvalue(isTwoFAenabled: Bool) {
        keychain.set(isTwoFAenabled, forKey: Consts.twoFAenabled.keyName)
    }
    
    public func getTwoFAstatus() -> Bool {
        guard let code = keychain.getBool(Consts.twoFAenabled.keyName) else {
            return true
        }
        return code
    }
    
    public func saveUserCredentials(userName: String, password: String) {
        saveUsername(name: userName)
        savePassword(password: password)
    }
    
    public func saveRememberMeValue(rememberMe: Bool) {
        keychain.set(rememberMe, forKey: Consts.rememberMe.keyName)
    }
    
    public func getRememberMeValue() -> Bool {
        if let rememberMe = keychain.getBool(Consts.rememberMe.keyName) {
            return rememberMe
        }
        return false
    }
    
    public func saveAPNDeviceToken(_ token: String) {
        keychain.set(token, forKey: Consts.apnToken.keyName)
    }
       
    public func getAPNDeviceToken() -> String {
        guard let apnsToken = keychain.get(Consts.apnToken.keyName) else {
            return ""
        }
        return apnsToken
    }
    
    public func deleteUserCredentialsAndToken() {
        keychain.delete(Consts.token.keyName)
        keychain.delete(Consts.tokenSavedTime.keyName)
        keychain.delete(Consts.username.keyName)
        keychain.delete(Consts.password.keyName)
        keychain.delete(Consts.twoFAenabled.keyName)
        keychain.delete(Consts.rememberMe.keyName)
    }
}
