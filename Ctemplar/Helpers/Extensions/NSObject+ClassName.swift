import Foundation

extension NSObject {
    /// Gives the string value of any NSObject instance
    var className: String {
        return String(describing: type(of: self))
    }
    /// Gives the string value of any NSObject instance
    class var className: String {
        return String(describing: self)
    }
}
