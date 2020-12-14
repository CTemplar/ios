import Foundation
import Utility
import Networking
import UIKit
import Login

public final class InboxSideMenuInteractor {
    // MARK: Properties
    private weak var viewController: InboxSideMenuController?
    
    private weak var presenter: InboxSideMenuPresenter?
    
    private let apiService = NetworkManager.shared.apiService
    
    private var user: UserMyself {
        return viewController?.inbox?.dataSource?.user ?? UserMyself()
    }
    
    private var folders: [Folder] {
        return (user.foldersList ?? [])
    }
    
    private var contacts: [Contact] {
        return (user.contactsList ?? [])
    }
    
    // MARK: - Setup
    func setup(viewController: InboxSideMenuController) {
        self.viewController = viewController
    }
    
    func setup(presenter: InboxSideMenuPresenter) {
        self.presenter = presenter
    }

    // MARK: - API Handlers
    public func logOut() {
        Loader.start()
        apiService.logOut(completionHandler: { [weak self] (isSucceeded) in
            DispatchQueue.main.async {
                Loader.stop()
                if isSucceeded {
                    UtilityManager.shared.keychainService.deleteUserCredentialsAndToken()
                    self?.resetAppIconBadgeValue()
                    self?.resetRootController()
                    NotificationCenter.default.post(name: .logoutCompleteNotificationID, object: nil)
                } else {
                   if let currentVC = self?.viewController {
                    currentVC.showAlert(with: Strings.Logout.logoutErrorTitle.localized,
                                   message: Strings.Logout.logoutErrorMessage.localized,
                                   buttonTitle: Strings.Button.closeButton.localized)
                    }
                }
            }
        })
    }
    
    func customFoldersList() {
        Loader.start()
        apiService.customFoldersList(limit: 200, offset: 0) { (result) in
            switch(result) {
            case .success(let value):
                let folderList = value as! FolderList
                
                self.setCustomFoldersData(folderList: folderList)
                
                self.unreadMessagesCounter()
                
            case .failure(let error):
                print("error:", error)
                self.viewController?.showAlert(with: "Folders Error",
                           message: error.localizedDescription,
                           buttonTitle: Strings.Button.closeButton.localized)
            }
            
            Loader.stop()
        }
    }

