import UIKit
import ObjectivePGP

public typealias AppResult<T> = Result<T, Error>
public typealias Completion<T> = (AppResult<T>) -> Void
public typealias PGPKey = Key
public typealias SecurityKey = Key

public struct AppStyle {
    public enum Colors: Int {
        case loaderColor = 0xe74c3c
        
        public var color: UIColor {
            return UIColor(appColor: self)
        }
    }
    
    public enum StringColor: String {
        case blue = "blueColor"
        case navigationBarTitle = "navBarTitleColor"
        case navigationBarBackground = "navBarBackgroundColor"
        case folderCellText = "folderCellTextColor"
        
        public var color: UIColor {
            guard let clr = UIColor(named: self.rawValue) else {
                fatalError("No color found for this name: \(self.rawValue)")
            }
            return clr
        }
    }
    
    public enum CustomFontStyle: String {
        case Regular = "Lato-Regular"
        case Bold = "Lato-Bold"
        
        public func font(withSize size: CGFloat) -> UIFont? {
            return UIFont(name: self.rawValue, size: size)
        }
    }
    
    public enum SystemFontStyle {
        case regular
        case bold
        case semiBold
        case light
        
        public func font(withSize size: CGFloat) -> UIFont {
            switch self {
            case .regular:
                return UIFont.systemFont(ofSize: size, weight: .regular)
            case .bold:
                return UIFont.systemFont(ofSize: size, weight: .bold)
            case .semiBold:
                return UIFont.systemFont(ofSize: size, weight: .semibold)
            case .light:
                return UIFont.systemFont(ofSize: size, weight: .light)
            }
        }
    }
}

public struct GeneralConstant {
    public enum PageControlConstant: Double {
        case pageControlBottomOffset = 30.0
        case pageControlDotSize = 8.0
        case lineSpaceSizeForFromToText = 10.0
    }
    
    public enum OffsetValue: Int {
        case contactPageLimit, firstLoadPageLimit_iPad = 20
        case pageLimit = 30
        case firstLoadPageLimit = 10
        case offsetForLast = 5
    }
    
    public enum DateFormatStyle: String {
        case utc = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        case utcWithoutSecond = "yyyy-MM-dd'T'HH:mm:SSZ"
        case utcWithoutMilliSecond = "yyyy-MM-dd HH:mm:ss Z"
        case HHmma = "HH:mm a"
        case HHmmssa = "HH:mm:ss a"
        case MMMdd = "MMM dd"
        case MMMddyyyyHHmmssa = "MMM dd, yyyy, HH:mm:ss a"
        case EMMMMddyyyy = "E, MMMM dd, yyyy"
        case yyyy_MM_dd_HH_mm_ss = "yyyy_MM_dd_HH_mm_ss"
        case EddMMMHHMM = "E dd MMM HH:MM"
        case YYYYMMddTHHmmssSSSZZZZZ = "YYYY-MM-dd'T'HH:mm:ss.SSSZZZZZ"
    }
    
