import UIKit

public extension UIFont {
    static func withType(_ type: FontType) -> UIFont {
        return type.font
    }
    
    func withStyle(_ style: FontStyle) -> UIFont {
        switch style {
        case .Bold:
            return self.bold()
        case .Italic:
            return self.italic()
        case .Normal:
            return self
        }
    }

    private func bold() -> UIFont {
        return withTraits(traits: .traitBold)
    }

    private func italic() -> UIFont {
        return withTraits(traits: .traitItalic)
    }
    
    private func withTraits(traits: UIFontDescriptor.SymbolicTraits) -> UIFont {
        let descriptor = fontDescriptor.withSymbolicTraits(traits)
        return UIFont(descriptor: descriptor!, size: 0) //size 0 means keep the size as it is
    }
}
