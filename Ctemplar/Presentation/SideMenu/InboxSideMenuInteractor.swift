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
    
    func getUnreadMessagesCount(folderName: String) -> Int {
        
        var unreadMessagesCount = 0
        
        for object in (self.viewController?.dataSource?.unreadMessagesArray)! {
            
            if object.folderName == self.apiFolderName(folderName: folderName) {
                unreadMessagesCount = object.unreadMessagesCount!
            }
        }
        
        return unreadMessagesCount
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
}
