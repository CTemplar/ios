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
        
        if let searchTextField = searchController.searchBar.value(forKey: "_searchField") as? UITextField {
            //searchTextField.borderStyle = .none
            searchTextField.backgroundColor = self.viewController?.navigationItem.titleView?.backgroundColor
        }
    }
}
