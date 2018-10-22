//
//  InboxSideMenuDataSource.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 22.10.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import UIKit

class InboxSideMenuDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {
    
    var menuOptionsArray        : Array<String> = []
    var tableView               : UITableView!
    var parentViewController    : InboxSideMenuViewController?
    var formatterService        : FormatterService?
    
    func initWith(parent: InboxSideMenuViewController, tableView: UITableView, array: Array<String>) {
        
        self.parentViewController = parent
        self.tableView = tableView
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.menuOptionsArray = array
        
        registerTableViewCell()
    }
    
    //MARK: - table view
    
    func registerTableViewCell() {
        
        //self.tableView.register(UINib(nibName: k_InboxMessageTableViewCellXibName, bundle: nil), forCellReuseIdentifier: k_InboxMessageTableViewCellIdentifier)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "sideMenuCellIdentifier")!
        
        let optionName = self.menuOptionsArray[indexPath.row]
        
        cell.textLabel?.text = optionName
        
        
        return cell
    }
}
