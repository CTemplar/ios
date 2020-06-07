import UIKit

struct AppStyle {
    enum Colors: Int {
        case loaderColor = 0xe74c3c
        
        var color: UIColor {
            return UIColor(appColor: self)
        }
    }
}
