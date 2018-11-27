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
    
    var messagesArray                     : Array<EmailMessage> = []

    
    var tableView               : UITableView!
    var parentViewController    : ComposeViewController!
    var formatterService        : FormatterService?
    
    func initWith(parent: ComposeViewController, tableView: UITableView) {
        
        self.parentViewController = parent
        self.tableView = tableView
        self.tableView.delegate = self
        self.tableView.dataSource = self
        //self.messagesArray = array
        
        registerTableViewCell()
        
    }
    
    //MARK: - table view
    
    func registerTableViewCell() {
        
        //self.tableView.register(UINib(nibName: k_ChildMessageCellXibName, bundle: nil), forCellReuseIdentifier: k_ChildMessageTableViewCellIdentifier)
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.messagesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

       let cell : ChildMessageTableViewCell = tableView.dequeueReusableCell(withIdentifier: k_ChildMessageTableViewCellIdentifier)! as! ChildMessageTableViewCell
        
        return cell
    }
}
