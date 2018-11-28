//
//  SearchViewController.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 09.11.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import UIKit
import Foundation
import PKHUD
import AlertHelperKit

class SearchViewController: UIViewController, UISearchBarDelegate {
    
    var presenter   : SearchPresenter?
    var router      : SearchRouter?
    var dataSource  : SearchDataSource?
    
    var messagesList    : Array<EmailMessage> = []
    var filteredArray   : Array<EmailMessage> = []
    
    var senderEmail: String = ""
    
    lazy var searchBar = UISearchBar(frame: CGRect.zero)
    
    var searchActive : Bool = false
    
    @IBOutlet var searchTableView        : UITableView!    
    @IBOutlet var emptySearch            : UIView!
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let configurator = SearchConfigurator()
        configurator.configure(viewController: self)
        
        presenter?.setupNavigationBarItem(searchBar: searchBar)
        
        dataSource?.initWith(parent: self, tableView: searchTableView, array: messagesList)
        
        searchBar.delegate = self        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //self.presenter?.interactor?.allMessagesList()
        //self.dataSource?.messagesArray = self.messagesList
        self.dataSource?.reloadData()
    }
    
    // MARK: IBActions
    
    @IBAction func cancelButtonPressed(_ sender: AnyObject) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func searchButtonPressed(_ sender: AnyObject) {
        
    }
    
    // MARK: SearchBar delegate
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
        searchActive = true;
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        
        searchActive = false;
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        searchActive = false;
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        searchActive = false;
    }
    
    func searchBarIsEmpty() -> Bool {
        
        return searchBar.text?.isEmpty ?? true
    }
    
    func isFiltering() -> Bool {
        
        return searchActive && !searchBarIsEmpty()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        self.presenter?.interactor?.setFilteredList(searchText: searchText)
    }
}
