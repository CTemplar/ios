//
//  WhiteBlackListsInteractor.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 27.12.2018.
//  Copyright © 2018 CTemplar. All rights reserved.
//

import Foundation
import Utility
import Networking

class WhiteBlackListsInteractor {
    
    var viewController  : WhiteBlackListsViewController?
    var presenter       : WhiteBlackListsPresenter?
    var apiService      : APIService?
    
    func getWhiteListContacts(silent: Bool) {
        if !silent {
            Loader.start()
        }
        apiService?.whiteListContacts() { [weak self] (result) in
            guard let safeSelf = self else { return }
            switch(result) {
            case .success(let value):
                print("whiteListContacts value:", value)
                let contactsList = value as! ContactsList
                if let contacts = contactsList.contactsList {
                    safeSelf.presenter?.whiteListContacts = contacts
                    safeSelf.presenter?.setupTableAndDataSource(listMode: safeSelf.viewController!.listMode)
                }
            case .failure(let error):
                print("error:", error)
                safeSelf.viewController?.showAlert(with: "Get White List Contacts Error", message: error.localizedDescription, buttonTitle: Strings.Button.closeButton.localized)
            }
            Loader.stop()
        }
    }
    
    func getBlackListContacts(silent: Bool) {
        
        if !silent {
            Loader.start()
        }
        
        apiService?.blackListContacts() { [weak self] (result) in
            guard let safeSelf = self else { return }
            switch(result) {
            case .success(let value):
                print("blackListContacts value:", value)
                let contactsList = value as! ContactsList
                if let contacts = contactsList.contactsList {
                    safeSelf.presenter?.blackListContacts = contacts
                    safeSelf.presenter?.setupTableAndDataSource(listMode: safeSelf.viewController!.listMode)
                }
            case .failure(let error):
                print("error:", error)
                safeSelf.viewController?.showAlert(with: "Get Black List Contacts Error", message: error.localizedDescription, buttonTitle: Strings.Button.closeButton.localized)
            }
            Loader.stop()
        }
    }
    
    func setFilteredList(searchText: String) {
        
        let contacts = (self.viewController?.dataSource?.contactsArray)!
        
        let filteredContactNamesList = (contacts.filter({( contact : Contact) -> Bool in
            return (contact.contactName?.lowercased().contains(searchText.lowercased()) ?? false)
        }))
        
        let filteredEmailsList = (contacts.filter({( contact : Contact) -> Bool in
            return (contact.email?.lowercased().contains(searchText.lowercased()) ?? false)
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
        Loader.start()
        apiService?.addContactToBlackList(name: name, email: email) { [weak self] (result) in
            guard let safeSelf = self else { return }

            switch(result) {
            case .success(let value):
                print("value:", value)
                safeSelf.getBlackListContacts(silent: false)
            case .failure(let error):
                print("error:", error)
                safeSelf.viewController?.showAlert(with: "Add contact to BlackList Error", message: error.localizedDescription, buttonTitle: Strings.Button.closeButton.localized)
            }
            Loader.stop()
        }
    }
    
    func addContactToWhiteList(name: String, email: String) {
        
        Loader.start()
        
        apiService?.addContactToWhiteList(name: name, email: email) { [weak self] (result) in
            guard let safeSelf = self else { return }

            switch(result) {
            case .success(let value):
                print("value:", value)
                safeSelf.getWhiteListContacts(silent: false)
            case .failure(let error):
                print("error:", error)
                safeSelf.viewController?.showAlert(with: "Add contact to BlackList Error", message: error.localizedDescription, buttonTitle: Strings.Button.closeButton.localized)
            }
            Loader.stop()
        }
    }
    
    
    func deleteContactsFromWhiteList(contactID: String) {
        Loader.start()
        apiService?.deleteContactFromWhiteList(contactID: contactID) { [weak self] (result) in
            guard let safeSelf = self else { return }
            switch(result) {
            case .success( _):
                print("deleteContactsFromWhiteList")
                safeSelf.getWhiteListContacts(silent: false)
            case .failure(let error):
                print("error:", error)
                safeSelf.viewController?.showAlert(with: "Delete Contact Error", message: error.localizedDescription, buttonTitle: Strings.Button.closeButton.localized)
            }
            Loader.stop()
        }
    }
    
    func deleteContactsFromBlacklList(contactID: String) {
        Loader.start()
        apiService?.deleteContactFromBlackList(contactID: contactID) { [weak self] (result) in
            guard let safeSelf = self else { return }
            switch(result) {
            case .success( _):
                print("deleteContactsFromBlacklList")
                safeSelf.getBlackListContacts(silent: false)
            case .failure(let error):
                print("error:", error)
                safeSelf.viewController?.showAlert(with: "Delete Contact Error", message: error.localizedDescription, buttonTitle: Strings.Button.closeButton.localized)
            }
            Loader.stop()
        }
    }
}
