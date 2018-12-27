//
//  WhiteBlackListsDataSource.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 27.12.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import UIKit

class  WhiteBlackListsDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {
    
    var tableView               : UITableView!
    var parentViewController    : WhiteBlackListsViewController!
    var formatterService        : FormatterService?
    
    var contactsArray           : Array<Contact> = []
    var filteredContactsArray   : Array<Contact> = []
    
    var searchText              : String = ""
    var filtered : Bool = false
    
    func initWith(parent: WhiteBlackListsViewController, tableView: UITableView) {
        
        self.parentViewController = parent
        self.tableView = tableView
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.tableFooterView = UIView()
        
        registerTableViewCell()
    }
    
    //MARK: - table view
    
    func registerTableViewCell() {
        
        self.tableView.register(UINib(nibName: k_ContactCellXibName, bundle: nil), forCellReuseIdentifier: k_ContactTableViewCellIdentifier)
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if self.filtered {
            return filteredContactsArray.count
        }
        
        return contactsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell : ContactTableViewCell = tableView.dequeueReusableCell(withIdentifier: k_ContactTableViewCellIdentifier)! as! ContactTableViewCell
        
        var contact : Contact
        
        if self.filtered {
            contact = filteredContactsArray[indexPath.row]
        } else {
            contact = contactsArray[indexPath.row]
        }
        
        (cell as ContactTableViewCell).setupCellWithData(contact: contact, isSelectionMode: false, isSelected: false, foundText: self.searchText)
        
        return cell
    }
    
    func reloadData() {
        
        self.tableView.reloadData()        
    }
}
