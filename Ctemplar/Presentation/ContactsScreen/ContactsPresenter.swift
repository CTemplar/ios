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
        
        self.viewController?.searchController.searchResultsUpdater = self.viewController
        self.viewController?.searchController.obscuresBackgroundDuringPresentation = false
        self.viewController?.searchController.hidesNavigationBarDuringPresentation = false
        self.viewController?.searchController.searchBar.tintColor = k_contactsBarTintColor
        self.viewController?.searchController.searchBar.placeholder = "search".localized()
        self.viewController?.navigationItem.searchController = self.viewController?.searchController
        
        //UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).leftViewMode = .never
        UISearchBar.appearance().searchTextPositionAdjustment = UIOffset(horizontal: 10, vertical: 0)
       // UISearchBar.appearance().searchFieldBackgroundPositionAdjustment = UIOffset(horizontal: 0, vertical: 8)
        
        if let searchTextField = self.viewController?.searchController.searchBar.value(forKey: "_searchField") as? UITextField {
            searchTextField.borderStyle = .none
            //searchTextField.backgroundColor = self.viewController?.navigationItem.titleView?.backgroundColor
            //searchTextField.background = UIImage()
        }
    }
    
    func setupTable() {
        
        self.viewController?.contactsTableView.isHidden = true
        
        self.viewController?.selectedAllViewHeightConstraint.constant = 0.0
        self.viewController?.bottomBarHeightConstraint.constant = 0.0
        self.viewController?.view.layoutIfNeeded()
    }
    
    func getContactsList() {
        
        self.viewController?.contactsTableView.isHidden = false
        self.viewController?.dataSource?.contactsArray =  (self.viewController?.contactsList)!
        self.viewController?.dataSource?.reloadData()
        
        //self.interactor?.userContactsList()
    }
    
    func addContactButtonPressed(sender: AnyObject) {
        
        if self.viewController?.dataSource?.selectionMode == true {
            self.disableSelectionMode()
        } else {
            //temp
            //self.interactor?.createContact()
            self.viewController?.router?.showAddContactViewController(title: "Add Contact")
        }
    }
    
    func selectAllButtonPressed(sender: AnyObject) {
        
        let selectedContactsCount = self.viewController?.dataSource?.selectedContactsArray.count
        var overallContactsCount = self.viewController?.dataSource?.contactsArray.count
        
        if (self.viewController?.dataSource?.filtered)! {
            overallContactsCount = self.viewController?.dataSource?.filteredContactsArray.count
        } else {
            overallContactsCount = self.viewController?.dataSource?.contactsArray.count
        }
    
        if  selectedContactsCount == overallContactsCount {
            self.viewController?.dataSource?.selectedContactsArray.removeAll()
            
            self.viewController?.selectAllImageView.image = UIImage(named: k_checkBoxUncheckedImageName)
            self.viewController?.selectAllLabel.text = "selectAll".localized()
        } else {
            self.viewController?.dataSource?.selectedContactsArray.removeAll()
            self.viewController?.dataSource?.selectedContactsArray = (self.viewController?.dataSource?.contactsArray)!
            
            self.viewController?.selectAllImageView.image = UIImage(named: k_checkBoxSelectedImageName)
            self.viewController?.selectAllLabel.text = "deselectAll".localized()
        }
        
        self.viewController?.dataSource?.reloadData()
    }
    
    func enableSelectionMode() {
        
        self.viewController?.dataSource?.selectionMode = true
        self.viewController?.dataSource?.reloadData()
        
        self.viewController?.leftBarButtonItem.image = nil
        self.viewController?.leftBarButtonItem.isEnabled = false
        
        self.viewController?.rightBarButtonItem.image = nil
        self.viewController?.rightBarButtonItem.title = "cancelButton".localized()
        
        self.setupNavigationItemTitle(selectedContacts: (self.viewController?.dataSource?.selectedContactsArray.count)!, selectionMode: true)
        
        self.viewController?.selectedAllViewHeightConstraint.constant = k_contactsSelectAllBarHeight
        self.viewController?.bottomBarHeightConstraint.constant = k_contactsBottomBarHeight
        self.viewController?.view.layoutIfNeeded()
        
        self.viewController?.selectAllImageView.image = UIImage(named: k_checkBoxUncheckedImageName)
        self.viewController?.selectAllLabel.text = "selectAll".localized()
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
        
        self.viewController?.selectedAllViewHeightConstraint.constant = 0.0
        self.viewController?.bottomBarHeightConstraint.constant = 0.0
        self.viewController?.view.layoutIfNeeded()
    }
    
    func setupNavigationItemTitle(selectedContacts: Int, selectionMode: Bool) {
        
        if selectionMode == true {
            self.viewController?.navigationItem.title = String(format: "%d Selected", selectedContacts)
        } else {
            self.viewController?.navigationItem.title = "contacts".localized()
        }
    }
        
    func deleteContactPermanently(selectedContactsArray: Array<Contact>) {
        
        let params = Parameters(
            title: "deleteTitle".localized(),
            message: "deleteContact".localized(),
            cancelButton: "cancelButton".localized(),
            otherButtons: ["deleteButton".localized()]
        )
        
        AlertHelperKit().showAlertWithHandler(self.viewController!, parameters: params) { buttonIndex in
            switch buttonIndex {
            case 0:
                print("Cancel Delete")
            default:
                print("Delete")
                self.interactor?.deleteContactsList(selectedContactsArray:selectedContactsArray, withUndo: "")
            }
        }
    }
}
