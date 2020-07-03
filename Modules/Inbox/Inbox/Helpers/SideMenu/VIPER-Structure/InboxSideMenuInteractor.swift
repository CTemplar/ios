import Foundation
import Utility
import Networking
import UIKit
import Login

final class InboxSideMenuInteractor {
    // MARK: Properties
    private weak var viewController: InboxSideMenuController?
    private weak var presenter: InboxSideMenuPresenter?
    private let apiService = NetworkManager.shared.apiService
    
    // MARK: - Setup
    func setup(viewController: InboxSideMenuController) {
        self.viewController = viewController
    }
    
    func setup(presenter: InboxSideMenuPresenter) {
        self.presenter = presenter
    }

    // MARK: - API Handlers
    func logOut() {
        Loader.start()
        apiService.logOut(completionHandler: { [weak self] (isSucceeded) in
            DispatchQueue.main.async {
                Loader.stop()
                if isSucceeded {
                    self?.resetAppIconBadgeValue()
                    self?.resetRootController()
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
        
        switch folder {
        case .inbox:
            updateInboxBottomBar(with: counters, for: viewController?.inbox)
        case .outbox:
            updateInboxBottomBar(with: counters, for: viewController?.outbox)
        case .starred:
            updateInboxBottomBar(with: counters, for: viewController?.starred)
        case .archive:
            updateInboxBottomBar(with: counters, for: viewController?.archive)
        case .spam:
            updateInboxBottomBar(with: counters, for: viewController?.spam)
        case .trash:
            updateInboxBottomBar(with: counters, for: viewController?.trash)
        case .allMails:
            updateInboxBottomBar(with: counters, for: viewController?.allMail)
        default:
            updateInboxBottomBar(with: counters, for: viewController?.customFolder)
        }
    }
    
    func updateInboxBottomBar(with unreadMessages: [UnreadMessagesCounter],
                              for vc: InboxViewController?) {
        let filterEnabled = vc?.dataSource?.filterEnabled ?? false
        
        let totalEmails = vc?.presenter?.interactor?.totalItems ?? 0
        
        let currentFolder = vc?.selectedMenu ?? .inbox
        
        let unreadEmails = getUnreadMessagesCount(with: viewController?.dataSource?.unreadMessages ?? [],
                                                  folder: currentFolder.rawValue,
                                                  apiFolderName: currentFolder.rawValue
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
        
        for object in unreadMessages {
            if object.folderName == apiFolderName {
                unreadMessagesCount = object.unreadMessagesCount!
            }

            if object.folderName == MessagesFoldersName.outboxSD.rawValue {
                selfDestructUnreadMessagesCount = object.unreadMessagesCount!
            }
            
            if object.folderName == MessagesFoldersName.outboxDD.rawValue {
                delayedDeliveryUnreadMessagesCount = object.unreadMessagesCount!
            }
            
            if object.folderName == MessagesFoldersName.outboxDM.rawValue {
                deadManUnreadMessagesCount = object.unreadMessagesCount!
            }
        }
        
        if apiFolderName == MessagesFoldersName.draft.rawValue {
            unreadMessagesCount = 0
        }
        
        if apiFolderName == MessagesFoldersName.outbox.rawValue {
            unreadMessagesCount = selfDestructUnreadMessagesCount + delayedDeliveryUnreadMessagesCount + deadManUnreadMessagesCount
        }
        
        return unreadMessagesCount
    }
    
    // MARK: - Navigations
    private func resetRootController() {
        guard let presenter = viewController?.sideMenuController else {
            return
        }
        let loginCoordinator = LoginCoordinator()
        loginCoordinator.showLogin(from: presenter, withSideMenu: presenter)
    }
    
    func onTapSideMenu(with menu: Menu) {
        switch menu {
        case .inbox:
            applyInboxAction()
        case .draft:
            applyOtherFolderAction(with: viewController?.draft)
        case .outbox:
            applyOtherFolderAction(with: viewController?.outbox)
        case .sent:
            applyOtherFolderAction(with: viewController?.sent)
        case .spam:
            applyOtherFolderAction(with: viewController?.spam)
        case .starred:
            applyOtherFolderAction(with: viewController?.starred)
        case .trash:
            applyOtherFolderAction(with: viewController?.trash)
        case .archive:
            applyOtherFolderAction(with: viewController?.archive)
        case .allMails:
            applyOtherFolderAction(with: viewController?.allMail)
        case .manageFolders:
            viewController?.router?.showManageFoldersViewController()
        }
    }
    
    func onTapSideMenu(with preference: Menu.Preferences) {
        switch preference {
        case .contacts:
            viewController?.router?.showContactsViewController()
        case .settings:
            viewController?.router?.showSettingsViewController()
        case .FAQ:
            viewController?.router?.showFAQ()
        case .help:
            openSupportURL()
        case .logout:
            viewController?.presenter?.logOut()
        }
    }
    
    func onTapCustomFolder(with folderName: String) {
        
    }
}
// MARK: - Folder Actions
private extension InboxSideMenuInteractor {
    func applyInboxAction() {
        // TODO: Implementation required
    }
    
    func applyOtherFolderAction(with viewController: InboxViewController?) {
        // TODO: Implementation required
    }
    
    func applyCustomFolderAction() {
        // TODO: Implementation required
    }
    
    func openSupportURL() {
        if let url = URL(string: "mailto:\(GeneralConstant.Link.SupportURL)") {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
}
