import UIKit

public protocol InboxViewerPushable where Self: UIViewController {
    func openInboxViewer(of messageId: Int)
}
