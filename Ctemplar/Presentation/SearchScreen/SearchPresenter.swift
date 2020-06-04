//
//  SearchPresenter.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 09.11.2018.
//  Copyright © 2018 CTemplar. All rights reserved.
//

import Foundation
import AlertHelperKit

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
        if #available(iOS 13.0, *) {
            let searchTextField = searchBar.searchTextField
            searchTextField.borderStyle = .none
            searchTextField.backgroundColor = self.viewController?.navigationItem.titleView?.backgroundColor
            searchTextField.leftView = nil
        }else {
            if let searchTextField = searchBar.value(forKey: "_searchField") as? UITextField {
                searchTextField.borderStyle = .none
                searchTextField.backgroundColor = self.viewController?.navigationItem.titleView?.backgroundColor
                searchTextField.leftView = nil
            }
        }
        
        
        
        self.viewController?.navigationItem.titleView = searchBar   
    }
    
    func updateMessges() {
        
        self.interactor!.offset = 0
        self.interactor!.getCount = 0
        self.interactor!.currentCount = 0
        self.viewController?.dataSource?.messagesArray.removeAll()
        self.interactor?.getAllMessagesPageByPage()
    }
}
