import Foundation
import UIKit
import SideMenu

final class InboxSideMenuRouter {
    // MARK: Properties
    private weak var viewController: InboxSideMenuController?
    private var onTapContacts: (() -> Void)
    private var onTapSettings: (() -> Void)
    private var onTapFAQ: (() -> Void)
    private var onTapManageFolders: (() -> Void)
    
    // MARK: - Constructor
    init(viewController: InboxSideMenuController,
         onTapContacts: @escaping (() -> Void),
         onTapSettings: @escaping (() -> Void),
         onTapFAQ:  @escaping (() -> Void),
         onTapManageFolders: @escaping (() -> Void)
    ) {
        self.viewController = viewController
        self.onTapContacts = onTapContacts
        self.onTapSettings = onTapSettings
        self.onTapFAQ = onTapFAQ
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
    
    func showContactsViewController() {
        onTapContacts()
    }
    
    func showManageFoldersViewController() {
        onTapManageFolders()
    }
    
    func showSettingsViewController() {
        onTapSettings()
    }
    
    func showFAQ() {
        onTapFAQ()
    }
}
