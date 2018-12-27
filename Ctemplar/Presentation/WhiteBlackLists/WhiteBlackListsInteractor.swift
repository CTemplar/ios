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
        
        apiService?.addContactToBlackList(name: name, email: email) {(result) in
            
            switch(result) {
                
            case .success(let value):
                print("value:", value)
       
                
            case .failure(let error):
                print("error:", error)
                AlertHelperKit().showAlert(self.viewController!, title: "Add contact to BlackList Error", message: error.localizedDescription, button: "closeButton".localized())
            }
        }
    }
    
    func addContactToWhiteList(name: String, email: String) {
        
        apiService?.addContactToWhiteList(name: name, email: email) {(result) in
            
            switch(result) {
                
            case .success(let value):
                print("value:", value)
                
                
            case .failure(let error):
                print("error:", error)
                AlertHelperKit().showAlert(self.viewController!, title: "Add contact to BlackList Error", message: error.localizedDescription, button: "closeButton".localized())
            }
        }
    }
}
