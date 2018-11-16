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
        
        //var contacts : Array<Contact> = []
        /*
        if (self.viewController?.isFiltering())! {
            contacts = (self.viewController?.dataSource?.filterdContactsArray)!
        } else {
            contacts = (self.viewController?.dataSource?.contactsArray)!
        }*/
        
        let contacts = (self.viewController?.dataSource?.contactsArray)!
        
        let filteredContactNamesList = (contacts.filter({( contact : Contact) -> Bool in
            return (contact.contactName?.lowercased().contains(searchText.lowercased()))!
        }))
        
        let filteredEmailsList = (contacts.filter({( contact : Contact) -> Bool in
            return (contact.email?.lowercased().contains(searchText.lowercased()))!
        }))
        
        let filteredList = filteredContactNamesList + filteredEmailsList
        
        updateDataSource(searchText: searchText, filteredList: filteredList)
    }
    
    func updateDataSource(searchText: String, filteredList: Array<Contact>) {
        
        self.viewController?.dataSource?.filtered =  (self.viewController?.isFiltering())!
        self.viewController?.dataSource?.filteredContactsArray = filteredList
        //self.viewController?.dataSource?.searchText = searchText
        self.viewController?.dataSource?.reloadData()
    }
}
