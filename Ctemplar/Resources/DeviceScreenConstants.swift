//
//  DeviceScreenConstants.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 10.10.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import UIKit

struct Device {
    
    // iDevice detection code
    static let IS_IPAD              = UIDevice.current.userInterfaceIdiom == .pad
    static let IS_IPHONE            = UIDevice.current.userInterfaceIdiom == .phone
    static let IS_RETINA            = UIScreen.main.scale >= 2.0
    static let SCREEN_WIDTH         = Int(UIScreen.main.bounds.size.width)
    static let SCREEN_HEIGHT        = Int(UIScreen.main.bounds.size.height)
    static let SCREEN_MAX_LENGTH    = Int( max(SCREEN_WIDTH, SCREEN_HEIGHT) )
    static let SCREEN_MIN_LENGTH    = Int( min(SCREEN_WIDTH, SCREEN_HEIGHT) )
    static let IS_IPHONE_4_OR_LESS  = IS_IPHONE && SCREEN_MAX_LENGTH  < 568
    static let IS_IPHONE_5          = IS_IPHONE && SCREEN_MAX_LENGTH == 568
    static let IS_IPHONE_6          = IS_IPHONE && SCREEN_MAX_LENGTH == 667
    static let IS_IPHONE_6P         = IS_IPHONE && SCREEN_MAX_LENGTH == 736
    static let IS_IPHONE_X          = IS_IPHONE && SCREEN_MAX_LENGTH == 812
    static let IS_IPHONE_X_OR_ABOVE = IS_IPHONE && SCREEN_MAX_LENGTH > 736
    
}
