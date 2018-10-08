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
        
        let decryptedData = try! ObjectivePGP.decrypt(encryptedData, andVerifySignature: false, using: [key1])
        
        return decryptedData
    }
    
    //MARK: - Keys
    
    func generateUserPGPKeys(userName: String) -> UserPGPKey {
        
        let mainPgpKey = self.generatePGPKey(userName: userName)
        
        self.savePGPKey(pgpKey: mainPgpKey)
        
        let userPGPKey = UserPGPKey.init(pgpService: self, pgpKey: mainPgpKey)
        
        return userPGPKey
    }
    
    func generatePGPKey(userName: String) -> Key {
        
        let pgpKey = KeyGenerator().generate(for: userName, passphrase: nil)
        // <PGPKey: 0x600002ae0800>, publicKey: DAF8551361A84672, secretKey: DAF8551361A84672
        //print("generate publicKey:", pgpKey)
        print("generate keyID:", pgpKey.publicKey?.keyID as Any)
        print("generate fingerprint:", pgpKey.publicKey?.fingerprint as Any)
        
        return pgpKey
    }
    
    func generateArmoredPrivateKey(pgpKey: Key) -> String? {
        
        guard let privateKey = try? pgpKey.export(keyType: .public) else {return nil}
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
        
        let keyRingFileUrl = getDocumentsDirectory().appendingPathComponent("keyring.gpg")
        
        do {
            try keyring.export().write(to: keyRingFileUrl)
        }  catch {
            print("save privateKey Error")
        }
        
        print("save privateKey:", pgpKey)
        
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}
