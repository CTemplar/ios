//
//  ViewInboxEmailDataSource.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 16.11.2018.
//  Copyright © 2018 CTemplar. All rights reserved.
//

import Foundation
import UIKit
import Networking
import Utility

class ViewInboxEmailDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {
    
    var messagesArray                     : Array<EmailMessage> = []
    var dercyptedMessagesArray            : Array<String> = []
    var dercyptedHeadersArray             : Array<String> = []
    var showDetailMessagesArray           : Array<Bool> = []
    var showContentMessagesArray          : Array<Bool> = []
    
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
        
        self.tableView.register(UINib(nibName: k_ChildMessageCellXibName, bundle: nil), forCellReuseIdentifier: k_ChildMessageTableViewCellIdentifier)
        
        self.tableView.register(UINib(nibName: k_ChildMessageExpandedCellXibName, bundle: nil), forCellReuseIdentifier: k_ChildMessageExpandedTableViewCellIdentifier)
        
        self.tableView.register(UINib(nibName: k_ChildMessageExpandedWithAttachmentCellXibName, bundle: nil), forCellReuseIdentifier: k_ChildMessageExpandedWithAttachmentTableViewCellIdentifier)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.messagesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //let cell : ChildMessageTableViewCell = tableView.dequeueReusableCell(withIdentifier: k_ChildMessageTableViewCellIdentifier)! as! ChildMessageTableViewCell
        
        var cell : UITableViewCell
        
        let message = messagesArray[indexPath.row]
        var sender = ""
        if let dispalyName = message.sender_display {
            sender = dispalyName
        }else if let senderEmail = message.sender {
            sender = senderEmail
        }
        
        var header = ""
        var messageText = ""
        
        //if let messageContent = self.parentViewController?.presenter?.interactor?.extractMessageContent(message: message) {
        if dercyptedMessagesArray.count > indexPath.row {
            let messageContent = dercyptedMessagesArray[indexPath.row]
        
//            header = (self.parentViewController?.presenter?.interactor?.headerOfMessage(content: messageContent))!
            messageText = messageContent
        }
        
        let showDetails = self.showDetailMessagesArray[indexPath.row]
        let showContent = self.showContentMessagesArray[indexPath.row]
        
        if showContent {
            var hasAttachments : Bool = false
            
            if let attachments = message.attachments {
                if attachments.count > 0 {
                    hasAttachments = true
                }
            }
            
            if hasAttachments {
                cell = tableView.dequeueReusableCell(withIdentifier: k_ChildMessageExpandedWithAttachmentTableViewCellIdentifier)! as! ChildMessageExpandedWithAttachmentTableViewCell
                (cell as! ChildMessageExpandedWithAttachmentTableViewCell).parentController = self
                (cell as! ChildMessageExpandedWithAttachmentTableViewCell).setupCellWithData(message: message, contentMessage: messageText, showDetails: showDetails, index: indexPath.row, delegate: self)
            } else {
                cell = tableView.dequeueReusableCell(withIdentifier: k_ChildMessageExpandedTableViewCellIdentifier)! as! ChildMessageExpandedTableViewCell
                (cell as! ChildMessageExpandedTableViewCell).parentController = self
                (cell as! ChildMessageExpandedTableViewCell).setupCellWithData(message: message, contentMessage: messageText, showDetails: showDetails, index: indexPath.row, delegate: self)
            }

        } else {
            if dercyptedMessagesArray.count > indexPath.row {
                let messageContent = dercyptedMessagesArray[indexPath.row]
            
                header = (self.parentViewController?.presenter?.interactor?.headerOfMessage(content: messageContent))!
            }
            
            var lastMessage = false
            
            if indexPath.row == messagesArray.count - 1 {
                lastMessage = true
            }
            
            cell = tableView.dequeueReusableCell(withIdentifier: k_ChildMessageTableViewCellIdentifier)! as! ChildMessageTableViewCell
            (cell as! ChildMessageTableViewCell).parentController = self
            (cell as! ChildMessageTableViewCell).setupCellWithData(sender: sender, header: header, message: message, isLast: lastMessage)
        }
         
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsets.zero
        cell.layoutMargins = UIEdgeInsets.zero
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if self.messagesArray.count > 1 { //expand/close only for chain of messages
        
            let showContent = self.showContentMessagesArray[indexPath.row]
            self.showContentMessagesArray[indexPath.row] = !showContent
        
            self.reloadData(scrollToLastMessage: false)
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func reloadData(scrollToLastMessage : Bool) {
        
        self.tableView.reloadData()
        
        if scrollToLastMessage {
            
            if self.messagesArray.count > 3 {
                let lastIndex : IndexPath = IndexPath(row: self.messagesArray.count - 1, section: 0)
                self.tableView.scrollToRow(at: lastIndex as IndexPath, at: UITableView.ScrollPosition.top, animated: true)
            }
        }
    }
    
    func attachSelected(itemUrlString: String, encrypted: Bool) {
        
        self.parentViewController.presenter?.showShareScreen(itemUrlString: itemUrlString, encrypted: encrypted)
    }
}

extension ViewInboxEmailDataSource: ChildMessageExxpandedTableViewCellDelegate {
    func reloadCell(at index: Int) {
        tableView.beginUpdates()
        tableView.endUpdates()
    }
}
