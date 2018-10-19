//
//  InboxDataSource.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 11.10.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import UIKit

class InboxDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {
    
    var messagesArray           : Array<EmailMessage> = []
    var tableView               : UITableView!
    var parentViewController    : InboxViewController!
    
    func initWith(parent: InboxViewController, tableView: UITableView, array: Array<EmailMessage>) {
        
        self.parentViewController = parent
        self.tableView = tableView
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.messagesArray = array
        
        registerTableViewCell()
    }
    
    //MARK: - table view
    
    func registerTableViewCell() {
        
       self.tableView.register(UINib(nibName: k_InboxMessageTableViewCellXibName, bundle: nil), forCellReuseIdentifier: k_InboxMessageTableViewCellIdentifier)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.messagesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        /*
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellIdentifier")!
        
        let message = self.messagesArray[indexPath.row]
        
        cell.textLabel?.text = message.sender
        cell.detailTextLabel?.text = message.subject*/
        
        let cell : InboxMessageTableViewCell = tableView.dequeueReusableCell(withIdentifier: k_InboxMessageTableViewCellIdentifier)! as! InboxMessageTableViewCell
        
        cell.setupCellWithData(message: messagesArray[indexPath.row], isSelectionMode: false, isSelected: false)
        
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        self.parentViewController.router?.showViewInboxEmailViewController()
    }
    
    func reloadData() {

        self.tableView.reloadData()
    }
}
