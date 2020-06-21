import Foundation
import UIKit

public enum PasswordChecker {
    case matched
    case unMatched
    case wrongFormat
    case minLength
    
    public var image: UIImage {
        if #available(iOS 13.0, *) {
            return (self == .some(PasswordChecker.matched) ? #imageLiteral(resourceName: "checkedBoxDark") : #imageLiteral(resourceName: "errorDark"))
        } else {
            // Fallback on earlier versions
            let image = self == .some(PasswordChecker.matched) ? #imageLiteral(resourceName: "checkedBoxDark") : #imageLiteral(resourceName: "errorDark")
            image.withRenderingMode(.alwaysTemplate)
            return image
        }
    }
    
    public var text: String {
        return self == .some(PasswordChecker.matched) ? Strings.Signup.passwordMatched.localized : self == .some(PasswordChecker.unMatched) ? Strings.Signup.passwordNotMatched.localized : self == .some(PasswordChecker.minLength) ? Strings.Signup.minPasswordLengthError.localized : Strings.Signup.invalidEnteredPassword.localized
    }
    
    public var color: UIColor? {
        return self == .some(PasswordChecker.matched) ? UIColor(named: "pngColor") : UIColor(named: "redColor")
    }
}
