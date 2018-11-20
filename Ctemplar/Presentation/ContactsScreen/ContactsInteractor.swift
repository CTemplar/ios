//
//  ContactsInteractor.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 14.11.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import AlertHelperKit
import PKHUD

class ContactsInteractor {
    
    var viewController  : ContactsViewController?
    var presenter       : ContactsPresenter?
    var apiService      : APIService?

    func setFilteredList(searchText: String) {

        let contacts = (self.viewController?.dataSource?.contactsArray)!
        
        let filteredContactNamesList = (contacts.filter({( contact : Contact) -> Bool in
            return (contact.contactName?.lowercased().contains(searchText.lowercased()))!
        }))
        
        let filteredEmailsList = (contacts.filter({( contact : Contact) -> Bool in
            return (contact.email?.lowercased().contains(searchText.lowercased()))!
        }))
        
        var filteredDuplicatesEmailsList : Array<Contact> = []
        
        for contact in filteredContactNamesList {
            filteredDuplicatesEmailsList = filteredEmailsList.filter { $0.contactID != contact.contactID }
        }
        
        let filteredList = filteredContactNamesList + filteredDuplicatesEmailsList
        
        updateDataSource(searchText: searchText, filteredList: filteredList)
    }
    
    func updateDataSource(searchText: String, filteredList: Array<Contact>) {
        
        self.viewController?.dataSource?.filtered =  (self.viewController?.isFiltering())!
        self.viewController?.dataSource?.filteredContactsArray = filteredList
        self.viewController?.dataSource?.searchText = searchText
        self.viewController?.dataSource?.reloadData()
    }
    
    func setContactsData(contactsList: ContactsList) {
        
        if let contacts = contactsList.contactsList {
            self.viewController?.dataSource?.contactsArray = contacts
            self.viewController?.dataSource?.reloadData()
        }
    }
    
    func userContactsList() {
        
        HUD.show(.progress)
        
        apiService?.userContacts(contactsIDIn: "") {(result) in
            
            switch(result) {
                
            case .success(let value):
                //print("userContactsList:", value)
                
                let contactsList = value as! ContactsList
                self.setContactsData(contactsList: contactsList)
                
            case .failure(let error):
                print("error:", error)
                AlertHelperKit().showAlert(self.viewController!, title: "Contacts Error", message: error.localizedDescription, button: "closeButton".localized())
            }
            
            HUD.hide()
        }
    }
    /*
    func createContact() {
        
        HUD.show(.progress)
        
        apiService?.createContacts(name: "TestContact4", email: "test4@test.com", phone: "123456", address: "test address4", note: "test note4") {(result) in
            
            switch(result) {
                
            case .success(let value):
                print("createContact:", value)
                
                //let contact = value as! Contact
                //print("createContact:", contact)
                self.userContactsList()
                
            case .failure(let error):
                print("error:", error)
                AlertHelperKit().showAlert(self.viewController!, title: "Contacts Error", message: error.localizedDescription, button: "closeButton".localized())
            }
            
            HUD.hide()
        }
    }*/
    
    func deleteContactsList(selectedContactsArray: Array<Contact>, withUndo: String) {
        
        var contactsIDList : String = ""
        
        for contact in selectedContactsArray {
            contactsIDList = contactsIDList + contact.contactID!.description + ","
        }
        
        contactsIDList.remove(at: contactsIDList.index(before: contactsIDList.endIndex)) //remove last ","
        
        HUD.show(.progress)
        
        apiService?.deleteContacts(contactsIDIn: contactsIDList) {(result) in
            
            switch(result) {
                
            case .success( _):
              
                print("deleteContactsList")
                self.userContactsList()
                
            case .failure(let error):
                print("error:", error)
                AlertHelperKit().showAlert(self.viewController!, title: "Contacts Error", message: error.localizedDescription, button: "closeButton".localized())
            }
            
            HUD.hide()
        }
    }
}
