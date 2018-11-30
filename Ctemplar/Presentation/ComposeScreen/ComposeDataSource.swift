//
//  ComposeDataSource.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 27.11.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import UIKit

class ComposeDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {
    
    var isMailboxDataSource     : Bool = true
    
    var itemsArray              : Array<Any> = []
    var mailboxesArray          : Array<Mailbox> = []
    
    var tableView               : UITableView!
    var parentViewController    : ComposeViewController!
    var formatterService        : FormatterService?
    
    func initWith(parent: ComposeViewController, tableView: UITableView) {
        
        self.parentViewController = parent
        self.tableView = tableView
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        registerTableViewCell()        
    }
    
    //MARK: - table view
    
    func registerTableViewCell() {
        
        self.tableView.register(UINib(nibName: k_UserMailboxCellXibName, bundle: nil), forCellReuseIdentifier: k_UserMailboxTableViewCellIdentifier)
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if self.isMailboxDataSource {
            return mailboxesArray.count
        }
        
        return self.itemsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

       let cell : UserMailboxTableViewCell = tableView.dequeueReusableCell(withIdentifier: k_UserMailboxTableViewCellIdentifier)! as! UserMailboxTableViewCell
        
        //let cell : UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "mailboxcellidentifier")!
        
        //cell.textLabel?.font = UIFont(name: k_latoRegularFontName, size: 14.0)
        //cell.textLabel?.textColor = k_actionMessageColor
                
        
        if self.isMailboxDataSource {
            let mailbox = self.mailboxesArray[indexPath.row]
            
            if let email = mailbox.email {
                cell.emailLabel.text = email
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        print("select row:", indexPath.row)
        
        if self.isMailboxDataSource {
            
            let mailbox = self.mailboxesArray[indexPath.row]
            
            if let email = mailbox.email {
                self.parentViewController.presenter?.setupEmailFromSection(emailFromText: email)
            }
            
            self.parentViewController.mailboxID = mailbox.mailboxID!
        }
        
        self.tableView.isHidden = true
    }
    
    func reloadData(setMailboxData: Bool) {
        
        self.isMailboxDataSource = setMailboxData
        self.tableView.reloadData()
    }
}
