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
    
    var contactsArray           : Array<Contact> = []
    var mailboxesArray          : Array<Mailbox> = []
    
    var searchText              : String = ""
    
    var currentTextView         : UITextView!
    
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
        self.tableView.register(UINib(nibName: k_ContactCellXibName, bundle: nil), forCellReuseIdentifier: k_ContactTableViewCellIdentifier)        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if self.isMailboxDataSource {
            return mailboxesArray.count
        }
        
        return self.contactsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell : UITableViewCell!// = tableView.dequeueReusableCell(withIdentifier: "mailboxcellidentifier")!
        
        if self.isMailboxDataSource {
            
            cell = tableView.dequeueReusableCell(withIdentifier: k_UserMailboxTableViewCellIdentifier)! as! UserMailboxTableViewCell
            
            let mailbox = self.mailboxesArray[indexPath.row]
            
            if let email = mailbox.email {
                (cell as! UserMailboxTableViewCell).emailLabel.text = email
            }
        } else {
            
            cell = tableView.dequeueReusableCell(withIdentifier: k_ContactTableViewCellIdentifier)! as! ContactTableViewCell
            
            let contact = contactsArray[indexPath.row]
            
            (cell as! ContactTableViewCell).setupCellWithData(contact: contact, isSelectionMode: false, isSelected: false, foundText: self.searchText)
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
        } else {
            
            let contact = contactsArray[indexPath.row]
            
            if  let email = contact.email {
                if (self.currentTextView != nil) {
                    self.parentViewController.interactor?.setEmail(textView: self.currentTextView, inputEmail: email, addSelected: true)
                }
            }
        }
        
        self.tableView.isHidden = true
    }
    
    func reloadData(setMailboxData: Bool) {
        
        self.isMailboxDataSource = setMailboxData
        self.tableView.reloadData()
    }
}
