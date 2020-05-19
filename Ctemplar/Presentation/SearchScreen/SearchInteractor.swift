//
//  SearchInteractor.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 09.11.2018.
//  Copyright © 2018 CTemplar. All rights reserved.
//

import Foundation
import AlertHelperKit
import PKHUD

class SearchInteractor {
    
    var viewController  : SearchViewController?
    var presenter       : SearchPresenter?
    var apiService      : APIService?
    var pgpService      : PGPService?
    
    var totalItems = 0
    var offset = 0
    var getCount = 0
    var currentCount = 0
    
    func setData(messages: EmailMessagesList) {
        
        if offset == 0 {
            currentCount = 0
            self.viewController?.dataSource?.messagesArray.removeAll()
        }
        
        if let emailsArray = messages.messagesList {
            //self.viewController?.dataSource?.messagesArray = emailsArray
            self.viewController?.dataSource?.messagesArray.append(contentsOf: emailsArray)
            print("total search messagesArray:", self.viewController?.dataSource?.messagesArray.count as Any)
        }
        
        self.viewController?.dataSource?.reloadData()
    }
    
    func getAllMessagesPageByPage() {
        
        if self.offset >= self.totalItems && self.offset > 0 {
            HUD.hide()
            return
        }
    
        if getCount > 0 {
            if currentCount > 0 {
                allMessagesList()
                currentCount = currentCount - 1
            }
        } else {
            allMessagesList()
        }
    }
    
    func allMessagesList() {
        
        HUD.show(.progress)
        
        apiService?.messagesList(folder: "", messagesIDIn: "", seconds: 0, offset: self.offset) {(result) in
            
            switch(result) {
                
            case .success(let value):
                //print("value:", value)
                
                let emailMessages = value as! EmailMessagesList
                self.totalItems = emailMessages.totalCount!
                
                self.setData(messages: emailMessages)
               
                self.getCount = self.totalItems / k_pageLimit
                
                if self.offset == 0 {
                    self.customFoldersList() //need to get folders/labels color
                    self.currentCount = self.getCount
                }
                
                self.offset = self.offset + k_pageLimit
                
                //print("self.offset:", self.offset)
                
                self.getAllMessagesPageByPage()
                
            case .failure(let error):
                HUD.hide()
                print("error:", error)
                AlertHelperKit().showAlert(self.viewController!, title: "Messages Error", message: error.localizedDescription, button: "closeButton".localized())
            }
            
            if self.offset != 0 {
            //    HUD.hide()
            }
        }
    }
    
/*
    func allMessagesList() {
        
        HUD.show(.progress)
        
        apiService?.messagesList(folder: "", messagesIDIn: "", seconds: 0, offset: -1) {(result) in
            
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
    }*/
    
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
                AlertHelperKit().showAlert(self.viewController!, title: "Folders Error", message: error.localizedDescription, button: "closeButton".localized())
            }
            
            //HUD.hide()
        }
    }
    
    func setFilteredList(searchText: String) {
        
        let filteredSubjectsList = (self.viewController?.dataSource?.messagesArray.filter({( message : EmailMessage) -> Bool in
            return (message.subject?.lowercased().contains(searchText.lowercased()) ?? false)
        }))!
        
        let filteredSendersList = (self.viewController?.dataSource?.messagesArray.filter({( message : EmailMessage) -> Bool in
            return (message.sender?.lowercased().contains(searchText.lowercased()) ?? false)
        }))!
        
        var filteredDuplicatesMessagesList : Array<EmailMessage> = []
        
        for message in filteredSendersList {
            filteredDuplicatesMessagesList = filteredSendersList.filter { $0.messsageID != message.messsageID } //need to check for valid results
        }
        
        let filteredList = filteredSubjectsList + filteredDuplicatesMessagesList
            
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
