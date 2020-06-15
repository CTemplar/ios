import UIKit
public extension UIColor {

    /// Hexadecimal representation of the UIColor.
    /// For example, UIColor.blackColor() becomes "#000000".
    var hex: String {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        self.getRed(&red, green: &green, blue: &blue, alpha: nil)

        let r = Int(255.0 * red)
        let g = Int(255.0 * green)
        let b = Int(255.0 * blue)

        let str = String(format: "#%02x%02x%02x", r, g, b)
        return str
    }
    
    /// Initialises UIColor with custom app colors
    /// - Parameters:
    ///    - appColor: `AppStyle.Colors` type value
    convenience init(appColor: AppStyle.Colors) {
        self.init(hex: appColor.rawValue)
    }
    
    /// A private constructor which initialises UIColor using hex value
    /// - Parameters:
    ///    - hex: Hex Value of the color
    private convenience init(hex: Int) {
        let components = (
            R: CGFloat((hex >> 16) & 0xff) / 255,
            G: CGFloat((hex >> 08) & 0xff) / 255,
            B: CGFloat((hex >> 00) & 0xff) / 255
        )
        self.init(red: components.R, green: components.G, blue: components.B, alpha: 1)
    }
}
