import Foundation
import UIKit

public enum EmailChecker {
    case correctEmail
    case incorrectEmail
    
    public var image: UIImage {
        if #available(iOS 13.0, *) {
            return (self == .some(EmailChecker.correctEmail) ? #imageLiteral(resourceName: "checkedBoxDark") : #imageLiteral(resourceName: "errorDark"))
        } else {
            // Fallback on earlier versions
            let image = self == .some(EmailChecker.incorrectEmail) ? #imageLiteral(resourceName: "checkedBoxDark") : #imageLiteral(resourceName: "errorDark")
            image.withRenderingMode(.alwaysTemplate)
            return image
        }
    }
    
    public var text: String {
        return self == .some(EmailChecker.correctEmail) ? Strings.Signup.validEnteredEmail.localized : Strings.Signup.invalidEnteredEmail.localized
    }
    
    public var color: UIColor? {
        return self == .some(EmailChecker.correctEmail) ? UIColor(named: "pngColor") : UIColor(named: "redColor")
    }
}
