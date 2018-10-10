//
//  PGPService.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 01.10.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import ObjectivePGP


// Generate new key
let key1 = KeyGenerator().generate(for: "marcin@krzyzanowskim.com", passphrase: nil)
let key2 = KeyGenerator().generate(for: "fran@krzyzanowskim.com", passphrase: nil)

class PGPService {
    
    let keyring = Keyring()
    
    func encrypt(data: Data) -> Data? {
        
        let encryptedBin = try! ObjectivePGP.encrypt(data, addSignature: false, using: [key1, key2])
        let encrypted = Armor.armored(encryptedBin, as: .message)
        print(encrypted)
        
        let signatureBin = try! ObjectivePGP.sign(encryptedBin, detached: true, using: [key1])
        let signature = Armor.armored(signatureBin, as: .signature)
        print(signature)
        
        try! ObjectivePGP.verify(encryptedBin, withSignature: signatureBin, using: [key1])
        
        return encryptedBin
    }
    
    func decrypt(encryptedData: Data) -> Data? {
        
        if Armor.isArmoredData(encryptedData)  {
            print("encryptedData is armored")
        }
        
        //print("encryptedData Array: \(Array(encryptedData))")
        
        let password : String = "test1234" //"admin1234"//"test1234" //temp

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
    
    //MARK: - Keys
    
    func generateUserPGPKeys(userName: String, password: String) -> UserPGPKey {
        
        let mainPgpKey = self.generatePGPKey(userName: userName, password: password)
        
        self.savePGPKey(pgpKey: mainPgpKey)
        
        let userPGPKey = UserPGPKey.init(pgpService: self, pgpKey: mainPgpKey)
        
        return userPGPKey
    }
    
    func generatePGPKey(userName: String, password: String) -> Key {
        
        let pgpKey = KeyGenerator().generate(for: userName, passphrase: password)
        // <PGPKey: 0x600002ae0800>, publicKey: DAF8551361A84672, secretKey: DAF8551361A84672
        //print("generate publicKey:", pgpKey)
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
        
        let keyRingFileUrl = getDocumentsDirectory().appendingPathComponent(k_keyringFileName)
        
        do {
            try keyring.export().write(to: keyRingFileUrl)
        }  catch {
            print("save PGP Key Error")
        }
        
        print("save PGP Key:", pgpKey)
    }
    
    func getStoredPGPKeys() -> [Key]? {
        
        let keyRingFileUrl = getDocumentsDirectory().appendingPathComponent(k_keyringFileName)
        
        guard let keys = try? ObjectivePGP.readKeys(fromPath: keyRingFileUrl.path) else {return nil}
        print("get stored PGP key:", keys)
        
        return keys
    }
    
    func readPGPKeysFromString(key : String) -> [Key]? {
        
        guard let encryptedData = try? Armor.readArmored(key) else {return nil}
        //print("read encryptedData", encryptedData)
        
        guard let keys = try? ObjectivePGP.readKeys(from: encryptedData) else {return nil}
        print("read keys from string", keys)
        
        return keys
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}
