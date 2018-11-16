//
//  ContactsPresenter.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 14.11.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import AlertHelperKit
import PKHUD

class ContactsPresenter {
    
    var viewController   : ContactsViewController?
    var interactor       : ContactsInteractor?

    func setupSearchController() {
        
        self.viewController?.definesPresentationContext = true
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self.viewController
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.tintColor = k_actionMessageColor
        searchController.searchBar.placeholder = "search".localized()
        self.viewController?.navigationItem.searchController = searchController
        
        //UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).leftViewMode = .never
        UISearchBar.appearance().searchTextPositionAdjustment = UIOffset(horizontal: 10, vertical: 0)
       // UISearchBar.appearance().searchFieldBackgroundPositionAdjustment = UIOffset(horizontal: 0, vertical: 8)
        
        if let searchTextField = searchController.searchBar.value(forKey: "_searchField") as? UITextField {
            searchTextField.borderStyle = .none
            //searchTextField.backgroundColor = self.viewController?.navigationItem.titleView?.backgroundColor
            //searchTextField.background = UIImage()
        }
    }
    
    func addContactButtonPressed(sender: AnyObject) {
        
        if self.viewController?.dataSource?.selectionMode == true {
            self.disableSelectionMode()
        } else {
            
        }
    }
    
    func enableSelectionMode() {
        
        self.viewController?.dataSource?.selectionMode = true
        self.viewController?.dataSource?.reloadData()
        
        self.viewController?.leftBarButtonItem.image = nil
        self.viewController?.leftBarButtonItem.isEnabled = false
        
        self.viewController?.rightBarButtonItem.image = nil
        self.viewController?.rightBarButtonItem.title = "cancelButton".localized()
        
        self.setupNavigationItemTitle(selectedContacts: (self.viewController?.dataSource?.selectedContactsArray.count)!, selectionMode: true)
    }
    
    func disableSelectionMode() {
        
        self.viewController?.dataSource?.selectionMode = false
        self.viewController?.dataSource?.selectedContactsArray.removeAll()
        self.viewController?.dataSource?.reloadData()
        
        self.viewController?.leftBarButtonItem.image = UIImage(named: k_menuImageName)
        self.viewController?.leftBarButtonItem.isEnabled = true
        
        self.viewController?.rightBarButtonItem.image = UIImage(named: k_darkPlusIconImageName)
        self.viewController?.rightBarButtonItem.title = nil
        
        self.setupNavigationItemTitle(selectedContacts: 0, selectionMode: false)
    }
    
    func setupNavigationItemTitle(selectedContacts: Int, selectionMode: Bool) {
        
        if selectionMode == true {
            self.viewController?.navigationItem.title = String(format: "%d Selected", selectedContacts)
        } else {
            self.viewController?.navigationItem.title = "contacts".localized()
        }
    }
}
