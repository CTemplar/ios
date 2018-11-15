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
        
        //self.tableView.register(UINib(nibName: k_SearchCellXibName, bundle: nil), forCellReuseIdentifier: k_SearchTableViewCellIdentifier)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
       return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell : SearchTableViewCell = tableView.dequeueReusableCell(withIdentifier: k_SearchTableViewCellIdentifier)! as! SearchTableViewCell
        
    
        
        return cell
    }
    
    func reloadData() {
        
        self.tableView.reloadData()
    }
}
