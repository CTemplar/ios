//
//  SearchInteractor.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 09.11.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import AlertHelperKit
import PKHUD

class SearchInteractor {
    
    var viewController  : SearchViewController?
    var presenter       : SearchPresenter?
    var apiService      : APIService?
    var pgpService      : PGPService?
    
    func setData(messages: EmailMessagesList) {
        
        if let emailsArray = messages.messagesList {
            self.viewController?.dataSource?.messagesArray = emailsArray
        }
        
        self.viewController?.dataSource?.reloadData()
    }

    func allMessagesList() {
        
        HUD.show(.progress)
        
        apiService?.messagesList(folder: "") {(result) in
            
            switch(result) {
                
            case .success(let value):
                //print("value:", value)
                
                let emailMessages = value as! EmailMessagesList
                self.setData(messages: emailMessages)
                
                self.customFoldersList()
                
            case .failure(let error):
                HUD.hide()
                print("error:", error)
                AlertHelperKit().showAlert(self.viewController!, title: "Messages Error", message: error.localizedDescription, button: "closeButton".localized())
            }
            
           // HUD.hide()
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
            
            HUD.hide()
        }
    }
}
