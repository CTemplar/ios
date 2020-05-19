//
//  ManageFoldersDataSource.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 17.12.2018.
//  Copyright © 2018 CTemplar. All rights reserved.
//

import Foundation
import UIKit

class ManageFoldersDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {
    
    var foldersArray            : Array<Folder> = []
 
    var tableView               : UITableView!
    var parentViewController    : ManageFoldersViewController!
    var formatterService        : FormatterService?
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh(_:)), for: UIControl.Event.valueChanged)
        refreshControl.tintColor = UIColor.gray
        
        return refreshControl
    }()
    
    func initWith(parent: ManageFoldersViewController, tableView: UITableView) {
        
        self.parentViewController = parent
        self.tableView = tableView
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.tableFooterView = UIView()
        self.tableView.addSubview(self.refreshControl)
           
        registerTableViewCell()
    }
    
    //MARK: - table view
    
    func registerTableViewCell() {
        
        self.tableView.register(UINib(nibName: k_MoveToFolderCellXibName, bundle: nil), forCellReuseIdentifier: k_MoveToFolderTableViewCellIdentifier)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return foldersArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let folder = foldersArray[indexPath.row]
        let color = folder.color
        let folderName = folder.folderName
        
        let cell = tableView.dequeueReusableCell(withIdentifier: k_MoveToFolderTableViewCellIdentifier)! as! MoveToFolderTableViewCell
        (cell as MoveToFolderTableViewCell).setupMoveToFolderTableCell(checked: false, iconColor: color!, title: folderName!, showCheckBox: false)
        
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let folder = foldersArray[indexPath.row]
        
        self.parentViewController?.router?.showEditFolderViewController(folder: folder)
    }
    
    func reloadData() {
        
        self.refreshControl.endRefreshing()
        self.tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        let folder = foldersArray[indexPath.row]
        
        if (editingStyle == .delete) {
            if let folderID = folder.folderID {
                self.parentViewController?.presenter?.showDeleteFolderAlert(folderID: folderID)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        
        return "deleteRow".localized()
    }
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        
        self.parentViewController.presenter?.interactor?.foldersList(silent: true)
        
    }
}