    // MARK: - Application Logics
    private func resetAppIconBadgeValue() {
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    func setCustomFoldersData(folderList: FolderList) {
        if let folders = folderList.foldersList {
            viewController?.dataSource?.update(customFolders: folders)
            viewController?.dataSource?.reload()
        }
    }
    
    func setUnreadCounters(_ counters: [UnreadMessagesCounter]) {
        viewController?.dataSource?.update(unreadMessages: counters)
        viewController?.dataSource?.reload()
        updateInboxBottomBar(with: counters, for: viewController?.inbox)
    }
    
    func setUnreadCounters(_ counters: [UnreadMessagesCounter], folder: Menu) {
        viewController?.dataSource?.update(unreadMessages: counters)
        viewController?.dataSource?.reload()
        updateInboxBottomBar(with: counters, for: viewController?.inbox)
    }
    
    func updateInboxBottomBar(with unreadMessages: [UnreadMessagesCounter],
                              for vc: InboxViewController?) {
        let filterEnabled = vc?.dataSource?.filterEnabled ?? false
        
        let totalEmails = vc?.presenter?.interactor?.totalItems ?? 0
        
        let currentFolder = SharedInboxState.shared.selectedMenu ?? Menu.inbox
        
        let unreadEmails = getUnreadMessagesCount(with: viewController?.dataSource?.unreadMessages ?? [],
                                                  folder: currentFolder.menuName,
                                                  apiFolderName: currentFolder.menuName
        )
        vc?.dataSource?.update(unreadCount: unreadEmails)
        vc?.presenter?.setupUI(emailsCount: totalEmails, unreadEmails: unreadEmails, filterEnabled: filterEnabled)
    }
    
    func unreadMessagesCounter() {
        apiService.unreadMessagesCounter() { [weak self] (result) in
            switch(result) {
            case .success(let value):
                var unreadMessagesCounters: [UnreadMessagesCounter] = []
                if let value = value as? Dictionary<String, Any> {
                    for objectDictionary in value {
                        let unreadMessageCounter = UnreadMessagesCounter(key: objectDictionary.key, value: objectDictionary.value)
                        unreadMessagesCounters.append(unreadMessageCounter)
                    }
                }
                self?.setUnreadCounters(unreadMessagesCounters)
            case .failure(let error):
                DPrint("error:", error)
            }
        }
    }
    
    func getUnreadMessagesCount(with unreadMessages: [UnreadMessagesCounter],
                                folder: String,
                                apiFolderName: String) -> Int {
        var unreadMessagesCount = 0
        var selfDestructUnreadMessagesCount = 0
        var delayedDeliveryUnreadMessagesCount = 0
        var deadManUnreadMessagesCount = 0
        
        for object in unreadMessages where object.folderName == apiFolderName {
            unreadMessagesCount = object.unreadMessagesCount ?? 0

            if object.folderName == MessagesFoldersName.outboxSD.rawValue {
                selfDestructUnreadMessagesCount = object.unreadMessagesCount ?? 0
            }
            
            if object.folderName == MessagesFoldersName.outboxDD.rawValue {
                delayedDeliveryUnreadMessagesCount = object.unreadMessagesCount ?? 0
            }
            
            if object.folderName == MessagesFoldersName.outboxDM.rawValue {
                deadManUnreadMessagesCount = object.unreadMessagesCount ?? 0
            }
            
            if object.folderName == MessagesFoldersName.outboxDM.rawValue {
                deadManUnreadMessagesCount = object.unreadMessagesCount ?? 0
            }
        }
        
        if apiFolderName == MessagesFoldersName.outbox.rawValue {
            unreadMessagesCount = selfDestructUnreadMessagesCount + delayedDeliveryUnreadMessagesCount + deadManUnreadMessagesCount
        }
        
        if folder == Menu.unread.menuName,
            let unreadMessage = unreadMessages.first(where: { $0.folderName == MessagesFoldersName.inbox.rawValue }) {
            unreadMessagesCount = unreadMessage.unreadMessagesCount ?? 0
        }
        
        return unreadMessagesCount
    }
    
    // MARK: - Navigations
    private func resetRootController() {
        // Inbox list update notification
        NotificationCenter.default.post(name: .logoutCompleteNotificationID, object: nil)
    }
    
    func onTapSideMenu(with menu: Menu) {
        switch menu {
        case .inbox,
             .draft,
             .outbox,
             .sent,
             .spam,
             .starred,
             .trash,
             .allMails,
             .unread,
             .archive:
            applyFolderAction(of: menu)
        case .manageFolders:
            viewController?.router?.showManageFoldersViewController(withList: folders, user: user)
        }
    }
    
    func onTapSideMenu(with preference: Menu.Preferences) {
        switch preference {
        case .contacts:
            viewController?.router?.showContactsViewController(withUserContacts: contacts,
                                                               isContactEncrypted: user.settings.isContactsEncrypted ?? false)
        case .settings:
            viewController?.router?.showSettingsViewController(withUser: user)
//        case .FAQ:
//            viewController?.router?.showFAQ()
        case .help:
            openSupportURL()
        case .logout:
            viewController?.presenter?.logOut()
        }
    }
    
    func onTapCustomFolder(with folderName: String) {
        let formattedFolderName = formatFolderNameLikeUrl(folderName: folderName)
        viewController?.inbox?.update(menu: CustomFolderMenu.customFolder(formattedFolderName))
        if let menu = SharedInboxState.shared.selectedMenu {
            applyFolderAction(of: menu)
        }
    }
}
// MARK: - Folder Actions
private extension InboxSideMenuInteractor {
    func applyFolderAction(of menu: MenuConfigurable) {
        guard let inbox = viewController?.inbox else {
            if let vc = viewController?.commonInboxVC {
                viewController?.setup(inboxVC: vc)
                applyFolderAction(of: menu)
            }
            return
        }
        
        inbox.presenter?.interactor?.update(offset: 0)
        inbox.dataSource?.clearFilters()
        inbox.dataSource?.resetSelectionMode()
        
        inbox.presenter?.interactor?.updateMessages(withUndo: "",
                                                    silent: false,
                                                    menu: menu
        )
        
        updateInboxBottomBar(with: viewController?.dataSource?.unreadMessages ?? [], for: inbox)
        viewController?.router?.showMessagesViewController(vc: inbox)
    }

    func openSupportURL() {
        if let url = URL(string: "mailto:\(GeneralConstant.Link.SupportURL.rawValue)") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    func formatFolderNameLikeUrl(folderName: String) -> String {
        let formattedFolderName = folderName.replacingOccurrences(of: " ", with: "%20")
        return formattedFolderName
    }
}
