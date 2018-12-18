//
//  MoveToInteractor.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 06.11.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import AlertHelperKit
import PKHUD

class MoveToInteractor {
    
    var viewController      : MoveToViewController?
    var presenter           : MoveToPresenter?
    var apiService          : APIService?
    
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
                AlertHelperKit().showAlert(self.viewController!, title: "Get Folders Error", message: error.localizedDescription, button: "closeButton".localized())
            }
            
            HUD.hide()
        }
    }
    
    func setCustomFoldersData(folderList: FolderList) {
        
        if let folders = folderList.foldersList {
            
            if folders.count > 0 {
                self.viewController?.addFolderButton.isHidden = true
                self.viewController?.manageFolderButton.isHidden = false
            } else {
                self.viewController?.addFolderButton.isHidden = false
                self.viewController?.manageFolderButton.isHidden = true
            }
            
            self.viewController?.dataSource?.customFoldersArray = folders
            self.viewController?.dataSource?.reloadData()
        }
    }
    
    func moveMessagesListTo(selectedMessagesIdArray: Array<Int>, folder: String) {       
        
        var messagesIDList : String = ""
        
        for message in selectedMessagesIdArray {
            messagesIDList = messagesIDList + message.description + ","
        }
        
        messagesIDList.remove(at: messagesIDList.index(before: messagesIDList.endIndex))
        
        apiService?.updateMessages(messageID: "", messagesIDIn: messagesIDList, folder: folder, starred: false, read: false, updateFolder: true, updateStarred: false, updateRead: false)  {(result) in
            
            switch(result) {
                
            case .success( _):
                //print("value:", value)
                print("move list to another folder")
                
                self.viewController?.dismiss(animated: true, completion: nil)
                
            case .failure(let error):
                print("error:", error)
                AlertHelperKit().showAlert(self.viewController!, title: "Messages Error", message: error.localizedDescription, button: "closeButton".localized())
            }
        }
    }
    
    func applyButtonPressed() {
        
        if (self.viewController?.selectedMessagesIDArray.count)! > 0 {
            if self.viewController?.dataSource?.selectedFolderIndex != nil {
                
                let folderName = self.folderNameBy(selectedIndex: (self.viewController?.dataSource?.selectedFolderIndex)!)
                
                if folderName.count > 0 {
                    self.moveMessagesListTo(selectedMessagesIdArray: (self.viewController?.selectedMessagesIDArray)!, folder: folderName)
                }
            }
        }
    }
    
    func folderNameBy(selectedIndex: Int) -> String {
        
        var folderName : String = ""
        
        for (index, folder) in (self.viewController?.dataSource?.customFoldersArray)!.enumerated() {
            if index == selectedIndex {
                if let name = folder.folderName {
                    folderName = name
                }
            }
        }
        
        return folderName
    }
}
