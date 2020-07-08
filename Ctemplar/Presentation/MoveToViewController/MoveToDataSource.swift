//
//  MoveToDataSource.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 06.11.2018.
//  Copyright © 2018 CTemplar. All rights reserved.
//

import Foundation
import UIKit
import Networking

class MoveToDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: Properties
    private var tableView: UITableView
    private weak var parentViewController: MoveToViewController?
    var customFoldersArray: [Folder] = []
    var selectedFolderIndex: Int?
    
    // MARK: - Constructor
    init(parent: MoveToViewController, tableView: UITableView) {
        self.parentViewController = parent
        self.tableView = tableView
        
        super.init()
        
        setupTableView()
    }

    // MARK: - Setuo
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.register(UINib(nibName: k_MoveToFolderCellXibName, bundle: nil), forCellReuseIdentifier: k_MoveToFolderTableViewCellIdentifier)

        tableView.reloadData()
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
        
        reloadData()
    }
    
    func reloadData() {
        tableView.reloadData()
    }
    
    func setApplyButtonEnabled() {
        parentViewController?.presenter?.applyButton(enabled: selectedFolderIndex == nil ? false : true)
    }
}
