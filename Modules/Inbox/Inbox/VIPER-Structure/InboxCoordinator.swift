import Foundation
import UIKit
import Networking
import Utility

public class InboxCoordinator {
    private var inbox: InboxViewController?

    public init() {}
    
    public func showInbox(onTapCompose: ((AnswerMessageMode, UserMyself, UIViewController?) -> Void)?,
                          onTapComposeWithDraft: ((AnswerMessageMode, EmailMessage, UserMyself, UIViewController?) -> Void)?,
                          onTapSearch: (([EmailMessage], UserMyself, UIViewController?) -> Void)?,
                          onTapViewInbox: ((EmailMessage, String, UserMyself, ViewInboxEmailDelegate?) -> Void)?,
                          onTapContacts: (([Contact], Bool, UIViewController?) -> Void)?,
                          onTapSettings: ((UserMyself, UIViewController?) -> Void)?,
                          onTapManageFolders: (([Folder], UserMyself, UIViewController?) -> Void)?,
                          onTapFAQ: ((UIViewController?) -> Void)?) -> (menu: InboxSideMenuController, content: UIViewController) {
        
        SharedInboxState.shared.update(menu: Menu.inbox)
        
        let inboxViewController: InboxViewController = UIStoryboard(name: "Inbox", bundle: Bundle(for: type(of: self))).instantiateViewController(withIdentifier: InboxViewController.className) as! InboxViewController
        
        inboxViewController.onTapSearch = onTapSearch
        inboxViewController.onTapViewInbox = onTapViewInbox
        inboxViewController.onTapCompose = onTapCompose
        inboxViewController.onTapComposeWithDraft = onTapComposeWithDraft
        
        let inboxNavigationController = InboxNavigationController(rootViewController: inboxViewController)

        let leftMenuController: InboxSideMenuController = UIStoryboard(storyboard: .inboxSideMenu,
                                                                       bundle: Bundle(for: type(of: self))
        ).instantiateViewController()
        
        leftMenuController.onTapContacts = { (contacts, encrypted) in
            onTapContacts?(contacts, encrypted, leftMenuController)
        }
        
        leftMenuController.onTapSettings = { (user) in
            onTapSettings?(user, leftMenuController)
        }
        
        leftMenuController.onTapManageFolders = { (folders, user) in
            onTapManageFolders?(folders, user, leftMenuController)
        }
        
        leftMenuController.onTapFAQ = {
            onTapFAQ?(leftMenuController)
        }
        
        leftMenuController.setup(inboxVC: inboxViewController)

        self.inbox = inboxViewController
        
        return (menu: leftMenuController, content: inboxNavigationController)
    }
    
    public func update(messageId: Int) {
        inbox?.dataSource?.update(messageId: messageId)
    }
}
