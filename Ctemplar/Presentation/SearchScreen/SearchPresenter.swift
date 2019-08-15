//
//  SearchPresenter.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 09.11.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import AlertHelperKit
import PKHUD

class SearchPresenter {
    
    var viewController   : SearchViewController?
    var interactor       : SearchInteractor?
    
    func setupNavigationBarItem(searchBar: UISearchBar) {
        
        self.viewController?.navigationItem.rightBarButtonItem?.title = "cancelButton".localized()
        
        UISearchBar.appearance().searchTextPositionAdjustment = UIOffset(horizontal: 0, vertical: 0)
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).leftViewMode = .always
        
        searchBar.placeholder = "search".localized()
        searchBar.sizeToFit()
        
        //UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).leftViewMode = .never
        
        if let searchTextField = searchBar.value(forKey: "_searchField") as? UITextField {
            searchTextField.borderStyle = .none
            searchTextField.backgroundColor = self.viewController?.navigationItem.titleView?.backgroundColor
            searchTextField.leftView = nil
        }
        
        self.viewController?.navigationItem.titleView = searchBar   
    }

}
