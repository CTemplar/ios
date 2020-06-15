//
//  ContactsPresenter.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 14.11.2018.
//  Copyright © 2018 CTemplar. All rights reserved.
//

import Foundation
import Utility
import UIKit
import Networking

class ContactsPresenter {
    
    var viewController   : ContactsViewController?
    var interactor       : ContactsInteractor?

    func setupSearchController() {
        if #available(iOS 13.0, *) {
            let buttonAppearence = UIBarButtonItemAppearance()
            buttonAppearence.configureWithDefault(for: .plain)
            buttonAppearence.normal.titleTextAttributes = [.foregroundColor: k_navButtonTintColor]
            
            let navBarAppearence = UINavigationBarAppearance()
            navBarAppearence.configureWithDefaultBackground()
            navBarAppearence.backgroundColor = k_navBar_backgroundColor
            navBarAppearence.titleTextAttributes = [.foregroundColor: k_navBar_titleColor]
            
            navBarAppearence.buttonAppearance = buttonAppearence
            
            self.viewController?.navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearence
            self.viewController?.navigationController?.navigationBar.compactAppearance = navBarAppearence
            self.viewController?.navigationController?.navigationBar.standardAppearance = navBarAppearence
        }else {
            self.viewController?.navigationController?.navigationBar.tintColor = k_navBar_backgroundColor
            self.viewController?.searchController.searchBar.barTintColor = k_navBar_backgroundColor
        }
        self.viewController?.navigationController?.navigationBar.isTranslucent = true
        self.viewController?.definesPresentationContext = true
        
        self.viewController?.searchController.searchResultsUpdater = self.viewController
        self.viewController?.searchController.obscuresBackgroundDuringPresentation = false
        self.viewController?.searchController.hidesNavigationBarDuringPresentation = false
        self.viewController?.searchController.searchBar.tintColor = k_searchBar_backgroundColor
        self.viewController?.searchController.searchBar.placeholder = "search".localized()
        //self.viewController?.navigationItem.searchController = self.viewController?.searchController
        self.viewController?.searchController.searchBar.delegate = self.viewController
        self.viewController?.searchController.searchBar.returnKeyType = .done
        
