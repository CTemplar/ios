//
//  ContactsDataSource.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 14.11.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import UIKit

class ContactsDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {
    
    var contactsArray           : Array<Contact> = []
    
    var searchText              : String = ""
    
    var tableView               : UITableView!
    var parentViewController    : ContactsViewController!
    var formatterService        : FormatterService?
    
    var filtered : Bool = false
    
    func initWith(parent: ContactsViewController, tableView: UITableView) {
        
        self.parentViewController = parent
        self.tableView = tableView
        self.tableView.delegate = self
        self.tableView.dataSource = self
//        self.contactsArray = array
        
        registerTableViewCell()
    }
    
    //MARK: - table view
    
    func registerTableViewCell() {
        
        self.tableView.register(UINib(nibName: k_ContactCellXibName, bundle: nil), forCellReuseIdentifier: k_ContactTableViewCellIdentifier)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
       return contactsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell : ContactTableViewCell = tableView.dequeueReusableCell(withIdentifier: k_ContactTableViewCellIdentifier)! as! ContactTableViewCell
        
        let contact = contactsArray[indexPath.row]
        
        (cell as ContactTableViewCell).setupCellWithData(contact: contact, isSelectionMode: false, isSelected: false)
        
        return cell
    }
    
    func reloadData() {
        
        self.tableView.reloadData()
    }
}
