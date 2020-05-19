//
//  String+Error.swift
//  Ctemplar
//
//  Created by Majid Hussain on 10/05/2020.
//  Copyright © 2020 Ctemplar. All rights reserved.
//

import Foundation

extension String {
    func isSignatureDecodingError() -> Bool{
        if self.lowercased() == k_signature_decoding_issue {
            return true
        }
        return false
    }
}
