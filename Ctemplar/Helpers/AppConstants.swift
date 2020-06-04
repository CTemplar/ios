import UIKit

struct AppStyle {
    enum Colors: Int {
        case loaderColor = 0x34495e
        
        var color: UIColor {
            return UIColor(appColor: self)
        }
    }
}
