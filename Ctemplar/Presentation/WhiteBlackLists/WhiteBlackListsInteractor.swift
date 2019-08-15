//
//  WhiteBlackListsInteractor.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 27.12.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import AlertHelperKit
import PKHUD

class WhiteBlackListsInteractor {
    
    var viewController  : WhiteBlackListsViewController?
    var presenter       : WhiteBlackListsPresenter?
    var apiService      : APIService?
    
    func getWhiteListContacts() {
        
        HUD.show(.progress)
        
        apiService?.whiteListContacts() {(result) in
            
            switch(result) {
                
            case .success(let value):
                print("whiteListContacts value:", value)
                
                let contactsList = value as! ContactsList
                if let contacts = contactsList.contactsList {
                    self.presenter?.whiteListContacts = contacts
                    self.presenter?.setupTableAndDataSource(listMode: self.viewController!.listMode)
                }
                
                break              
                
            case .failure(let error):
                print("error:", error)
                AlertHelperKit().showAlert(self.viewController!, title: "Get White List Contacts Error", message: error.localizedDescription, button: "closeButton".localized())
            }
            
            HUD.hide()
        }
    }
    
    func getBlackListContacts() {
        
        HUD.show(.progress)
        
        apiService?.blackListContacts() {(result) in
            
            switch(result) {
                
            case .success(let value):
                print("blackListContacts value:", value)
                
                let contactsList = value as! ContactsList
                if let contacts = contactsList.contactsList {
                    self.presenter?.blackListContacts = contacts                    
                    self.presenter?.setupTableAndDataSource(listMode: self.viewController!.listMode)
                }
               
                break
                
            case .failure(let error):
                print("error:", error)
                AlertHelperKit().showAlert(self.viewController!, title: "Get Black List Contacts Error", message: error.localizedDescription, button: "closeButton".localized())
            }
            
            HUD.hide()
        }
    }
    
    func setFilteredList(searchText: String) {
        
        let contacts = (self.viewController?.dataSource?.contactsArray)!
        
        let filteredContactNamesList = (contacts.filter({( contact : Contact) -> Bool in
            return (contact.contactName?.lowercased().contains(searchText.lowercased()))!
        }))
        
        let filteredEmailsList = (contacts.filter({( contact : Contact) -> Bool in
            return (contact.email?.lowercased().contains(searchText.lowercased()))!
        }))
        
        let filteredList = filteredContactNamesList + filteredEmailsList
        
        updateDataSource(searchText: searchText, filteredList: filteredList.removingDuplicates())
    }
    
    func updateDataSource(searchText: String, filteredList: Array<Contact>) {
        
        self.viewController?.dataSource?.filtered =  (self.viewController?.isFiltering())!
        self.viewController?.dataSource?.filteredContactsArray = filteredList
        self.viewController?.dataSource?.searchText = searchText
        self.viewController?.dataSource?.reloadData()
    }
    
    func addContactToBlackList(name: String, email: String) {
        
        HUD.show(.progress)
        
        apiService?.addContactToBlackList(name: name, email: email) {(result) in
            
            switch(result) {
                
            case .success(let value):
                print("value:", value)
                self.getBlackListContacts()
                
            case .failure(let error):
                print("error:", error)
                AlertHelperKit().showAlert(self.viewController!, title: "Add contact to BlackList Error", message: error.localizedDescription, button: "closeButton".localized())
            }
            
             HUD.hide()
        }
    }
    
    func addContactToWhiteList(name: String, email: String) {
        
        HUD.show(.progress)
        
        apiService?.addContactToWhiteList(name: name, email: email) {(result) in
            
            switch(result) {
                
            case .success(let value):
                print("value:", value)
                self.getWhiteListContacts()
                
            case .failure(let error):
                print("error:", error)
                AlertHelperKit().showAlert(self.viewController!, title: "Add contact to BlackList Error", message: error.localizedDescription, button: "closeButton".localized())
            }
            
            HUD.hide()
        }
    }
    
    
    func deleteContactsFromWhiteList(contactID: String) {
        
        HUD.show(.progress)
        
        apiService?.deleteContactFromWhiteList(contactID: contactID) {(result) in
            
            switch(result) {
                
            case .success( _):
                
                print("deleteContactsFromWhiteList")
                self.getWhiteListContacts()
                
            case .failure(let error):
                print("error:", error)
                AlertHelperKit().showAlert(self.viewController!, title: "Delete Contact Error", message: error.localizedDescription, button: "closeButton".localized())
            }
            
            HUD.hide()
        }
    }
    
    func deleteContactsFromBlacklList(contactID: String) {
        
        HUD.show(.progress)
        
        apiService?.deleteContactFromBlackList(contactID: contactID) {(result) in
            
            switch(result) {
                
            case .success( _):
                
                print("deleteContactsFromBlacklList")
                self.getBlackListContacts()
                
            case .failure(let error):
                print("error:", error)
                AlertHelperKit().showAlert(self.viewController!, title: "Delete Contact Error", message: error.localizedDescription, button: "closeButton".localized())
            }
            
            HUD.hide()
        }
    }
}
