//
//  WhiteBlackListsViewController.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 27.12.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import UIKit

enum WhiteBlackListsMode: Int {
    
    case whiteList   = 0
    case blackList   = 1
}

class WhiteBlackListsViewController: UIViewController, UISearchBarDelegate {
    
    @IBOutlet var tableView             : UITableView!
    
    @IBOutlet var segmentedControl      : UISegmentedControl!
    @IBOutlet var underlineView         : UIView!
    
    @IBOutlet var addContactButton      : UIButton!
    @IBOutlet var addContactBottomButton      : UIButton!
    @IBOutlet var textLabel             : UILabel!
    
    @IBOutlet var searchBar             : UISearchBar!
    @IBOutlet var addButtonView         : UIView!
    
    @IBOutlet var underlineWidthConstraint              : NSLayoutConstraint!
    @IBOutlet var underlineLeftOffsetConstraint         : NSLayoutConstraint!
    
    var user = UserMyself()
    
    var listMode = WhiteBlackListsMode.whiteList
    
    var searchActive : Bool = false
    
    var presenter   : WhiteBlackListsPresenter?
    var router      : WhiteBlackListsRouter?
    var dataSource  : WhiteBlackListsDataSource?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let configurator =  WhiteBlackListsConfigurator()
        configurator.configure(viewController: self)
        
        self.dataSource?.initWith(parent: self, tableView: tableView)
        
        self.presenter?.setupSegmentedControl()
        self.segmentedControl.sendActions(for: UIControl.Event.valueChanged)
        self.presenter?.setupSearchBar(searchBar: self.searchBar)
        //self.presenter?.setupTableAndDataSource(user: self.user, listMode: self.listMode)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        self.navigationController!.navigationBar.hideBorderLine()
        self.presenter?.setupUnderlineView(listMode: self.listMode)
        self.presenter?.interactor?.getWhiteListContacts()
    }
    
    //MARK: - IBActions
    
    @IBAction func backButtonPressed(_ sender: AnyObject) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func addContactButtonPressed(_ sender: AnyObject) {
        
        self.presenter?.addContactButtonPressed(listMode: self.listMode)
    }
    
    @IBAction func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        
        self.presenter?.segmentedControlValueChanged(sender)
    }
    
    // MARK: SearchBar delegate
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
        searchActive = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        
        searchActive = false
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        searchActive = false;
        searchBar.endEditing(true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        searchActive = false
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

extension WhiteBlackListsViewController: AddContactToWhiteBlackListDelegate {
    
    func addAction(name: String, email: String) {
        
        switch listMode {
        case WhiteBlackListsMode.whiteList:
            self.presenter?.interactor?.addContactToWhiteList(name: name, email: email)
            break
        case WhiteBlackListsMode.blackList:
            self.presenter?.interactor?.addContactToBlackList(name: name, email: email)
            break
        }
    }
}
