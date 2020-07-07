import Foundation
import SideMenu
import UIKit
import Networking
import Utility

final class InboxRouter {
    // MARK: Properties
    private weak var inboxViewController: InboxViewController?
    private var onTapSearch: (([EmailMessage], UserMyself, UIViewController?) -> Void)?
    private var onTapComposeWithDraft: ((AnswerMessageMode, EmailMessage, UserMyself, UIViewController?) -> Void)?
    private var onTapCompose: ((AnswerMessageMode, UserMyself, UIViewController?) -> Void)?
    private var onTapViewInbox: ((EmailMessage, String, UserMyself, ViewInboxEmailDelegate?) -> Void)?

    // MARK: - Constructor
    init(inboxViewController: InboxViewController?,
         onTapCompose: ((AnswerMessageMode, UserMyself, UIViewController?) -> Void)?,
         onTapComposeWithDraft: ((AnswerMessageMode, EmailMessage, UserMyself, UIViewController?) -> Void)?,
         onTapSearch: (([EmailMessage], UserMyself, UIViewController?) -> Void)?,
         onTapViewInbox: ((EmailMessage, String, UserMyself, ViewInboxEmailDelegate?) -> Void)?
    ) {
        self.inboxViewController = inboxViewController
        self.onTapCompose = onTapCompose
        self.onTapComposeWithDraft = onTapComposeWithDraft
        self.onTapSearch = onTapSearch
        self.onTapViewInbox = onTapViewInbox
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
                                          currentFolderFilter: String,
                                          user: UserMyself) {
        onTapViewInbox?(message, currentFolderFilter, user, inboxViewController)
    }
    
    func showSearchViewController(with messages: [EmailMessage], user: UserMyself) {
        onTapSearch?(messages, user, inboxViewController)
    }
    
    func showMoveToController(withSelectedMessages messageIds: [Int]) {
        let moveToViewController: MoveToViewController = UIStoryboard(storyboard: .moveTo,
                                                bundle: Bundle(for: MoveToViewController.self)
        ).instantiateViewController()
        
        moveToViewController.delegate = inboxViewController?.presenter
        
        moveToViewController.selectedMessagesIDArray = messageIds
        
        if let user = inboxViewController?.dataSource?.user {
            moveToViewController.user = user
        }
        
        moveToViewController.modalPresentationStyle = .formSheet
        
        inboxViewController?.present(moveToViewController, animated: true, completion: nil)
    }
}
