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
        
        leftMenuController.onTapManageFolders = { [weak self] (folders, user) in
            self?.openManageFolders(withFolders: folders,
                                    user: user,
                                    from: leftMenuController,
                                    fromSideMenu: true)
        }
        
        leftMenuController.onTapFAQ = {
            onTapFAQ?(leftMenuController)
        }
        
        inboxViewController.onTapMoveTo = { [weak self] (delegate, ids, user, presenter) in
            self?.showMoveToController(withMoveToDelegate: delegate,
                                       selectedMessageIds: ids,
                                       user: user,
                                       presenter: presenter
            )
        }
        
        leftMenuController.setup(inboxVC: inboxViewController)

        self.inbox = inboxViewController
        
        return (menu: leftMenuController, content: inboxNavigationController)
    }
    
    public func update(messageId: Int) {
        inbox?.dataSource?.update(messageId: messageId)
    }
    
    public func openManageFolders(withFolders folders: [Folder],
                                  user: UserMyself,
                                  from presenter: UIViewController?,
                                  fromSideMenu: Bool) {
        let manageFoldersVC: ManageFoldersViewController = UIStoryboard(storyboard: .manageFolders,
                                                              bundle: Bundle(for: ManageFoldersViewController.self)
        ).instantiateViewController()
        manageFoldersVC.setup(folderList: folders)
        manageFoldersVC.setup(user: user)
        manageFoldersVC.showFromSideMenu = fromSideMenu
        let navController = InboxNavigationController(rootViewController: manageFoldersVC)
        if fromSideMenu {
            presenter?
                .sideMenuController?
                .setContentViewController(to: navController, animated: true, completion: {
                    presenter?.sideMenuController?.hideMenu()
            })
        } else {
            navController.modalPresentationStyle = .formSheet
            presenter?.show(navController, sender: presenter)
        }
    }
    
    public func showMoveToController(withMoveToDelegate delegate: MoveToViewControllerDelegate?,
                                     selectedMessageIds: [Int],
                                     user: UserMyself,
                                     presenter: UIViewController?) {
        let moveToViewController: MoveToViewController = UIStoryboard(storyboard: .moveTo,
                                                bundle: Bundle(for: MoveToViewController.self)
        ).instantiateViewController()
        
        moveToViewController.delegate = delegate
        
        moveToViewController.selectedMessagesIDArray = selectedMessageIds
        
        moveToViewController.user = user
        
        moveToViewController.modalPresentationStyle = .formSheet
        
        presenter?.present(moveToViewController, animated: true, completion: nil)
    }
}
