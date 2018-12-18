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
    var selectedFolderIndex     : Int?
    
    func initWith(parent: MoveToViewController, tableView: UITableView) {
        
        self.parentViewController = parent
        self.tableView = tableView
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        registerTableViewCell()
    }
    
    func registerTableViewCell() {
                
        self.tableView.register(UINib(nibName: k_MoveToFolderCellXibName, bundle: nil), forCellReuseIdentifier: k_MoveToFolderTableViewCellIdentifier)
    }
    
    //MARK: - table view
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return customFoldersArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
              
        let folder = customFoldersArray[indexPath.row]
        let color = folder.color
        let folderName = folder.folderName
        
        var selected = false
        
        if indexPath.row == self.selectedFolderIndex {
            selected = true
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: k_MoveToFolderTableViewCellIdentifier)! as! MoveToFolderTableViewCell
        (cell as MoveToFolderTableViewCell).setupMoveToFolderTableCell(checked: selected, iconColor: color!, title: folderName!, showCheckBox: true)
        
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if self.selectedFolderIndex == indexPath.row {
            self.selectedFolderIndex = nil
        } else {
            self.selectedFolderIndex = indexPath.row
        }
        
        setApplyButtonEnabled()
        
        self.tableView.reloadData()
    }
    
    func reloadData() {
        
        if customFoldersArray.count > 0 {
            self.tableView.isHidden = false
        } else {
            self.tableView.isHidden = true
        }
        
        self.tableView.reloadData()
    }
    
    func setApplyButtonEnabled() {
        
        if self.selectedFolderIndex == nil {
            self.parentViewController?.presenter?.applyButton(enabled: false)
        } else {
            self.parentViewController?.presenter?.applyButton(enabled: true)
        }
    }
}
