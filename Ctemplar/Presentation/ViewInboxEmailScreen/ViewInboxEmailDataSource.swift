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
        
        self.tableView.register(UINib(nibName: k_ChildMessageCellXibName, bundle: nil), forCellReuseIdentifier: k_ChildMessageTableViewCellIdentifier)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.messagesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell : ChildMessageTableViewCell = tableView.dequeueReusableCell(withIdentifier: k_ChildMessageTableViewCellIdentifier)! as! ChildMessageTableViewCell
        
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsets.zero
        cell.layoutMargins = UIEdgeInsets.zero
        
        let message = messagesArray[indexPath.row]
        let sender = message.sender
        
        var header = ""
        
        if let messageContent = self.parentViewController?.presenter?.interactor?.extractMessageContent(message: message) {
            header = (self.parentViewController?.presenter?.interactor?.headerOfMessage(content: messageContent))!
        }
        
        //let header = message.content
        cell.setupCellWithData(sender: sender!, header: header)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func reloadData() {
        
        self.tableView.reloadData()
    }
}
