//
//  InboxSideMenuInteractor.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 22.10.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import AlertHelperKit
import PKHUD

class InboxSideMenuInteractor {
    
    var viewController  : InboxSideMenuViewController?
    var presenter       : InboxSideMenuPresenter?
    var apiService      : APIService?

    func logOut() {
        
        self.viewController?.dataSource?.selectedIndexPath = IndexPath(row: 0, section: SideMenuSectionIndex.mainFolders.rawValue)
        self.viewController?.inboxViewController.currentFolder  = InboxSideMenuOptionsName.inbox.rawValue
        self.viewController?.inboxViewController.currentFolderFilter = MessagesFoldersName.inbox.rawValue
        
        if (!Device.IS_IPAD) {
            self.viewController?.dismiss(animated: true, completion: {
                if let parentViewController = self.viewController?.currentParentViewController {
                    parentViewController.navigationController?.popViewController(animated: true)
                }
            })
            
            self.viewController?.inboxViewController.dismiss(animated: false, completion: {
                self.viewController?.mainViewController?.showLoginViewController()
            })
        } else {
            self.viewController?.splitViewController?.dismiss(animated: false, completion: {
                self.viewController?.mainViewController?.showLoginViewController()
            })
        }
        
        apiService?.logOut()  {(result) in
            switch(result) {
                
            case .success(let value):
                print("value:", value)
                
            case .failure(let error):
                print("error:", error)
                
            }
        }
    }
    
    func setCustomFoldersData(folderList: FolderList) {
        
        if let folders = folderList.foldersList {
            
            self.viewController?.dataSource?.customFoldersArray = folders
            self.viewController?.dataSource?.reloadData()
        }
    }
    
    func customFoldersList() {
        
        HUD.show(.progress)
        
        apiService?.customFoldersList(limit: 200, offset: 0) {(result) in
            
            switch(result) {
                
            case .success(let value):
                //print("value:", value)
                
                let folderList = value as! FolderList
                
                self.setCustomFoldersData(folderList: folderList)
                
                self.unreadMessagesCounter()
                
            case .failure(let error):
                print("error:", error)
                AlertHelperKit().showAlert(self.viewController!, title: "Messages Error", message: error.localizedDescription, button: "closeButton".localized())
            }
            
            HUD.hide()
        }
    }
    
    func userMyself() {
        
        apiService?.userMyself() {(result) in
            
            switch(result) {
                
            case .success(let value):
                print("userMyself value:", value)
                
            case .failure(let error):
                print("error:", error)
                AlertHelperKit().showAlert(self.viewController!, title: "User Myself Error", message: error.localizedDescription, button: "closeButton".localized())
            }
        }
    }
    
    func setUnreadCounters(array: Array<UnreadMessagesCounter>) {
        
         self.viewController?.dataSource?.unreadMessagesArray = array
         self.viewController?.dataSource?.reloadData()
    }
    
    func unreadMessagesCounter() {
        
        //HUD.show(.progress)
        
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
                AlertHelperKit().showAlert(self.viewController!, title: "Messages Error", message: error.localizedDescription, button: "closeButton".localized())
            }
            
            HUD.hide()
        }
    }
    
    func dismissSideMenuAndTopController() {
        
        if (!Device.IS_IPAD) {
            self.viewController?.dismiss(animated: true, completion: {
                if let parentViewController = self.viewController?.currentParentViewController {
                    parentViewController.navigationController?.popToRootViewController(animated: true)
                }
            })
        } else {
            self.viewController?.splitViewController?.toggleMasterView()
        
            if let parentViewController = self.viewController?.currentParentViewController {
                parentViewController.navigationController?.popToRootViewController(animated: true)
            }        
        }
    }
    
    func selectSideMenuAction(optionName: String) {
        
        switch optionName {
        case InboxSideMenuOptionsName.inbox.rawValue :
            self.applyFirstSectionAction(folder: optionName, filter: MessagesFoldersName.inbox.rawValue)
            break
        case InboxSideMenuOptionsName.draft.rawValue :
            self.applyFirstSectionAction(folder: optionName, filter: MessagesFoldersName.draft.rawValue)
            break
        case InboxSideMenuOptionsName.sent.rawValue :
            self.applyFirstSectionAction(folder: optionName, filter: MessagesFoldersName.sent.rawValue)
            break
        case InboxSideMenuOptionsName.outbox.rawValue :
            self.applyFirstSectionAction(folder: optionName, filter: MessagesFoldersName.outbox.rawValue)
            break
        case InboxSideMenuOptionsName.starred.rawValue :
            self.applyFirstSectionAction(folder: optionName, filter: MessagesFoldersName.starred.rawValue)
            break
        case InboxSideMenuOptionsName.archive.rawValue :
            self.applyFirstSectionAction(folder: optionName, filter: MessagesFoldersName.archive.rawValue)
            break
        case InboxSideMenuOptionsName.spam.rawValue :
            self.applyFirstSectionAction(folder: optionName, filter: MessagesFoldersName.spam.rawValue)
            break
        case InboxSideMenuOptionsName.trash.rawValue :
            self.applyFirstSectionAction(folder: optionName, filter: MessagesFoldersName.trash.rawValue)
            break
        case InboxSideMenuOptionsName.allMails.rawValue :
            self.applyFirstSectionAction(folder: optionName, filter: "")
            break
        case InboxSideMenuOptionsName.contacts.rawValue :
            if (!Device.IS_IPAD) {
                self.dismissSideMenuAndTopController()
            }
            self.viewController?.router?.showContactsViewController()
        case InboxSideMenuOptionsName.settings.rawValue :
            if (!Device.IS_IPAD) {
                self.dismissSideMenuAndTopController()
            }
            self.viewController?.router?.showSettingsViewController()
            break
        case InboxSideMenuOptionsName.manageFolders.rawValue :
            if (!Device.IS_IPAD) {
                self.dismissSideMenuAndTopController()
            }
            self.viewController?.router?.showManageFoldersViewController()
            break
        case InboxSideMenuOptionsName.logout.rawValue :
            self.viewController?.presenter?.logOut()
            break
        default:
            print("do nothing")
        }
    }
    
    func applyFirstSectionAction(folder: String, filter: String) {
        
        let currentViewController = self.viewController?.inboxViewController
        
        currentViewController?.currentFolder = folder
        currentViewController?.currentFolderFilter = filter
        //currentViewController?.presenter?.interactor?.updateMessages(withUndo: "")//loadMessages(folder: filter)
        
        currentViewController?.presenter?.interactor?.setInboxData(messages: (currentViewController?.allMessagesList)!, folderFilter: filter)
        currentViewController?.presenter?.interactor?.clearFilters()
        
        self.dismissSideMenuAndTopController()
    }
    
    func applyCustomFolderAction(folderName: String) {
        
        //let formattedFolderName = self.formatFolderNameLikeUrl(folderName: folderName)
        
        self.applyFirstSectionAction(folder: folderName, filter: folderName)
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
}
