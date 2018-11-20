//
//  ContactsViewController.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 14.11.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import UIKit
import SideMenu

class ContactsViewController: UIViewController, UISearchResultsUpdating {
    
    var presenter   : ContactsPresenter?
    var router      : ContactsRouter?
    var dataSource  : ContactsDataSource?
    
    var sideMenuViewController : InboxSideMenuViewController?
    
    var contactsList : Array<Contact> = []
    var filterdContactsList : Array<Contact> = []
    
    @IBOutlet var contactsTableView        : UITableView!
    
    @IBOutlet var leftBarButtonItem     : UIBarButtonItem!
    @IBOutlet var rightBarButtonItem    : UIBarButtonItem!
    
    @IBOutlet var selectAllBar          : UIView!
    @IBOutlet var bottomToolBar         : UIView!
    @IBOutlet var undoBar               : UIView!
    
    @IBOutlet var selectAllImageView    : UIImageView!
    @IBOutlet var selectAllLabel        : UILabel!
    
    @IBOutlet var selectedAllViewHeightConstraint    : NSLayoutConstraint!
    @IBOutlet var bottomBarHeightConstraint          : NSLayoutConstraint!
    
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let configurator = ContactsConfigurator()
        configurator.configure(viewController: self)
     
        self.presenter?.setupSearchController()
        
        dataSource?.initWith(parent: self, tableView: contactsTableView)
        
        contactsTableView.isHidden = true
        
        self.selectedAllViewHeightConstraint.constant = 0.0
        self.bottomBarHeightConstraint.constant = 0.0
        self.view.layoutIfNeeded()
        
        //temp
        contactsTableView.isHidden = false
        dataSource?.contactsArray = contactsList
        dataSource?.reloadData()
    }
        
    //MARK: - IBActions
    
    @IBAction func menuButtonPressed(_ sender: AnyObject) {
        
        self.router?.showInboxSideMenu()
        //self.dismiss(animated: true, completion: nil)
        //self.navigationController?.popViewController(animated: true) //temp
    }
    
    @IBAction func addContactButtonPressed(_ sender: AnyObject) {
        
        presenter?.addContactButtonPressed(sender: self)
    }
    
    @IBAction func selectAllButtonPressed(_ sender: AnyObject) {
        
        presenter?.selectAllButtonPressed(sender: self)
    }
    
    @IBAction func trashButtonPressed(_ sender: AnyObject) {
     
        presenter?.deleteContactPermanently(selectedContactsArray: (self.dataSource?.selectedContactsArray)!)
    }
    
    //MARK: - Search delegate
    
    func updateSearchResults(for searchController: UISearchController) {
        
        guard let text = searchController.searchBar.text else { return }
        print("searched text:", text)
        
        self.presenter?.interactor?.setFilteredList(searchText: text)
    }
    
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    
    func isFiltering() -> Bool {
        
        return searchController.isActive && !searchBarIsEmpty()
    }
}
