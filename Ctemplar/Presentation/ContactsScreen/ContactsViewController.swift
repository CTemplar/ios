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

    @IBOutlet var contactsTableView        : UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        self.presenter?.setupSearchController()
        
        let configurator = ContactsConfigurator()
        configurator.configure(viewController: self)
        
        dataSource?.initWith(parent: self, tableView: contactsTableView)
        
        contactsTableView.isHidden = true
    }
        
    //MARK: - IBActions
    
    @IBAction func menuButtonPressed(_ sender: AnyObject) {
        
        //self.showInboxSideMenu()
        //self.dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true) //temp
    }
    
    @IBAction func addContactButtonPressed(_ sender: AnyObject) {
        
       
    }
    
    //MARK: - Search delegate
    
    func updateSearchResults(for searchController: UISearchController) {
        
        guard let text = searchController.searchBar.text else { return }
        print("searched text:", text)
    }
}
