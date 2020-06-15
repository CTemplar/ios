import Foundation

public extension NSAttributedString {
    var trailingNewlineChopped: NSAttributedString {
        if string.hasSuffix("\n") {
            return attributedSubstring(from: NSRange(location: 0, length: length - 1))
        } else {
            return self
        }
    }
}
