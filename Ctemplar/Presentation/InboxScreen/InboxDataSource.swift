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
    
    var messagesArray           : Array<Any> = []
    var tableView               : UITableView!
    var parentViewController    : InboxViewController!
    
    func initWith(parent: InboxViewController, tableView: UITableView, array: Array<Any>) {
        
        self.parentViewController = parent
        self.tableView = tableView
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.messagesArray = array
        
        registerTableViewCell()
    }
    
    //MARK: - table view
    
    func registerTableViewCell() {
        
        //self.tableView.register(UINib(nibName: k_leaderBoardCellXibName, bundle: nil), forCellReuseIdentifier: k_leaderBoardCellIdentifier)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellIdentifier")!
        
        return cell
    }
}
