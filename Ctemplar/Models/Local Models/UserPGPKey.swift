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
        
        self.privateKey = pgpService.exportArmoredPrivateKey(pgpKey: pgpKey)
        self.publicKey = pgpService.exportArmoredPublicKey(pgpKey: pgpKey)
        self.fingerprint = pgpService.fingerprintForKey(pgpKey: pgpKey)
        
    }
}
