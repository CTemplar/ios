//
//  InboxSideMenuInteractor.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 22.10.2018.
//  Copyright © 2018 CTemplar. All rights reserved.
//

import Foundation
import Utility
import Networking
import UIKit
import Login

class InboxSideMenuInteractor {
    
    var viewController  : InboxSideMenuViewController?
    var presenter       : InboxSideMenuPresenter?
    var apiService      : APIService?

    func logOut() {
        Loader.start()
        apiService?.logOut(completionHandler: { [weak self] (isSucceeded) in
            DispatchQueue.main.async {
                Loader.stop()
                if isSucceeded {
                    self?.resetAppIconBadgeValue()
                    self?.resetRootController()
                } else {
                   if let currentVC = self?.viewController {
                        currentVC.showAlert(with: "logoutErrorTitle".localized(),
                                   message: "logoutErrorMessage".localized(),
                                   buttonTitle: Strings.Button.closeButton.localized)
                    }
                }
            }
        })
    }
    
    private func resetAppIconBadgeValue() {
        UIApplication.shared.applicationIconBadgeNumber = 0
    }

    private func resetRootController() {
        guard let presenter = viewController?.sideMenuController else {
            return
        }
        
        let loginCoordinator = LoginCoordinator()
        loginCoordinator.showLogin(from: presenter, withSideMenu: presenter)
    }
    
    func setCustomFoldersData(folderList: FolderList) {
        
        if let folders = folderList.foldersList {
            
            self.viewController?.dataSource?.customFoldersArray = folders
            self.viewController?.dataSource?.reloadData()
        }
    }
    
