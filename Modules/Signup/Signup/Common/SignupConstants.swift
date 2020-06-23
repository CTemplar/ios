import Utility
import UIKit

public let maxPasswordLength = 20
public let minPasswordLength = 10

enum UserExistance {
    case available
    case unAvailable
    
    var image: UIImage {
        if #available(iOS 13.0, *) {
            return (self == .some(UserExistance.available) ? #imageLiteral(resourceName: "checkedBoxDark") : #imageLiteral(resourceName: "errorDark"))
        } else {
            // Fallback on earlier versions
            let image = self == .some(UserExistance.available) ? #imageLiteral(resourceName: "checkedBoxDark") : #imageLiteral(resourceName: "errorDark")
            image.withRenderingMode(.alwaysTemplate)
            return image
        }
    }
    
    var text: String {
        return self == .some(UserExistance.available) ? Strings.Signup.userNameAvailable.localized : Strings.Signup.nameAlreadyExistsError.localized
    }
    
    var color: UIColor? {
        return self == .some(UserExistance.available) ? UIColor(named: "pngColor") : UIColor(named: "redColor")
    }
}
