import Foundation
import UIKit
import Utility

let defaultSideMenuCell = "DefaultSideMenuCell"
public let undoActionDuration = 5
let headerCharacters = 50

public enum PageLimit: Int {
    case generalThreshold = 30
    case smallDeviceOffset = 10
    case bigDeviceOffset = 20
}

public protocol MenuConfigurable {
    var menuName: String { get }
    var localizedMenuName: String { get }
}

public enum Menu: String, MenuConfigurable {
    case inbox = "inbox"
    case draft = "draft"
    case sent = "sent"
    case outbox = "outbox"
    case starred = "starred"
    case archive = "archive"
    case spam = "spam"
    case trash = "trash"
    case allMails = "allmails"
    case unread = "allunreadmails"
    case manageFolders = "manageFolders"
    
    static var allMenu: [Menu] {
        return [
            .inbox,
            .draft,
            .sent,
            .outbox,
            .starred,
            .archive,
            .unread,
            .allMails,
            .spam,
            .trash
        ]
    }
    
    var image: UIImage {
        switch self {
        case .inbox:
            return #imageLiteral(resourceName: "darkInbox")
        case .draft:
            return #imageLiteral(resourceName: "darkDraft")
        case .sent:
            return #imageLiteral(resourceName: "darkSent")
        case .outbox:
            return #imageLiteral(resourceName: "darkOutbox")
        case .starred:
            return #imageLiteral(resourceName: "darkStar")
        case .archive:
            return #imageLiteral(resourceName: "darkArchive")
        case .unread:
            return #imageLiteral(resourceName: "darkUnread")
        case .allMails:
            return #imageLiteral(resourceName: "darkAllMails")
        case .spam:
            return #imageLiteral(resourceName: "darkSpam")
        case .trash:
            return #imageLiteral(resourceName: "darkTrash")
        case .manageFolders:
            return #imageLiteral(resourceName: "darkFoldersIcon")
        }
    }
    
    var localized: String {
        switch self {
        case .inbox:
            return Strings.Menu.inbox.localized
        case .draft:
            return Strings.Menu.draft.localized
        case .sent:
            return Strings.Menu.sent.localized
        case .outbox:
            return Strings.Menu.outbox.localized
        case .starred:
            return Strings.Menu.starred.localized
        case .unread:
            return Strings.Menu.unread.localized
        case .archive:
            return Strings.Menu.archive.localized
        case .spam:
            return Strings.Menu.spam.localized
        case .trash:
            return Strings.Menu.trash.localized
        case .allMails:
            return Strings.Menu.allMails.localized
        case .manageFolders:
            return Strings.Menu.manageFolders.localized
        }
    }
    
    enum extraFolder: String, CaseIterable {
        case outboxSD = "outbox_self_destruct_counter"
        case outboxDD = "outbox_delayed_delivery_counter"
        case outboxDM = "outbox_dead_man_counter"
    }

    enum Preferences: String, CaseIterable {
        case contacts = "contacts"
        case settings = "settings"
   //     case subscriptions = "subscriptions"
        case help = "help"
        case FAQ = "FAQ"
        case logout = "logout"
        
        var image: UIImage {
            switch self {
            case .contacts:
                return #imageLiteral(resourceName: "darkContact")
            case .settings:
                return #imageLiteral(resourceName: "darkSettings")
            case .help:
                return #imageLiteral(resourceName: "darkHelp")
            case .FAQ:
                return #imageLiteral(resourceName: "darkFAQ")
            case .logout:
                return #imageLiteral(resourceName: "darkLogout")
//            case .subscriptions:
//                guard let img = UIImage(systemName: "hand.tap") else { return UIImage(named: "subscribe")! }
//                return img
            }
        }
        
        var localized: String {
            switch self {
            case .contacts:
                return Strings.Menu.contacts.localized
            case .settings:
                return Strings.Menu.settings.localized
            case .help:
                return Strings.Menu.help.localized
            case .FAQ:
                return Strings.Menu.FAQ.localized
            case .logout:
                return Strings.Menu.logout.localized
//            case .subscriptions:
//                return Strings.Menu.subscriptions.localized.capitalized
            }
        }
    }
    
    enum SideMenuSection: Int, CaseIterable {
        case menu = 0
        case preferences
        case manageFolders
        case customFolders
    }
    
    public enum Action {
        case markAsSpam
        case markAsRead
        case markAsStarred
        case moveToTrash
        case moveToArchive
        case moveToInbox
        case moveTo
        case delete
        case noAction
    }
    
    static let customFoldersCount = 3
    
    public var menuName: String {
        self.rawValue
    }
    
    public var localizedMenuName: String {
        return self.localized
    }
}

public enum CustomFolderMenu: MenuConfigurable {
    case customFolder(String)
    
    public var menuName: String {
        switch self {
        case .customFolder(let name):
            return name
        }
    }
    
    public var localizedMenuName: String {
        return menuName
    }
}

enum InboxCellButtonsIndex: Int {
    case right = 0
    case middle
    case left
}

public enum MoreAction: CaseIterable {
    case moveToArchive
    case markAsUnread
    case markAsRead
    case moveToInbox
    case markAsSpam
    case moveToTrash
    case cancel
    case moveTo
    
    public var localized: String {
        switch self {
        case .moveToArchive:
            return Strings.Inbox.MoreAction.moveToArchive.localized
        case .markAsUnread:
            return Strings.Inbox.MoreAction.markAsUnread.localized
        case .markAsRead:
            return Strings.Inbox.MoreAction.markAsRead.localized
        case .moveToInbox:
            return Strings.Inbox.MoreAction.moveToInbox.localized
        case .markAsSpam:
            return Strings.Inbox.MoreAction.markAsSpam.localized
        case .moveToTrash:
            return Strings.Inbox.MoreAction.moveToTrash.localized
        case .moveTo:
            return Strings.ManageFolder.moveTo.localized
        case .cancel:
            return Strings.Button.cancelButton.localized
        }
    }
}
extension UIImage {

    func maskWithColor(color: UIColor) -> UIImage? {
        let maskImage = cgImage!

        let width = size.width
        let height = size.height
        let bounds = CGRect(x: 0, y: 0, width: width, height: height)

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        let context = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)!

        context.clip(to: bounds, mask: maskImage)
        context.setFillColor(color.cgColor)
        context.fill(bounds)

        if let cgImage = context.makeImage() {
            let coloredImage = UIImage(cgImage: cgImage)
            return coloredImage
        } else {
            return nil
        }
    }

}
extension UIImageView {
  func setImageColor(color: UIColor) {
    let templateImage = self.image?.withRenderingMode(.alwaysTemplate)
    self.image = templateImage
    self.tintColor = color
  }
}
