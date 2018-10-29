//
//  InboxSideMenuDataSource.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 22.10.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import UIKit
import SideMenu

class InboxSideMenuDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {
    
    var mainFoldersArray        : Array<String> = []
    var customFoldersArray      : Array<String> = []
    var labelsArray             : Array<String> = []
    var optionsArray            : Array<String> = []
    
    var tableView               : UITableView!
    var parentViewController    : InboxSideMenuViewController?
    var formatterService        : FormatterService?
    
    func initWith(parent: InboxSideMenuViewController, tableView: UITableView, mainFoldersArray: Array<String>, customFoldersArray: Array<String>, labelsArray: Array<String>, optionsArray: Array<String>) {
        
        self.parentViewController = parent
        self.tableView = tableView
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.mainFoldersArray = mainFoldersArray
        self.customFoldersArray = customFoldersArray
        self.labelsArray = labelsArray
        self.optionsArray = optionsArray
        
        registerTableViewCell()
    }
    
    //MARK: - table view
    
    func registerTableViewCell() {
        
        //self.tableView.register(UINib(nibName: k_InboxMessageTableViewCellXibName, bundle: nil), forCellReuseIdentifier: k_InboxMessageTableViewCellIdentifier)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return SideMenuSectionIndex.sectionCount.rawValue
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        case SideMenuSectionIndex.mainFolders.rawValue:
            return mainFoldersArray.count
        case SideMenuSectionIndex.customFolders.rawValue:
            return 0
        case SideMenuSectionIndex.labels.rawValue:
            return 0
        case SideMenuSectionIndex.options.rawValue:
            return self.optionsArray.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell : UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "sideMenuCellIdentifier")!
        
        cell.selectionStyle = .gray
        
        switch indexPath.section {
        case SideMenuSectionIndex.mainFolders.rawValue:
            
            cell = tableView.dequeueReusableCell(withIdentifier: "sideMenuCellIdentifier")!
            
            let folderName = self.mainFoldersArray[indexPath.row]
            cell.textLabel?.text = folderName
            
            break
        case SideMenuSectionIndex.customFolders.rawValue:
            break
        case SideMenuSectionIndex.labels.rawValue:
            break
        case SideMenuSectionIndex.options.rawValue:
            let optionName = self.optionsArray[indexPath.row]
            cell.textLabel?.text = optionName
            
            break
        default:
            print("unknown section")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.section {
            case SideMenuSectionIndex.mainFolders.rawValue:
                let optionName = self.mainFoldersArray[indexPath.row]
                self.parentViewController?.presenter?.interactor?.selectAction(optionName: optionName)
            break
        case SideMenuSectionIndex.customFolders.rawValue:
            break
        case SideMenuSectionIndex.labels.rawValue:
            break
        case SideMenuSectionIndex.options.rawValue:
            let optionName = self.optionsArray[indexPath.row]
            self.parentViewController?.presenter?.interactor?.selectAction(optionName: optionName)
            break
        default:
            print("selected unknown section")
        }
    }
    
    func reloadData() {
        
        self.tableView.reloadData()
    }
}
