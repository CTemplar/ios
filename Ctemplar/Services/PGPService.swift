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
}