        if !viewController!.contactsEncrypted {
            self.viewController?.navigationItem.searchController = self.viewController?.searchController
        }
        
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).leftViewMode = .always
        
        UISearchBar.appearance().searchTextPositionAdjustment = UIOffset(horizontal: 14, vertical: 0) //10
       // UISearchBar.appearance().searchFieldBackgroundPositionAdjustment = UIOffset(horizontal: 0, vertical: 8)
        
        //self.viewController?.searchController.searchBar.setImage(UIImage(named: "SearchIcon"), for: .search, state: .normal)
        
        self.viewController?.searchController.searchBar.setPositionAdjustment(UIOffset(horizontal: 0, vertical: 0), for: UISearchBar.Icon.search)
  
        let imageView = UIImageView(image: UIImage(named: "SearchIcon")!)//?.withRenderingMode(.alwaysTemplate))
        imageView.frame = CGRect(x: 0, y: 0, width: 22, height: 22)
        if #available(iOS 13.0, *) {
            if let searchTextField = self.viewController?.searchController.searchBar.searchTextField {
                searchTextField.borderStyle = .roundedRect
                searchTextField.leftView = imageView
                
            }
        }else {
            if let searchTextField = self.viewController?.searchController.searchBar.value(forKey: "_searchField") as? UITextField {
                searchTextField.borderStyle = .roundedRect
                searchTextField.leftView = imageView
            }
        }
    }
    
    func setupTable() {
        
        self.viewController?.contactsTableView.isHidden = true
        
        self.viewController?.selectedAllViewHeightConstraint.constant = 0.0
        self.viewController?.bottomBarHeightConstraint.constant = 0.0
        self.viewController?.view.layoutIfNeeded()
    }
    
    func setupAddContactsButtonLabel() {
        
        let labelText = self.viewController?.addContactsLabel.text?.localized()
        
        let textWidth = labelText?.widthOfString(usingFont: (self.viewController?.addContactsLabel.font)!)
        
        let viewWidth = k_plusImageWidth + k_addButtonLeftOffet + textWidth! + 3.0 //sometimes width calculation is small
        
        self.viewController?.addContactsViewWithConstraint.constant = viewWidth
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
            let contact = Contact.init()
            self.viewController?.router?.showAddContactViewController(editMode: false, contact: contact, contactsEncrypted: self.viewController!.contactsEncrypted)
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
            
            //self.viewController?.selectAllImageView.image = UIImage(named: k_checkBoxUncheckedImageName)
            //self.viewController?.selectAllLabel.text = "selectAll".localized()
            self.setSelectAllBarMode(selectAll: true)
        } else {
            self.viewController?.dataSource?.selectedContactsArray.removeAll()
            self.viewController?.dataSource?.selectedContactsArray = (self.viewController?.dataSource?.contactsArray)!
            
            //self.viewController?.selectAllImageView.image = UIImage(named: k_checkBoxSelectedImageName)
            //self.viewController?.selectAllLabel.text = "deselectAll".localized()
            self.setSelectAllBarMode(selectAll: false)
        }
        
        self.viewController?.dataSource?.reloadData()
    }
    
    func setSelectAllBarMode(selectAll: Bool) {
        
        if selectAll {
            self.viewController?.selectAllImageView.image = UIImage(named: k_checkBoxUncheckedImageName)
            self.viewController?.selectAllLabel.text = "selectAll".localized()
        } else {
            self.viewController?.selectAllImageView.image = UIImage(named: k_checkBoxSelectedImageName)
            self.viewController?.selectAllLabel.text = "deselectAll".localized()
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
        
        //self.viewController?.selectedAllViewHeightConstraint.constant = k_contactsSelectAllBarHeight
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
        
        self.viewController?.rightBarButtonItem.image = UIImage(named: k_plusButtonIconImageName)
        self.viewController?.rightBarButtonItem.title = nil
        
        self.setupNavigationItemTitle(selectedContacts: 0, selectionMode: false)
        
        self.viewController?.selectedAllViewHeightConstraint.constant = 0.0
        self.viewController?.bottomBarHeightConstraint.constant = 0.0
        self.viewController?.view.layoutIfNeeded()
    }
    
    func setSelectAllBar(show : Bool) {
        
        if show {
            //self.viewController?.selectedAllViewHeightConstraint.constant = k_contactsSelectAllBarHeight
        } else {
            self.viewController?.selectedAllViewHeightConstraint.constant = 0.0
        }
        
        self.viewController?.view.layoutIfNeeded()
    }
    
    func setupNavigationItemTitle(selectedContacts: Int, selectionMode: Bool) {
        
        if selectionMode == true {
            self.viewController?.navigationItem.title = String(format: "%d " + "selected".localized(), selectedContacts)
        } else {
            self.viewController?.navigationItem.title = "contacts".localized()
        }
    }
    
    func setupNavigationLeftItem() {
        
        let emptyButton = UIBarButtonItem(image: UIImage(), style: .done, target: self, action: nil)
        
        if UIDevice.current.orientation.isLandscape {
            print("Landscape")
            self.viewController?.navigationItem.leftBarButtonItem = emptyButton
        } else {
            print("Portrait")
            self.viewController?.navigationItem.leftBarButtonItem = self.viewController?.leftBarButtonItem
        }
    }
        
    func deleteContactPermanently(selectedContactsArray: Array<Contact>) {
        let params = AlertKitParams(
            title: "deleteTitle".localized(),
            message: "deleteContact".localized(),
            cancelButton: "cancelButton".localized(),
            otherButtons: ["deleteButton".localized()]
        )
        
        viewController?.showAlert(with: params, onCompletion: { [weak self] (index) in
            switch index {
            case 0:
                DPrint("Cancel Delete")
            default:
                DPrint("Delete")
                self?.interactor?.deleteContactsList(selectedContactsArray: selectedContactsArray, withUndo: "")
            }
        })
    }
}
