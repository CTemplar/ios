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
            self.viewController?.currentParentViewController.currentFolder = InboxSideMenuOptionsName.inbox.rawValue
            self.viewController?.currentParentViewController.currentFolderFilter = MessagesFoldersName.inbox.rawValue
            self.viewController?.currentParentViewController.presenter?.loadMessages(folder: MessagesFoldersName.inbox.rawValue)
            self.viewController?.dismiss(animated: true, completion: nil)
            break
        case InboxSideMenuOptionsName.sent.rawValue :
            self.viewController?.currentParentViewController.currentFolder = InboxSideMenuOptionsName.sent.rawValue
            self.viewController?.currentParentViewController.currentFolderFilter = MessagesFoldersName.sent.rawValue
            self.viewController?.currentParentViewController.presenter?.loadMessages(folder: MessagesFoldersName.sent.rawValue)
            self.viewController?.dismiss(animated: true, completion: nil)
            break
        case InboxSideMenuOptionsName.logout.rawValue :
            self.viewController?.presenter?.logOut()
            break
        default:
            print("do nothing")
        }
    }
}
