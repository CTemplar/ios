//
//  PGPKey.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 08.10.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import ObjectivePGP

struct UserPGPKey {
    
    var privateKey: String? = nil
    var publicKey: String? = nil
    var fingerprint: String? = nil
    
    
    init() {
        
    }
    
    init(pgpService: PGPService, pgpKey: Key) {
        
        self.privateKey = pgpService.generateArmoredPrivateKey(pgpKey: pgpKey)
        self.publicKey = pgpService.generateArmoredPublicKey(pgpKey: pgpKey)
        self.privateKey = pgpService.fingerprintForKey(pgpKey: pgpKey)
        
    }
}
