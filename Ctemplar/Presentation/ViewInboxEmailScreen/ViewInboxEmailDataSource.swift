//
//  ViewInboxEmailDataSource.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 16.11.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import UIKit

class ViewInboxEmailDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {
    
    var messagesArray           : Array<EmailMessage> = []
    
    var tableView               : UITableView!
    var parentViewController    : ViewInboxEmailViewController!
    var formatterService        : FormatterService?
    
    
    func initWith(parent: ViewInboxEmailViewController, tableView: UITableView) {
        
        self.parentViewController = parent
        self.tableView = tableView
        self.tableView.delegate = self
        self.tableView.dataSource = self
        //self.messagesArray = array
        
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
        
        return self.messagesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell : SearchTableViewCell = tableView.dequeueReusableCell(withIdentifier: k_SearchTableViewCellIdentifier)! as! SearchTableViewCell
        
        //cell.parentController = self
        

        //let message = messagesArray[indexPath.row]
//        cell.setupCellWithData(message: message, foundText: searchText)
       

        
        return cell
    }
    
    func reloadData() {
        
        self.tableView.reloadData()
    }
}
