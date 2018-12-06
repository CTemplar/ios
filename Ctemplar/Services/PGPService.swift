//
//  PGPService.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 01.10.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import UIKit
import ObjectivePGP

class PGPService {
    
    //let keyring = Keyring()
    //let keychainService = KeychainService()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var keyring : Keyring!
    var keychainService: KeychainService!
    
    func initialize() {
        
        self.keyring = Keyring()
        self.keychainService = appDelegate.applicationManager.keychainService
    }
    
    func encodeString(message: String) -> Data {
        
        return Data(message.utf8)
    }
    
    func encrypt(data: Data) -> String? {
        
        if let keys = getStoredPGPKeys() {
            
            //let encryptedBin = try! ObjectivePGP.encrypt(data, addSignature: false, using: keys)
            guard let encryptedBin = try? ObjectivePGP.encrypt(data, addSignature: false, using: keys) else {return ""}
            
            let encrypted = Armor.armored(encryptedBin, as: .message)
            
            return encrypted
        }
        
        return ""
    }
    
    func encrypt(data: Data, keys: Array<Key>) -> String? {
        
        guard let encryptedBin = try? ObjectivePGP.encrypt(data, addSignature: false, using: keys) else {return ""}
            
        let encrypted = Armor.armored(encryptedBin, as: .message)
            
        return encrypted
    }
    
    func decrypt(encryptedData: Data) -> Data? {
        
        if Armor.isArmoredData(encryptedData)  {
            //print("encryptedData is armored")
        }

        let password = keychainService.getPassword()

        if let keys = getStoredPGPKeys() {
            
            guard let decryptedData = try? ObjectivePGP.decrypt(encryptedData, andVerifySignature: true, using: keys, passphraseForKey: {(key) -> String? in
                return password
            }) else {return nil}
            
            return decryptedData
        }
        
        return nil
    }
    
    func decodeData(decryptedData: Data) -> String {
        
        return String(decoding: decryptedData, as: UTF8.self)
    }
    
    func decryptMessage(encryptedContet: String) -> String {
        
        if let contentData = encryptedContet.data(using: .ascii) {
            if let decodedData = self.decrypt(encryptedData: contentData) {
                let decryptedMessage = self.decodeData(decryptedData: decodedData)
                //print("decryptedMessage:", decryptedMessage)
                return decryptedMessage
            } else {
                print("decrypting failed")
                return ""
            }
        }
        
        return ""
    }
    
    //MARK: - Keys
    
    func generateUserPGPKeys(userName: String, password: String) -> UserPGPKey {
        
        let mainPgpKey = self.generatePGPKey(userName: userName, password: password)
        
        self.savePGPKey(pgpKey: mainPgpKey)
        
        let userPGPKey = UserPGPKey.init(pgpService: self, pgpKey: mainPgpKey)
        
        return userPGPKey
    }
    
    func generatePGPKey(userName: String, password: String) -> Key {
        
        let pgpKey = KeyGenerator().generate(for: userName, passphrase: password)
        print("generate keyID:", pgpKey.publicKey?.keyID as Any)
        print("generate fingerprint:", pgpKey.publicKey?.fingerprint as Any)
        
        return pgpKey
    }
    
    func generateArmoredPrivateKey(pgpKey: Key) -> String? {
        
        guard let privateKey = try? pgpKey.export(keyType: .secret) else {return nil}
        let armoredPrivateKey = Armor.armored(privateKey, as: .secretKey)
        
        print("armoredPrivateKey:", armoredPrivateKey)
        
        return armoredPrivateKey
    }
    
    func generateArmoredPublicKey(pgpKey: Key) -> String? {
        
        guard let publicKey = try? pgpKey.export(keyType: .public) else {return nil}
        let armoredPublicKey = Armor.armored(publicKey, as: .publicKey)
        
        print("armoredPublicKey:", armoredPublicKey)
        
        return armoredPublicKey
    }
    
    func fingerprintForKey(pgpKey: Key) -> String? {
        
        if let fingerprint = pgpKey.publicKey?.fingerprint.description() {
            return fingerprint
        }
        
        return nil
    }
    
    func savePGPKey(pgpKey: Key) {
        
        keyring.import(keys: [pgpKey])
        
        let keyRingFileUrl = getApplicationSupportDirectoryDirectory().appendingPathComponent(k_keyringFileName)
        
        do {
            try keyring.export().write(to: keyRingFileUrl)
        }  catch {
            print("save PGP Key Error")
        }
        
        print("save PGP Key:", pgpKey)
    }
    
    func savePGPKeys(pgpKeys: [Key]) {
        
        keyring.import(keys: pgpKeys)
        
        let keyRingFileUrl = getApplicationSupportDirectoryDirectory().appendingPathComponent(k_keyringFileName)
        
        do {
            try keyring.export().write(to: keyRingFileUrl)
        }  catch {
            print("save PGP Keys Error")
        }
        
        print("save PGP Keys:", pgpKeys)
    }
    
    func getStoredPGPKeys() -> [Key]? {
        
        let keyRingFileUrl = getApplicationSupportDirectoryDirectory().appendingPathComponent(k_keyringFileName)
        
        guard let keys = try? ObjectivePGP.readKeys(fromPath: keyRingFileUrl.path) else {return nil}
        print("get stored PGP keys:", keys)
        
        return keys
    }
    
    func readPGPKeysFromString(key : String) -> [Key]? {
        
        guard let encryptedData = try? Armor.readArmored(key) else {return nil}
        //print("read encryptedData", encryptedData)
        
        guard let keys = try? ObjectivePGP.readKeys(from: encryptedData) else {return nil}
        print("read keys from string", keys)
        
        return keys
    }
    
    func extractAndSavePGPKeyFromString(key: String) {
        
        if let pgpKeys = self.readPGPKeysFromString(key: key) {
            self.savePGPKeys(pgpKeys: pgpKeys)
        } else {
            print("can not read keys from string!!!")
        }
    }
    
    func deleteStoredPGPKeys() {
        
        keyring.deleteAll()
        
        let keyRingFileUrl = getApplicationSupportDirectoryDirectory().appendingPathComponent(k_keyringFileName)
        
        /*
        do {
            try keyring.export().write(to: keyRingFileUrl)
        }  catch {
            print("delete PGP Key Error")
        }*/
        
        let fileManager = FileManager.default
        
        do {
            try fileManager.removeItem(atPath: keyRingFileUrl.path)
        }
        catch let error as NSError {
            print("delete keyring file Error: \(error)")
        }
        
        print("delete PGP Key")
    }
    
    func getApplicationSupportDirectoryDirectory() -> URL {
        
        let paths = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask) //.documentDirectory
        return paths[0]
    }
}
