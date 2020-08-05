import Foundation
import SideMenu
import UIKit
import Networking
import Utility

final class InboxRouter {
    // MARK: Properties
    private weak var inboxViewController: InboxViewController?
    private var onTapSearch: ((UserMyself, UIViewController?) -> Void)?
    private var onTapComposeWithDraft: ((AnswerMessageMode, EmailMessage, UserMyself, UIViewController?) -> Void)?
    private var onTapCompose: ((AnswerMessageMode, UserMyself, UIViewController?) -> Void)?
    private var onTapViewInbox: ((EmailMessage?, UserMyself?, ViewInboxEmailDelegate?, UIViewController?) -> Void)?
    private var onTapMoveTo: ((MoveToViewControllerDelegate?, [Int], UserMyself, UIViewController?) -> Void)?

    // MARK: - Constructor
    init(inboxViewController: InboxViewController?,
         onTapCompose: ((AnswerMessageMode, UserMyself, UIViewController?) -> Void)?,
         onTapComposeWithDraft: ((AnswerMessageMode, EmailMessage, UserMyself, UIViewController?) -> Void)?,
         onTapSearch: ((UserMyself, UIViewController?) -> Void)?,
         onTapViewInbox: ((EmailMessage?, UserMyself?, ViewInboxEmailDelegate?, UIViewController?) -> Void)?,
         onTapMoveTo: ((MoveToViewControllerDelegate?, [Int], UserMyself, UIViewController?) -> Void)?) {
        self.inboxViewController = inboxViewController
        self.onTapCompose = onTapCompose
        self.onTapComposeWithDraft = onTapComposeWithDraft
        self.onTapSearch = onTapSearch
        self.onTapViewInbox = onTapViewInbox
        self.onTapMoveTo = onTapMoveTo
    }
    
    // MARK: - Navigations
    func showSidemenu() {
        inboxViewController?.sideMenuController?.revealMenu()
    }
    
    func showComposeViewController(answerMode: AnswerMessageMode,
                                   message: EmailMessage,
                                   user: UserMyself) {
        onTapComposeWithDraft?(answerMode, message, user, inboxViewController)
    }
    
    func showComposeViewController(answerMode: AnswerMessageMode, user: UserMyself) {
        onTapCompose?(answerMode, user, inboxViewController)
    }
    
    func showViewInboxEmailViewController(message: EmailMessage,
                                          user: UserMyself,
                                          delegate: ViewInboxEmailDelegate?) {
        onTapViewInbox?(message, user, delegate, inboxViewController)
    }
    
    func showSearchViewController(with user: UserMyself) {
        onTapSearch?(user, inboxViewController)
    }
    
    func showMoveToController(withSelectedMessages messageIds: [Int]) {
        guard let user = inboxViewController?.dataSource?.user else {
            return
        }
        
        onTapMoveTo?(inboxViewController?.presenter, messageIds, user, inboxViewController)
    }
}
