//
//  ContactsDataSource.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 14.11.2018.
//  Copyright © 2018 CTemplar. All rights reserved.
//

import Foundation
import UIKit

class ContactsDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {
    
    var contactsArray           : Array<Contact> = []
    var selectedContactsArray   : Array<Contact> = []
    var filteredContactsArray    : Array<Contact> = []
    var selectedFilteredContactsArray   : Array<Contact> = []
    
    var searchText              : String = ""
    
    var tableView               : UITableView!
    var parentViewController    : ContactsViewController!
    var formatterService        : FormatterService?
    
    var filtered : Bool = false
    var selectionMode : Bool = false
    
    var currentOffset = 0
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh(_:)), for: UIControl.Event.valueChanged)
        refreshControl.tintColor = UIColor.gray
        
        return refreshControl
    }()
    
    func initWith(parent: ContactsViewController, tableView: UITableView) {
        
        self.parentViewController = parent
        self.tableView = tableView
        self.tableView.delegate = self
        self.tableView.dataSource = self
//        self.contactsArray = array
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressed(sender:)))
        self.tableView.addGestureRecognizer(longPressRecognizer)
        
        self.tableView.addSubview(self.refreshControl)
        
        registerTableViewCell()
    }
    
    //MARK: - table view
    
    func registerTableViewCell() {
        
        self.tableView.register(UINib(nibName: k_ContactCellXibName, bundle: nil), forCellReuseIdentifier: k_ContactTableViewCellIdentifier)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if self.filtered {
            return filteredContactsArray.count
        }
        
        if parentViewController.contactsEncrypted {
            //return contactsArray.count + 1
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
        
        let isSelected = self.isContactSelected(contact: contact)
        
        (cell as ContactTableViewCell).setupCellWithData(contact: contact, isSelectionMode: self.selectionMode, isSelected: isSelected, foundText: self.searchText)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
                
        var currentContactsArray : Array<Contact> = []
        
        if self.filtered {
            currentContactsArray = filteredContactsArray
        } else {
            currentContactsArray = contactsArray
        }
        
        let contact = currentContactsArray[indexPath.row]
        
        if self.selectionMode == false {
            self.parentViewController?.router?.showAddContactViewController(editMode: true, contact: contact, contactsEncrypted: self.parentViewController.contactsEncrypted)
        } else {
            
            let selected = isContactSelected(contact: contact)
            
            if selected {
                if let index = selectedContactsArray.index(where: {$0.contactID == contact.contactID}) {
                    selectedContactsArray.remove(at: index)
                }      
                
            } else {
                print("selected")
                selectedContactsArray.append(contact)               
            }
            
            if selectedContactsArray.count == 0 {
                self.parentViewController.presenter?.disableSelectionMode()
            }
            
            var selectedAll : Bool = false
            if selectedContactsArray.count != currentContactsArray.count {
                selectedAll = true
            }
            
            self.parentViewController.presenter?.setSelectAllBarMode(selectAll: selectedAll)
            
            self.reloadData()
            
           // self.parentViewController.presenter?.setupNavigationItemTitle(selectedContacts: selectedContactsArray.count, selectionMode: selectionMode)
        }
    }
    
    func reloadData() {
        
        self.tableView.reloadData()
        self.refreshControl.endRefreshing()
        
        self.parentViewController.presenter?.setupNavigationItemTitle(selectedContacts: selectedContactsArray.count, selectionMode: selectionMode)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if (editingStyle == .delete) {
            
            let contact = contactsArray[indexPath.row]            
            self.parentViewController.presenter?.deleteContactPermanently(selectedContactsArray: [contact])
        }
    }
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        
        self.parentViewController.presenter?.interactor?.userContactsList()
    }
    
    // MARK: Scrolling
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        if parentViewController.contactsEncrypted {
            if let lastCell = tableView.visibleCells.last {
                let indexPath = tableView.indexPath(for: lastCell)
                if let index = indexPath?.row {
                    print("last visible cell index:", index)                    
                    let totalItems = parentViewController.presenter?.interactor!.totalItems
                    let offset = (parentViewController.presenter?.interactor!.offset)!
                    print("currentOffset:", currentOffset)
                    print("offset:", offset)
                    if currentOffset < offset {
                        if contactsArray.count < totalItems! {
                            if index + k_offsetForLast >= currentOffset {
                                print("need load with new offset:", offset)
                                currentOffset = (parentViewController.presenter?.interactor!.offset)!
                                parentViewController.presenter?.interactor!.userContactsList()
                            }
                        }
                    }
                }
            }
        }
    }
     
    // MARK: Actions
    
    @objc func longPressed(sender: UILongPressGestureRecognizer) {
        
        if sender.state == UIGestureRecognizer.State.began {
            
            let touchPoint = sender.location(in: self.tableView)
            if let indexPath = tableView.indexPathForRow(at: touchPoint) {
                
                //let contact = contactsArray[indexPath.row]
                var contact : Contact
                
                if self.filtered {
                    contact = filteredContactsArray[indexPath.row]
                } else {
                    contact = contactsArray[indexPath.row]
                }
                
                print("Long pressed row: \(indexPath.row)")
                if self.selectionMode == false {
                    self.selectedContactsArray.removeAll()
                    self.selectedContactsArray.append(contact)
                    self.parentViewController.presenter?.enableSelectionMode()
                }
            }
        }
    }
    
    // MARK: local methods
    
    func isContactSelected(contact: Contact) -> Bool {
        
        for contactItem in selectedContactsArray {
            if let contactItemID = contactItem.contactID {
                if contactItemID == contact.contactID {
                    return true
                }
            }
        }
        
        return false
    }
}