    public static func getApplicationSupportDirectoryDirectory() -> URL {
        let paths = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    public enum Link: String {
        case PrivacyURL = "https://ctemplar.com/privacy"
        case TermsURL = "https://ctemplar.com/terms"
        case MainSiteURL = "https://ctemplar.com/"
        case UpgradeURL = "https://ctemplar.com/pricing"
        case SupportURL = "support@ctemplar.com."
        case FAQURL = "https://ctemplar.com/faqs/"
    }
    
    public static let updateInboxMessagesNotificationID = "updateInboxMessagesNotification"
}

public enum AnswerMessageMode {
    case newMessage
    case reply
    case replyAll
    case forward
}

enum AppSecurity: String {
    case SaltPrefix = "$2a$10$"
    case NumberOfRounds = "29"
    case keyringFileName = "keyring.gpg"
}

public struct Device {
    // iDevice detection code
    public static let IS_IPAD              = UIDevice.current.userInterfaceIdiom == .pad
    public static let IS_IPHONE            = UIDevice.current.userInterfaceIdiom == .phone
    public static let IS_RETINA            = UIScreen.main.scale >= 2.0
    public static let SCREEN_WIDTH         = Int(UIScreen.main.bounds.size.width)
    public static let SCREEN_HEIGHT        = Int(UIScreen.main.bounds.size.height)
    public static let SCREEN_MAX_LENGTH    = Int( max(SCREEN_WIDTH, SCREEN_HEIGHT) )
    public static let SCREEN_MIN_LENGTH    = Int( min(SCREEN_WIDTH, SCREEN_HEIGHT) )
    public static let IS_IPHONE_4_OR_LESS  = IS_IPHONE && SCREEN_MAX_LENGTH < 568
    public static let IS_IPHONE_5_OR_ABOVE = IS_IPHONE && SCREEN_MAX_LENGTH > 568
    public static let IS_IPHONE_5          = IS_IPHONE && SCREEN_MAX_LENGTH == 568
    public static let IS_IPHONE_6          = IS_IPHONE && SCREEN_MAX_LENGTH == 667
    public static let IS_IPHONE_6P         = IS_IPHONE && SCREEN_MAX_LENGTH == 736
    public static let IS_IPHONE_X          = IS_IPHONE && SCREEN_MAX_LENGTH == 812
    public static let IS_IPHONE_X_OR_ABOVE = IS_IPHONE && SCREEN_MAX_LENGTH > 736
    public static let PLATFORM             = "ios"
}

/// Debug Mode for print
public func DPrint(_ items: Any...) {
    
    #if DEBUG
    var startIdx = items.startIndex
    let endIdx = items.endIndex
    
    repeat {
        Swift.print(items[startIdx])
        startIdx += 1
    }
    while startIdx < endIdx
    
    #endif
}

// TODO: Temporary colors, will remove it once we shift all the colors into enum
public var k_navBar_titleColor: UIColor {
    return UIColor(named: "navBarTitleColor")!
} //= UIColor(red: 44/255, green: 62/255, blue: 80/255, alpha: 0.87)

public var k_navBar_backgroundColor: UIColor {
    return UIColor(named: "navBarBackgroundColor")!
} //= UIColor(red: 250/255, green: 251/255, blue: 251/255, alpha: 1.0)

public var k_navButtonTintColor: UIColor {
    return UIColor(named: "navButtonTintColor")!
}

public var k_searchBar_backgroundColor: UIColor {
    return UIColor(named: "searchBarBackgroundColor")!
}

public var k_lightRedColor: UIColor {
    return UIColor(named: "lightRedColor")!
} //= UIColor(red: 231.0/255.0, green: 76.0/255.0, blue: 60.0/255.0, alpha: 0.2)

public var k_redColor: UIColor {
    return UIColor(named: "redColor")!
} //= UIColor(red: 231.0/255.0, green: 76.0/255.0, blue: 60.0/255.0, alpha: 1.0)

public var k_sideMenuColor: UIColor {
    return UIColor(named: "sideMenuColor")!
} //= UIColor(red: 23.0/255.0, green: 50.0/255.0, blue: 77.0/255.0, alpha: 1.0)

public var k_sideMenuSeparatorColor: UIColor {
    return UIColor(named: "sideMenuSeparatorColor")!
} //= UIColor(red: 23.0/255.0, green: 50.0/255.0, blue: 77.0/255.0, alpha: 0.1)

public var k_sideMenuFadeColor: UIColor {
    return UIColor(named: "sideMenuFadeColor")!
} //= UIColor(red: 2.0/255.0, green: 13.0/255.0, blue: 25.0/255.0, alpha: 0.56)

public var k_sideMenuTextFadeColor: UIColor {
    return UIColor(named: "sideMenuTextFadeColor")!
} //= UIColor(red: 52.0/255.0, green: 73.0/255.0, blue: 94.0/255.0, alpha: 0.4)

public var k_urlColor: UIColor {
    return UIColor(named: "urlColor")!
} //= UIColor(red: 74.0 / 255.0, green: 144.0 / 255.0, blue: 226.0 / 255.0, alpha: 1.0)

public var k_lightGrayColor: UIColor {
    return UIColor(named: "lightGrayColor")!
} //= UIColor(white: 0.0, alpha: 0.54)

public var k_whiteBlackListTextLabelColor: UIColor {
    return UIColor(named: "whiteBlackListTextLabelColor")!
}

public var k_emailToColor: UIColor {
    return UIColor(named: "emailToColor")!
} //= UIColor(white: 158.0 / 255.0, alpha: 1.0)

public var k_emailToInputColor: UIColor {
    return UIColor(named: "emailToInputColor")!
} //= UIColor(red: 9.0 / 255.0, green: 31.0 / 255.0, blue: 53.0 / 255.0, alpha: 0.5)

public var k_emailToInputColor1: UIColor {
    return UIColor(named: "emailToInputColor1")!
}

public var k_lightGrayTextColor: UIColor {
    return UIColor(named: "lightGrayTextColor")!
} //= UIColor(red: 147.0 / 255.0, green: 145.0 / 255.0, blue: 145.0 / 255.0, alpha: 1.0)

public var k_mainInboxColor: UIColor {
    return UIColor(named: "mainInboxColor")!
} //= UIColor(red: 242.0 / 255.0, green: 240.0 / 255.0, blue: 240.0 / 255.0, alpha: 1.0)

public var k_foundTextBackgroundColor: UIColor {
    return UIColor(named: "foundTextBackgroundColor")!
} //= UIColor(red: 217.0 / 255.0, green: 235.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)

public var k_whiteColor: UIColor {
    return UIColor(named: "whiteColor")!
} //= UIColor(red: 250.0 / 255.0, green: 251.0 / 255.0, blue: 251.0 / 255.0, alpha: 1.0)

public var k_selectedFolderColor: UIColor {
    return UIColor(named: "selectedFolderColor")!
} //= UIColor(red: 18.0 / 255.0, green: 45.0 / 255.0, blue: 71.0 / 255.0, alpha: 0.1)

public var k_readMessageColor : UIColor {
    return UIColor(named: "readMessageColor")!
} //= UIColor(white: 245/255, alpha: 1.0)

public var k_unreadMessageColor : UIColor {
    return UIColor(named: "unreadMessageColor")!
} //= UIColor(white: 1.0, alpha: 1.0)

public var k_actionMessageColor : UIColor {
    return UIColor(named: "actionMessageColor")!
} //= UIColor(red: 9.0 / 255.0, green: 31.0 / 255.0, blue: 53.0 / 255.0, alpha: 1.0)

public var k_contactsBarTintColor : UIColor {
    return UIColor(named: "contactsBarTintColor")!
} //= UIColor(red: 44.0 / 255.0, green: 62.0 / 255.0, blue: 80.0 / 255.0, alpha: 1.0)

public var k_passwordBarTintColor : UIColor {
    return UIColor(named: "passwordBarTintColor")!
} //= UIColor(red: 44.0 / 255.0, green: 62.0 / 255.0, blue: 80.0 / 255.0, alpha: 0.87)

public var k_mainFolderTextColor : UIColor {
    return UIColor(named: "mainFolderTextColor")!
} //= UIColor(red: 9.0 / 255.0, green: 31.0 / 255.0, blue: 53.0 / 255.0, alpha: 0.5)

public var k_folderCellTextColor: UIColor {
    return UIColor(named: "folderCellTextColor")!
}

public var k_orangeColor : UIColor {
    return UIColor(named: "orangeColor")!
}//= UIColor(red: 255.0 / 255.0, green: 170.0 / 255.0, blue: 14.0 / 255.0, alpha: 1.0)

public var k_greenColor : UIColor {
    return UIColor(named: "greenColor")!
} //= UIColor(red: 0.0 / 255.0, green: 116.0 / 255.0, blue: 33.0 / 255.0, alpha: 1.0)

public var k_blueColor : UIColor {
    return UIColor(named: "blueColor")!
} //= UIColor(red: 52.0 / 255.0, green: 152.0 / 255.0, blue: 219.0 / 255.0, alpha: 1.0)

public var k_docColor : UIColor {
    return UIColor(named: "docColor")!
}//= UIColor(red: 0.0 / 255.0, green: 150.0 / 255.0, blue: 230.0 / 255.0, alpha: 1.0)

public var k_pdfColor : UIColor {
    return UIColor(named: "pdfColor")!
}
//= UIColor(red: 204.0 / 255.0, green: 75.0 / 255.0, blue: 76.0 / 255.0, alpha: 1.0)
public var k_pngColor : UIColor {
    return UIColor(named: "pngColor")!
}//= UIColor(red: 101.0 / 255.0, green: 156.0 / 255.0, blue: 53.0 / 255.0, alpha: 1.0)

public var k_jpgColor : UIColor {
    return UIColor(named: "jpgColor")!
}//= UIColor(red: 19.0 / 255.0, green: 160.0 / 255.0, blue: 133.0 / 255.0, alpha: 1.0)

public var k_otherColor : UIColor {
    return UIColor(named: "otherColor")!
} //= UIColor(red: 148.0 / 255.0, green: 165.0 / 255.0, blue: 165.0 / 255.0, alpha: 1.0)

public var k_fileNameColor : UIColor {
    return UIColor(named: "fileNameColor")!
}//= UIColor(red: 90.0 / 255.0, green: 90.0 / 255.0, blue: 90.0 / 255.0, alpha: 1.0)

public var k_settingHeaderLineColor: UIColor {
    return UIColor(named: "settingHeaderLineColor")!
} //= UIColor(red: 235.0 / 255.0, green: 235.0 / 255.0, blue: 235.0 / 255.0, alpha: 1.0)

public var k_mailboxTextColor: UIColor {
    return UIColor(named: "mailboxTextColor")!
} //= UIColor(red: 52.0/255.0, green: 73.0/255.0, blue: 94.0/255.0, alpha: 1.0)

public var k_cellTitleTextColor: UIColor {
    return UIColor(named: "cellTitleTextColor")!
}

public var k_cellSubTitleTextColor: UIColor {
    return UIColor(named: "cellSubTitleTextColor")!
}

public var k_messageCountLabelTextColor: UIColor {
    return UIColor(named: "messageCountLabelTextColor")!
}

public var k_settingsHeaderBackgroundColor: UIColor {
    return UIColor(named: "settingsHeaderBackgroundColor")!
}

public var k_fingerprintTextColor: UIColor {
    return UIColor(named: "fingerprintTextColor")!
}

public var k_sideMenuCellBackgroundColor: UIColor {
    return UIColor(named: "sideMenuCellBackgroundColor")!
}

public var k_sideMenuSelectedCellBackgroundColor: UIColor {
    return UIColor(named: "sideMenuSelectedCellBackgroundColor")!
}
