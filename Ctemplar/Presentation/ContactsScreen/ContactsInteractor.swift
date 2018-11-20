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
    
    func deleteContactsList(selectedContactsArray: Array<Contact>, withUndo: String) {
        
        var contactsIDList : String = ""
        
        for contact in selectedContactsArray {
            contactsIDList = contactsIDList + contact.contactID!.description + ","
        }
        
        contactsIDList.remove(at: contactsIDList.index(before: contactsIDList.endIndex)) //remove last ","
        
        apiService?.deleteContacts(contactsIDIn: contactsIDList) {(result) in
            
            switch(result) {
                
            case .success( _):
              
                print("deleteContactsList")

                
            case .failure(let error):
                print("error:", error)
                AlertHelperKit().showAlert(self.viewController!, title: "Messages Error", message: error.localizedDescription, button: "closeButton".localized())
            }
        }
    }
}
