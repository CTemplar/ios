//
//  Captcha.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 19/08/2019.
//  Copyright © 2019 CTemplar. All rights reserved.
//

import Foundation

struct Captcha {
    
    var captchaImageUrl : String? = nil
    var captchaKey : String? = nil
    
    init() {
        
    }
    
    init(dictionary: [String: Any]) {
        
        self.captchaImageUrl = dictionary["captcha_image"] as? String
        self.captchaKey = dictionary["captcha_key"] as? String
    }
}
