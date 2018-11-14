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
        
        //HUD.show(.progress)
        
        apiService?.customFoldersList(limit: 200, offset: 0) {(result) in
            
            switch(result) {
                
            case .success(let value):
                //print("value:", value)
                
                let folderList = value as! FolderList
                
                self.setCustomFoldersData(folderList: folderList)
                
            case .failure(let error):
                print("error:", error)
                AlertHelperKit().showAlert(self.viewController!, title: "Messages Error", message: error.localizedDescription, button: "closeButton".localized())
            }
            
           // HUD.hide()
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
                print("unreadMessagesCounter value:", value)
                
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
    
    func selectAction(optionName: String) {
        /*
        if (self.viewController?.currentParentViewController.isKind(of: InboxViewController.self))! {
            self.selectInboxAction(optionName: optionName)
        }
       
        if (self.viewController?.currentParentViewController.isKind(of: ContactsViewController.self))! {
            self.viewController?.dismiss(animated: true, completion: {

                self.viewController?.currentParentViewController.navigationController?.popViewController(animated: true)
            })
        }*/
        
        
        
    }
        
    func selectInboxAction(optionName: String) {
        
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
            self.viewController?.router?.showContactsViewController()
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
        currentViewController?.presenter?.interactor?.updateMessages(withUndo: "")//loadMessages(folder: filter)
        currentViewController?.presenter?.interactor?.clearFilters()
        
        self.viewController?.dismiss(animated: true, completion: nil)
    }
    
    func applyCustomFolderAction(folderName: String) {
        
        let formattedFolderName = self.formatFolderNameLikeUrl(folderName: folderName)
        
        self.applyFirstSectionAction(folder: folderName, filter: formattedFolderName)
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
        
        for object in (self.viewController?.dataSource?.unreadMessagesArray)! {
            
            if object.folderName == self.apiFolderName(folderName: folderName) {
                unreadMessagesCount = object.unreadMessagesCount!
            }
        }
        
        return unreadMessagesCount
    }
}
