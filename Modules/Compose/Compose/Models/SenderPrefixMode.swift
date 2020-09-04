import Utility
import UIKit

public enum SenderPrefixMode {
    case from
    case to
    case cc
    case bcc
    
    var localized: String {
        switch self {
        case .from:
            return Strings.InboxViewer.SenderPrefix.fromPrefix.localized
        case .to:
            return Strings.InboxViewer.SenderPrefix.toPrefix.localized
        case .cc:
            return Strings.InboxViewer.SenderPrefix.ccPrefix.localized
        case .bcc:
            return Strings.InboxViewer.SenderPrefix.bccPrefix.localized
        }
    }
    
    var chevronImage: UIImage? {
        switch self {
        case .from:
            return UIImage(systemName: "chevron.down",
                           withConfiguration: UIImage.SymbolConfiguration(pointSize: 14.0, weight: .light))
        case .to:
            return UIImage(systemName: "plus.circle",
                           withConfiguration: UIImage.SymbolConfiguration(pointSize: 14.0, weight: .light))
        case .cc, .bcc:
            return nil
        }
    }
}
