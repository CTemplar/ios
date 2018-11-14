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

    @IBOutlet var contactsTableView        : UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        self.setupSearchController()
        
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
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        print(text)
    }
    
    func setupSearchController() {
        
        self.definesPresentationContext = true
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.tintColor = k_actionMessageColor
        searchController.searchBar.placeholder = "search".localized()
        navigationItem.searchController = searchController        
        
        if let searchTextField = searchController.searchBar.value(forKey: "_searchField") as? UITextField {
            //searchTextField.borderStyle = .none
            searchTextField.backgroundColor = self.navigationItem.titleView?.backgroundColor
        }
    }
    
    func showInboxSideMenu() {
        
        //self.viewController?.inboxSideMenuViewController?.currentParentViewController = self.viewController
        let inboxSideMenuViewController = SideMenuManager.default.menuLeftNavigationController?.children.first as! InboxSideMenuViewController
        inboxSideMenuViewController.currentParentViewController = self
        self.present(SideMenuManager.default.menuLeftNavigationController!, animated: true, completion: nil)
    }
}
