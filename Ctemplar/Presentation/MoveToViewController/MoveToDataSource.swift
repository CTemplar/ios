//
//  MoveToDataSource.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 06.11.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import UIKit

class MoveToDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {
    
    var tableView               : UITableView!
    var parentViewController    : MoveToViewController?
    
    var customFoldersArray      : Array<Folder> = []
    
    func initWith(parent: MoveToViewController, tableView: UITableView) {
        
        self.parentViewController = parent
        self.tableView = tableView
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        registerTableViewCell()
    }
    
    func registerTableViewCell() {
                
        self.tableView.register(UINib(nibName: k_CustomFolderCellXibName, bundle: nil), forCellReuseIdentifier: k_CustomFolderTableViewCellIdentifier)
    }
    
    //MARK: - table view
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return customFoldersArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //var cell : UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "moveToCellIdentifier")!
        
        let cell = tableView.dequeueReusableCell(withIdentifier: k_CustomFolderTableViewCellIdentifier)! as! CustomFolderTableViewCell
        
        return cell
    }
    
    func reloadData() {
        
        if customFoldersArray.count > 0 {
            self.tableView.isHidden = false
        } else {
            self.tableView.isHidden = true
        }
        
        self.tableView.reloadData()
    }
}