    func customFoldersList() {
        
        Loader.start()
        
        apiService?.customFoldersList(limit: 200, offset: 0) {(result) in
            
            switch(result) {
                
            case .success(let value):
                //print("value:", value)
                
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
    
    func userMyself() {
        
        apiService?.userMyself() {(result) in
            
            switch(result) {
                
            case .success(let value):
                print("userMyself value:", value)
                
            case .failure(let error):
                print("error:", error)
                self.viewController?.showAlert(with: "User Myself Error",
                           message: error.localizedDescription,
                           buttonTitle: Strings.Button.closeButton.localized)
            }
        }
    }
    
    func setUnreadCounters(array: Array<UnreadMessagesCounter>) {
        
        self.viewController?.dataSource?.unreadMessagesArray = array
        self.viewController?.dataSource?.reloadData()
        
        updateInboxBottomBar(with: array, for: self.viewController!.inboxViewController)
    }
    
    func setUnReadCounters(array: Array<UnreadMessagesCounter>, folder: String) {
        self.viewController?.dataSource?.unreadMessagesArray = array
        self.viewController?.dataSource?.reloadData()
        
        switch folder {
        case InboxSideMenuOptionsName.inbox.rawValue:
            updateInboxBottomBar(with: array, for: self.viewController!.inboxViewController)
            break
        case InboxSideMenuOptionsName.outbox.rawValue:
            updateInboxBottomBar(with: array, for: self.viewController!.outboxViewController)
            break
        case InboxSideMenuOptionsName.starred.rawValue:
            updateInboxBottomBar(with: array, for: self.viewController!.starredViewController)
            break
        case InboxSideMenuOptionsName.archive.rawValue:
            updateInboxBottomBar(with: array, for: self.viewController!.archiveViewController)
            break
        case InboxSideMenuOptionsName.spam.rawValue:
            updateInboxBottomBar(with: array, for: self.viewController!.spamViewController)
            break
        case InboxSideMenuOptionsName.trash.rawValue:
            updateInboxBottomBar(with: array, for: self.viewController!.trashViewController)
            break
        default:
            updateInboxBottomBar(with: array, for: self.viewController!.customFoldersViewController)
        }
    }
    
    func updateInboxBottomBar(with array: Array<UnreadMessagesCounter>, for vc: InboxViewController) {
    
//        let inboxViewController = self.viewController?.inboxViewController
        
        let filterEnabled = vc.presenter?.interactor?.filterEnabled() ?? false
        let totalEmails = vc.presenter?.interactor?.totalItems ?? 0
        let currentFolder = vc.currentFolderFilter
        
        let unreadEmails = getUnreadMessagesCount(folderName: currentFolder)
        
        vc.presenter?.interactor?.unreadEmails = unreadEmails
        vc.presenter?.setupUI(emailsCount: totalEmails, unreadEmails: unreadEmails, filterEnabled: filterEnabled)
    }
    
    func unreadMessagesCounter() {
        apiService?.unreadMessagesCounter() {(result) in
            
            switch(result) {
                
            case .success(let value):
                //print("unreadMessagesCounter value:", value)
                
                var unreadMessagesCounterArray: Array<UnreadMessagesCounter> = []
                
                for objectDictionary in (value as? Dictionary<String, Any>)! {
                    
                    let unreadMessageCounter = UnreadMessagesCounter(key: objectDictionary.key, value: objectDictionary.value)
                    unreadMessagesCounterArray.append(unreadMessageCounter)
                }
                
                self.setUnreadCounters(array: unreadMessagesCounterArray)
                
            case .failure(let error):
                print("error:", error)
            }
        }
    }
    
//    func dismissSideMenuAndTopController() {
//        
//        if (!Device.IS_IPAD) {
//            self.viewController?.dismiss(animated: true, completion: {
//                if let parentViewController = self.viewController?.currentParentViewController {
//                    parentViewController.navigationController?.popToRootViewController(animated: true)
//                }
//            })
//        } else {
//            self.viewController?.splitViewController?.toggleMasterView()
//        
//            if let parentViewController = self.viewController?.currentParentViewController {
//                parentViewController.navigationController?.popToRootViewController(animated: true)
//            }        
//        }
//    }
    
    func selectSideMenuAction(optionName: String) {
        
        switch optionName {
        case InboxSideMenuOptionsName.inbox.rawValue :
            self.applyInboxAction()
        case InboxSideMenuOptionsName.draft.rawValue :
            self.applyOtherFolderAction(with: self.viewController!.draftViewController)
        case InboxSideMenuOptionsName.sent.rawValue :
            self.applyOtherFolderAction(with: self.viewController!.sentViewControllet)
        case InboxSideMenuOptionsName.outbox.rawValue :
            self.applyOtherFolderAction(with: self.viewController!.outboxViewController)
        case InboxSideMenuOptionsName.starred.rawValue :
            self.applyOtherFolderAction(with: self.viewController!.starredViewController)
        case InboxSideMenuOptionsName.archive.rawValue :
            self.applyOtherFolderAction(with: self.viewController!.archiveViewController)
        case InboxSideMenuOptionsName.spam.rawValue :
            self.applyOtherFolderAction(with: self.viewController!.spamViewController)
        case InboxSideMenuOptionsName.trash.rawValue :
            self.applyOtherFolderAction(with: self.viewController!.trashViewController)
        case InboxSideMenuOptionsName.allMails.rawValue :
            self.applyOtherFolderAction(with: self.viewController!.allMailViewController)
        case InboxSideMenuOptionsName.contacts.rawValue :
            self.viewController?.router?.showContactsViewController()
        case InboxSideMenuOptionsName.settings.rawValue :
            self.viewController?.router?.showSettingsViewController()
        case InboxSideMenuOptionsName.help.rawValue:
            self.openSupportURL()
        case InboxSideMenuOptionsName.FAQ.rawValue:
            self.viewController?.router?.showFAQ()
        case InboxSideMenuOptionsName.manageFolders.rawValue :
            self.viewController?.router?.showManageFoldersViewController()
        case InboxSideMenuOptionsName.logout.rawValue :
            self.viewController?.presenter?.logOut()
            break
        default:
            print("do nothing")
        }
    }
    
    func applyInboxAction() {
        let vc = self.viewController?.inboxViewController
        vc?.presenter?.interactor?.updateMessages(withUndo: "", silent: true)
        updateInboxBottomBar(with: (self.viewController?.dataSource!.unreadMessagesArray)!, for: vc!)
        self.viewController?.router?.showMessagesViewController(vc: vc!)
    }
    
    func applyOtherFolderAction(with vc: InboxViewController) {
        vc.presenter?.interactor?.updateMessages(withUndo: "", silent: true)
        updateInboxBottomBar(with: (self.viewController?.dataSource!.unreadMessagesArray)!, for: vc)
        self.viewController?.router?.showMessagesViewController(vc: vc)
    }
    
    func applyCustomFolderAction(folderName: String) {
        let formattedFolderName = self.formatFolderNameLikeUrl(folderName: folderName)
        
        let vc = self.viewController!.customFoldersViewController
        vc.currentFolder = folderName
        vc.currentFolderFilter = formattedFolderName
        vc.dataSource?.currentOffset = 0
        vc.presenter?.interactor?.offset = 0
        vc.allMessagesArray = []
        vc.presenter?.interactor?.updateMessages(withUndo: "", silent: false)
        vc.presenter?.interactor?.clearFilters()
        
        self.applyOtherFolderAction(with: vc)
    }
    
    func formatFolderNameLikeUrl(folderName: String) -> String {
        
        let formattedFolderName = folderName.replacingOccurrences(of: " ", with: "%20")
        
        return formattedFolderName
    }
    
    func apiFolderName(folderName: String) -> String {
        
        var apiFolderName = ""
        
        switch folderName {
        case InboxSideMenuOptionsName.inbox.rawValue:
            apiFolderName = MessagesFoldersName.inbox.rawValue
            break
        case InboxSideMenuOptionsName.draft.rawValue:
            apiFolderName = MessagesFoldersName.draft.rawValue
            break
        case InboxSideMenuOptionsName.sent.rawValue:
            apiFolderName = MessagesFoldersName.sent.rawValue
            break
        case InboxSideMenuOptionsName.outbox.rawValue:
            apiFolderName = MessagesFoldersName.outbox.rawValue
            break
        case InboxSideMenuOptionsName.starred.rawValue:
            apiFolderName = MessagesFoldersName.starred.rawValue
            break
        case InboxSideMenuOptionsName.archive.rawValue:
            apiFolderName = MessagesFoldersName.archive.rawValue
            break
        case InboxSideMenuOptionsName.spam.rawValue:
            apiFolderName = MessagesFoldersName.spam.rawValue
            break
        case InboxSideMenuOptionsName.trash.rawValue:
            apiFolderName = MessagesFoldersName.trash.rawValue
            break
        default:
            apiFolderName = folderName //custom folder name
            break
        }
        
        return apiFolderName
    }
    
    func getUnreadMessagesCount(folderName: String) -> Int {
        
        var unreadMessagesCount = 0
        
        var selfDestructUnreadMessagesCount = 0
        var delayedDeliveryUnreadMessagesCount = 0
        var deadManUnreadMessagesCount = 0
        
        for object in (self.viewController?.dataSource?.unreadMessagesArray)! {
            
            if object.folderName == self.apiFolderName(folderName: folderName) {
                unreadMessagesCount = object.unreadMessagesCount!
            }
            
            //avoid API problem
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
        
        if self.apiFolderName(folderName: folderName) == MessagesFoldersName.draft.rawValue { //avoid API problem
            unreadMessagesCount = 0
        }
        
        if self.apiFolderName(folderName: folderName) == MessagesFoldersName.outbox.rawValue { //avoid API problem
            unreadMessagesCount = selfDestructUnreadMessagesCount + delayedDeliveryUnreadMessagesCount + deadManUnreadMessagesCount
        }
        
        return unreadMessagesCount
    }
    
    func openSupportURL() {
        
        if let url = URL(string: "mailto:\(k_supportURL)") {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
}
