import Foundation
import UIKit
import SideMenu
import Networking
import Utility

final class InboxSideMenuRouter {
    // MARK: Properties
    private weak var viewController: InboxSideMenuController?
    var onTapSettings: ((UserMyself) -> Void)?
    var onTapManageFolders: (([Folder], UserMyself) -> Void)?
    var onTapContacts: (([Contact], UserMyself) -> Void)?
    var onTapFAQ: (() -> Void)?

    // MARK: - Constructor
    init(viewController: InboxSideMenuController,
         onTapContacts: (([Contact], UserMyself) -> Void)?,
         onTapSettings: ((UserMyself) -> Void)?,
         onTapManageFolders: (([Folder], UserMyself) -> Void)?,
         onTapFAQ: (() -> Void)?) {
        self.viewController = viewController
        self.onTapSettings = onTapSettings
        self.onTapFAQ = onTapFAQ
        self.onTapContacts = onTapContacts
        self.onTapManageFolders = onTapManageFolders
    }
    
    // MARK: - navigations
    func showMessagesViewController(vc: InboxViewController) {
        self.viewController?.setup(parent: vc)
        let navigationController = InboxNavigationController(rootViewController: vc)
        viewController?.sideMenuController?.setContentViewController(to: navigationController,
                                                                     animated: true,
                                                                     completion: { [weak self] in
                                                                        self?.viewController?.sideMenuController?.hideMenu()
        })
    }
    
    func showContactsViewController(withUserContacts contacts: [Contact], user: UserMyself) {
        onTapContacts?(contacts, user)
    }
    
    func showManageFoldersViewController(withList folderList: [Folder], user: UserMyself) {
        onTapManageFolders?(folderList, user)
    }
    
    func showSettingsViewController(withUser user: UserMyself) {
        onTapSettings?(user)
    }
    
    func showFAQ() {
        onTapFAQ?()
    }
}
