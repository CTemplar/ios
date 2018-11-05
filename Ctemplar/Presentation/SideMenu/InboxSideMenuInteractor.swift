//
//  InboxSideMenuInteractor.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 22.10.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import AlertHelperKit

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
    
    func applyFirstSectionAction(folder: String, filter: String) {
        
        self.viewController?.currentParentViewController.currentFolder = folder
        self.viewController?.currentParentViewController.currentFolderFilter = filter
        self.viewController?.currentParentViewController.presenter?.interactor?.updateMessages(withUndo: "")//loadMessages(folder: filter)
        self.viewController?.currentParentViewController.presenter?.interactor?.clearFilters()
        self.viewController?.dismiss(animated: true, completion: nil)
    }
}
