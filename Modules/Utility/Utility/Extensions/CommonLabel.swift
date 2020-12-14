import UIKit

public enum FontStyle {
    case Bold
    case Italic
    case Normal
}

public enum FontType {
    case Default(FontStyle)
    case Small(FontStyle)
    case ExtraSmall(FontStyle)
    case Large(FontStyle)
    case ExtraLarge(FontStyle)
    case title1(FontStyle)

    public var font: UIFont {
        switch self {
        case .Default(let style):
            return UIFont.preferredFont(forTextStyle: .body).withStyle(style)
        case .Small(let style):
            return UIFont.preferredFont(forTextStyle: .callout).withStyle(style)
        case .ExtraSmall(let style):
            return UIFont.preferredFont(forTextStyle: .footnote).withStyle(style)
        case .Large(let style):
            return UIFont.preferredFont(forTextStyle: .subheadline).withStyle(style)
        case .ExtraLarge(let style):
            return UIFont.preferredFont(forTextStyle: .largeTitle).withStyle(style)
        case .title1(let style):
            return UIFont.preferredFont(forTextStyle: .title1).withStyle(style)
        }
    }
}
