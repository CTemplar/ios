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
    
    func customFoldersList() {
        
        HUD.show(.progress)
        
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
            
            HUD.hide()
        }
    }
    
    func setCustomFoldersData(folderList: FolderList) {
        
         if let folders = folderList.foldersList {
         
            self.viewController?.dataSource?.customFoldersArray = folders
            self.viewController?.dataSource?.reloadData()
         }
    }
    
    func selectAction(optionName: String) {
        
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
        case InboxSideMenuOptionsName.logout.rawValue :
            self.viewController?.presenter?.logOut()
            break
        default:
            print("do nothing")
        }
    }
    
    func applyCustomFolderAction(folderName: String) {
        
        let formattedFolderName = self.formatFolderNameLikeUrl(folderName: folderName)
        
        self.applyFirstSectionAction(folder: folderName, filter: formattedFolderName)
    }
    
    func formatFolderNameLikeUrl(folderName: String) -> String {
        
        let formattedFolderName = folderName.replacingOccurrences(of: " ", with: "%20")
        
        return formattedFolderName
    }
    
    func applyFirstSectionAction(folder: String, filter: String) {
        
        self.viewController?.currentParentViewController.currentFolder = folder
        self.viewController?.currentParentViewController.currentFolderFilter = filter
        self.viewController?.currentParentViewController.presenter?.interactor?.updateMessages(withUndo: "")//loadMessages(folder: filter)
        self.viewController?.currentParentViewController.presenter?.interactor?.clearFilters()
        self.viewController?.dismiss(animated: true, completion: nil)
    }
    
    func getUnreadMessagesCount(folderName: String, unreadMessages: UnreadMessages) -> Int {
        
        var unreadMessagesCount = 0
        
        switch folderName {
        case InboxSideMenuOptionsName.inbox.rawValue:
            if let inboxUnreadMessages = unreadMessages.inbox {
                unreadMessagesCount = inboxUnreadMessages
            }
            break
        case InboxSideMenuOptionsName.draft.rawValue:
            if let draftUnreadMessages = unreadMessages.draft {
                unreadMessagesCount = draftUnreadMessages
            }
            break
        case InboxSideMenuOptionsName.sent.rawValue:
            break
        case InboxSideMenuOptionsName.outbox.rawValue:
            break
        case InboxSideMenuOptionsName.starred.rawValue:
            if let starredUnreadMessages = unreadMessages.starred {
                unreadMessagesCount = starredUnreadMessages
            }
            break
        case InboxSideMenuOptionsName.archive.rawValue:
            if let archiveUnreadMessages = unreadMessages.archive {
                unreadMessagesCount = archiveUnreadMessages
            }
            break
        case InboxSideMenuOptionsName.spam.rawValue:
            if let spamUnreadMessages = unreadMessages.spam {
                unreadMessagesCount = spamUnreadMessages
            }
            break
        case InboxSideMenuOptionsName.trash.rawValue:
            if let trashUnreadMessages = unreadMessages.trash {
                unreadMessagesCount = trashUnreadMessages
            }
            break
            
        default:
            break
        }
        
        return unreadMessagesCount
    }
}
