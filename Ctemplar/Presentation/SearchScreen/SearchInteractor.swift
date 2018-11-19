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
        
        apiService?.messagesList(folder: "", messagesIDIn: "", seconds: 0) {(result) in
            
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
    
    func setFilteredList(searchText: String) {
        
        let filteredSubjectsList = (self.viewController?.dataSource?.messagesArray.filter({( message : EmailMessage) -> Bool in
            return (message.subject?.lowercased().contains(searchText.lowercased()))!
        }))!
        
        let filteredSendersList = (self.viewController?.dataSource?.messagesArray.filter({( message : EmailMessage) -> Bool in
            return (message.sender?.lowercased().contains(searchText.lowercased()))!
        }))!
        
        var filteredDuplicatesMessagesList : Array<EmailMessage> = []
        
        for message in filteredSendersList {
            filteredDuplicatesMessagesList = filteredSubjectsList.filter { $0.messsageID != message.messsageID }
        }
        
        let filteredList = filteredSendersList + filteredDuplicatesMessagesList
        //let filteredList = filteredSendersList + filteredSubjectsList
        
        updateDataSource(searchText: searchText, filteredList: filteredList)
    }
    
    func updateDataSource(searchText: String, filteredList: Array<EmailMessage>) {
        
        self.viewController?.dataSource?.filtered =  (self.viewController?.isFiltering())!
        self.viewController?.dataSource?.filteredArray = filteredList
        self.viewController?.dataSource?.searchText = searchText
        self.viewController?.dataSource?.reloadData()
    }
    
    func folderFilterByFolderName(folder: String) -> String  {
        
        for folderName in MessagesFoldersName.allCases {
            if folderName.rawValue == folder {
               return folderName.rawValue
            }
        }
        
        return ""
    }
}
