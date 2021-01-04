import UIKit

public enum ActionDescriptor {
    case read, unread, more, spam, trash, moveTo, newMail, phoneCall
    
    public func title(forDisplayMode displayMode: ButtonDisplayMode) -> String? {
        guard displayMode != .imageOnly else { return nil }
        
        switch self {
        case .read: return Strings.Inbox.read.localized
        case .unread: return Strings.Inbox.unread.localized
        case .more: return Strings.Inbox.MoreAction.more.localized
        case .spam: return Strings.Menu.spam.localized
        case .trash: return Strings.Menu.trash.localized
        case .moveTo: return Strings.Inbox.moveTo.localized.replacingOccurrences(of: "...", with: "")
        case .newMail: return Strings.Compose.compose.localized
        case .phoneCall: return Strings.Contacts.call.localized
        }
    }
    
    public func image(forStyle style: ButtonStyle, displayMode: ButtonDisplayMode) -> UIImage? {
        guard displayMode != .titleOnly else { return nil }
        
        let name: String
        switch self {
        case .read: name = "envelope.open.fill"
        case .unread: name = "envelope.badge.fill"
        case .more: name = "ellipsis.circle.fill"
        case .spam: name = "exclamationmark.circle.fill"
        case .trash: name = "trash.fill"
        case .moveTo: name = "folder.fill.badge.plus"
        case .newMail: name  = "envelope.badge.fill"
        case .phoneCall: name = "phone.fill.arrow.up.right"
        }
        
        if style == .backgroundColor {
            let config = UIImage.SymbolConfiguration(pointSize: 23.0, weight: .regular)
            return UIImage(systemName: name, withConfiguration: config)
        } else {
            let config = UIImage.SymbolConfiguration(pointSize: 16.0, weight: .regular)
            let image = UIImage(systemName: name, withConfiguration: config)?.withTintColor(.white, renderingMode: .alwaysTemplate)
            return circularIcon(with: color(forStyle: style), size: CGSize(width: 30.0, height: 30.0), icon: image)
        }
    }
    
    public func color(forStyle style: ButtonStyle) -> UIColor {
        switch self {
        case .read, .unread, .newMail: return .systemBlue
        case .phoneCall: return .systemGreen
        case .more:
            if UITraitCollection.current.userInterfaceStyle == .dark {
                return .systemGray
            }
            return style == .backgroundColor ? UIColor.systemGray3 : UIColor.systemGray2
        case .spam: return .systemOrange
        case .trash: return .systemRed
        case .moveTo: return .systemYellow
        }
    }
    
    public func circularIcon(with color: UIColor, size: CGSize, icon: UIImage? = nil) -> UIImage? {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        
        UIBezierPath(ovalIn: rect).addClip()
        
        color.setFill()
        UIRectFill(rect)
        
        if let icon = icon {
            let iconRect = CGRect(x: (rect.size.width - icon.size.width) / 2,
                                  y: (rect.size.height - icon.size.height) / 2,
                                  width: icon.size.width,
                                  height: icon.size.height)
            icon.draw(in: iconRect, blendMode: .normal, alpha: 1.0)
        }
        
        defer { UIGraphicsEndImageContext() }
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}

public enum ButtonDisplayMode {
    case titleAndImage, titleOnly, imageOnly
}

public enum ButtonStyle {
    case backgroundColor, circular
}
