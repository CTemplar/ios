import Foundation
import SideMenu
import UIKit
import Networking
import Utility

final class InboxRouter {
    // MARK: Properties
    private weak var inboxViewController: InboxViewController?
    private var onTapMoveTo: (() -> Void)
    
    // MARK: - Constructor
    init(inboxViewController: InboxViewController?,
         onTapMoveTo: @escaping (() -> Void)) {
        self.inboxViewController = inboxViewController
        self.onTapMoveTo = onTapMoveTo
    }
    
    // MARK: - Navigations
    func showSidemenu() {
        inboxViewController?.sideMenuController?.revealMenu()
    }
    
    func showComposeViewControllerWithDraft(answerMode: AnswerMessageMode,
                                            message: EmailMessage) {
        
    }
    
    func showViewInboxEmailViewController(message: EmailMessage) {
        
    }
    
    func showSearchViewController() {
        
    }
    
    func showMoveToController() {
        onTapMoveTo()
    }
}
