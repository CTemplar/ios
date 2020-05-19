//
//  PGPKey.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 08.10.2018.
//  Copyright © 2018 CTemplar. All rights reserved.
//

import Foundation
import ObjectivePGP

struct UserPGPKey {
    let privateKey: String
    let publicKey: String
    let fingerprint: String
}
