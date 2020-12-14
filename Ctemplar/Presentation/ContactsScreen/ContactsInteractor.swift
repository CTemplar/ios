//
//  ContactsInteractor.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 14.11.2018.
//  Copyright © 2018 CTemplar. All rights reserved.
//

import Foundation
import Utility
import Networking

class ContactsInteractor {
    
    var viewController  : ContactsViewController?
    var presenter       : ContactsPresenter?
    var apiService      : APIService?
    
    var totalItems = 0
    var offset = 0

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
        
        if searchText.count > 0 {
            let show = !filteredList.isEmpty
            presenter?.setSelectAllBar(show: show)
        } else {
            presenter?.setSelectAllBar(show: true)
        }
    }
    
    func updateDataSource(searchText: String, filteredList: Array<Contact>) {
        
        self.viewController?.dataSource?.filtered =  (self.viewController?.isFiltering())!
        self.viewController?.dataSource?.filteredContactsArray = filteredList
        self.viewController?.dataSource?.searchText = searchText
        self.viewController?.dataSource?.reloadData()
    }
    
    func clearContactsList() {
        
        self.viewController?.dataSource?.contactsArray.removeAll()
    }
    
    func setContactsData(contactsList: ContactsList, withOffset: Bool) {
        
        if let contacts = contactsList.contactsList {
            if withOffset {
                self.viewController?.dataSource?.contactsArray.append(contentsOf: contacts)
            } else {
                self.viewController?.dataSource?.contactsArray = contacts
            }
            self.viewController?.dataSource?.reloadData()
        }
    }
    
    func userContactsList() {        
        if self.offset >= self.totalItems && self.offset > 0 {
            return
        }
        
        let fetchAll = !self.viewController!.contactsEncrypted
        
        apiService?.userContacts(fetchAll: fetchAll, offset: offset, silent: false) { [weak self] (result) in
            switch(result) {
            case .success(let value):
                let contactsList = value as! ContactsList
                
                if let totalCount = contactsList.totalCount {
                    self?.totalItems = totalCount
                }
                self?.offset = (self?.offset ?? 0) + k_contactPageLimit
                self?.setContactsData(contactsList: contactsList, withOffset: !fetchAll)
            case .failure(let error):
                self?.viewController?.showAlert(with: Strings.AppError.error.localized,
                           message: error.localizedDescription,
                           buttonTitle: Strings.Button.closeButton.localized)
            }
        }
    }
       
    func deleteContactsList(selectedContactsArray: [Contact], withUndo: String) {
        var contactsIDList = ""
        
        for contact in selectedContactsArray {
            if let contactId = contact.contactID?.description {
                contactsIDList = contactsIDList + contactId + ","
            }
        }
        
        contactsIDList.remove(at: contactsIDList.index(before: contactsIDList.endIndex))
        
        Loader.start()
        
        apiService?.deleteContacts(contactsIDIn: contactsIDList) { [weak self] (result) in
            switch(result) {
            case .success( _):
                self?.offset = 0
                self?.userContactsList()
            case .failure(let error):
                self?.viewController?.showAlert(with: Strings.AppError.error.localized,
                           message: error.localizedDescription,
                           buttonTitle: Strings.Button.closeButton.localized)
            }
            
            Loader.stop()
        }
    }
}
