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
    
    var mainFoldersArray                : Array<String> = []
    var mainFoldersImageNameList        : Array<String> = []
   
    var unreadMessagesArray             : Array<UnreadMessagesCounter> = []
    
    var customFoldersArray              : Array<Folder> = []
    var labelsArray                     : Array<String> = []
    var optionsArray                    : Array<String> = []
    var optionsImageNameList            : Array<String> = []
    
    var tableView               : UITableView!
    var parentViewController    : InboxSideMenuViewController?
    var formatterService        : FormatterService?
    
    var showAllFolders : Bool = false
    
    var selectedIndexPath : IndexPath = IndexPath(row: 0, section: SideMenuSectionIndex.mainFolders.rawValue)
    
    func initWith(parent: InboxSideMenuViewController, tableView: UITableView) {
        
        self.parentViewController = parent
        self.tableView = tableView
        self.tableView.delegate = self
        self.tableView.dataSource = self

        registerTableViewCell()
    }
 
    func setupData(mainFoldersArray: Array<String>, mainFoldersImageNameList: Array<String>, customFoldersArray: Array<String>, labelsArray: Array<String>, optionsArray: Array<String>, optionsImageNameList: Array<String>) {
        
        self.mainFoldersArray = mainFoldersArray
        self.mainFoldersImageNameList = mainFoldersImageNameList
        //self.customFoldersArray = customFoldersArray
        self.labelsArray = labelsArray
        self.optionsArray = optionsArray
        self.optionsImageNameList = optionsImageNameList
    }
    
    //MARK: - table view
    
    func registerTableViewCell() {
        
        self.tableView.register(UINib(nibName: k_SideMenuTableViewCellXibName, bundle: nil), forCellReuseIdentifier: k_SideMenuTableViewCellIdentifier)
        
        //self.tableView.register(UINib(nibName: k_SideMenuTableSectionHeaderViewXibName, bundle: nil), forHeaderFooterViewReuseIdentifier: k_SideMenuTableSectionHeaderViewIdentifier)
        
        self.tableView.register(UINib(nibName: k_SideMenuTableManageFolderXibName, bundle: nil), forCellReuseIdentifier: k_SideMenuTableManageFolderCellIdentifier)
        
        self.tableView.register(UINib(nibName: k_CustomFolderCellXibName, bundle: nil), forCellReuseIdentifier: k_CustomFolderTableViewCellIdentifier)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return SideMenuSectionIndex.sectionsCount.rawValue
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        switch section {
        case SideMenuSectionIndex.mainFolders.rawValue:
            return 0//k_sideMenuSeparatorHeight
        case SideMenuSectionIndex.options.rawValue:
            return k_sideMenuSeparatorHeight
        case SideMenuSectionIndex.manageFolders.rawValue:
            return k_sideMenuSeparatorHeight
        case SideMenuSectionIndex.customFolders.rawValue:
            return k_sideMenuSeparatorHeight//k_sideMenuSectionHeaderHeight
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        // Dequeue with the reuse identifier
        //let header = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: k_SideMenuTableSectionHeaderViewIdentifier)
        //let headerView = header as! SideMenuTableSectionHeaderView
        
        let separatorLineHeaderView: UIView =  UIView()
        separatorLineHeaderView.backgroundColor = k_sideMenuSeparatorColor
        //header?.contentView.backgroundColor = k_whiteColor
        
        return separatorLineHeaderView
        
        /*
        switch section {
        case SideMenuSectionIndex.mainFolders.rawValue:
            headerView.setupHeader(iconName: "", title: "", foldersCount: 0, hideBottomLine: false)
            break
        case SideMenuSectionIndex.options.rawValue:
            //headerView.setupHeader(iconName: "", title: "", hideBottomLine: false)
            //break
            return separatorLineHeaderView
        case SideMenuSectionIndex.manageFolders.rawValue:
            //break
            return separatorLineHeaderView
        case SideMenuSectionIndex.customFolders.rawValue:
            /*
            headerView.setupHeader(iconName: k_darkFoldersIconImageName, title: "manageFolders".localized(), foldersCount: self.customFoldersArray.count, hideBottomLine: false)
            let headerTapGesture = UITapGestureRecognizer()
            headerTapGesture.addTarget(self, action: #selector(self.tappedHeaderAction(sender:)))
            headerView.addGestureRecognizer(headerTapGesture)
            break*/
            
            return separatorLineHeaderView
        default:
            print("unknown header section")
        }*/
        
       // return headerView
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        case SideMenuSectionIndex.mainFolders.rawValue:
            return mainFoldersArray.count
        case SideMenuSectionIndex.options.rawValue:
            return self.optionsArray.count
        case SideMenuSectionIndex.manageFolders.rawValue:
            return 1
        case SideMenuSectionIndex.customFolders.rawValue:
            if self.showAllFolders {
                return self.customFoldersArray.count + 1
            } else {
                if self.customFoldersArray.count > k_numberOfCustomFoldersShowing {
                    return k_numberOfCustomFoldersShowing + 1
                } else {
                    return self.customFoldersArray.count
                }
            }
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell : UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "sideMenuCellIdentifier")!
        cell.contentView.backgroundColor = k_whiteColor
        
        //cell.selectionStyle = .gray
        
        switch indexPath.section {
        case SideMenuSectionIndex.mainFolders.rawValue:
            
            cell = tableView.dequeueReusableCell(withIdentifier: k_SideMenuTableViewCellIdentifier)! as! SideMenuTableViewCell
            
            let folderName = self.mainFoldersArray[indexPath.row]
            //let selected = self.isSelected(folderName: folderName)
            let selected = isSelected(section: indexPath.section, row: indexPath.row)
            let iconName = self.mainFoldersImageNameList[indexPath.row]

            let unreadCount = self.parentViewController?.presenter?.interactor?.getUnreadMessagesCount(folderName: folderName)
            
            (cell as! SideMenuTableViewCell).setupSideMenuTableCell(selected: selected, iconName: iconName, title: folderName.localized(), unreadCount: unreadCount!)
            
            break
        case SideMenuSectionIndex.options.rawValue:
            
            cell = tableView.dequeueReusableCell(withIdentifier: k_SideMenuTableViewCellIdentifier)! as! SideMenuTableViewCell
            
            let optionName = self.optionsArray[indexPath.row]
            let iconName = self.optionsImageNameList[indexPath.row]
            let selected = isSelected(section: indexPath.section, row: indexPath.row)
            
            (cell as! SideMenuTableViewCell).setupSideMenuTableCell(selected: selected, iconName: iconName, title: optionName.localized(), unreadCount: 0)
            
            break
        case SideMenuSectionIndex.manageFolders.rawValue:
            
            cell = tableView.dequeueReusableCell(withIdentifier: k_SideMenuTableManageFolderCellIdentifier)! as! SideMenuTableManageFolderCell
           
            let selected = isSelected(section: indexPath.section, row: indexPath.row)
            
            (cell as! SideMenuTableManageFolderCell).setupCell(selected: selected, iconName: k_darkFoldersIconImageName, title: "manageFolders".localized(), foldersCount: self.customFoldersArray.count)
            break
        case SideMenuSectionIndex.customFolders.rawValue:
            
            if self.showAllFolders {
                
                if self.customFoldersArray.count > indexPath.row {
                    
                    cell = tableView.dequeueReusableCell(withIdentifier: k_CustomFolderTableViewCellIdentifier)! as! CustomFolderTableViewCell
                    
                    let folder = self.customFoldersArray[indexPath.row]
                    let folderName = folder.folderName
                    let selected = isSelected(section: indexPath.section, row: indexPath.row)
                    let folderColor = folder.color
                    
                    let unreadCount = self.parentViewController?.presenter?.interactor?.getUnreadMessagesCount(folderName: folderName!)
                    
                    (cell as! CustomFolderTableViewCell).setupCustomFolderTableCell(selected: selected, iconColor: folderColor!, title: folderName!, unreadCount: unreadCount!)
                } else {
                
                    if indexPath.row == self.customFoldersArray.count {
                        cell.textLabel?.textColor = k_sideMenuColor
                        cell.textLabel?.text = "hideFolders".localized()
                    }
                }
                
            } else {
                
                if indexPath.row < k_numberOfCustomFoldersShowing {
                    
                    if self.customFoldersArray.count > indexPath.row {
                        cell = tableView.dequeueReusableCell(withIdentifier: k_CustomFolderTableViewCellIdentifier)! as! CustomFolderTableViewCell
                        
                        let folder = self.customFoldersArray[indexPath.row]
                        let folderName = folder.folderName                       
                        let selected = isSelected(section: indexPath.section, row: indexPath.row)
                        let folderColor = folder.color
                        
                        let unreadCount = self.parentViewController?.presenter?.interactor?.getUnreadMessagesCount(folderName: folderName!)
                        
                        (cell as! CustomFolderTableViewCell).setupCustomFolderTableCell(selected: selected, iconColor: folderColor!, title: folderName!, unreadCount: unreadCount!)
                    }
                } else {
                  
                    if indexPath.row == k_numberOfCustomFoldersShowing {
                        cell.textLabel?.textColor = k_redColor
                        cell.textLabel?.text = "showMoreFolders".localized()
                    }
                }
            }
            
            break
        default:
            print("unknown section")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if self.selectedIndexPath == indexPath {
            
            if (!Device.IS_IPAD) {
                self.parentViewController?.dismiss(animated: true, completion: nil)
            } else {
                self.parentViewController?.splitViewController?.toggleMasterView()
            }
            
            return
        }
        
        let currentSelectedIndexPath = self.selectedIndexPath
        self.selectedIndexPath = indexPath
        self.tableView.reloadData()//for update Selection Status of Rows
        
        switch indexPath.section {
            case SideMenuSectionIndex.mainFolders.rawValue:
                let optionName = self.mainFoldersArray[indexPath.row]
                self.parentViewController?.presenter?.interactor?.selectSideMenuAction(optionName: optionName)
                
                break
            case SideMenuSectionIndex.options.rawValue:
                let optionName = self.optionsArray[indexPath.row]
                self.parentViewController?.presenter?.interactor?.selectSideMenuAction(optionName: optionName)
                break
            case SideMenuSectionIndex.manageFolders.rawValue:
                let optionName = InboxSideMenuOptionsName.manageFolders.rawValue 
                self.parentViewController?.presenter?.interactor?.selectSideMenuAction(optionName: optionName)
                break
            case SideMenuSectionIndex.customFolders.rawValue:
                
                if self.showAllFolders {
                    if indexPath.row < self.customFoldersArray.count {
                        let folder = self.customFoldersArray[indexPath.row]
                        let folderName = folder.folderName
                        self.parentViewController?.presenter?.interactor?.applyCustomFolderAction(folderName: folderName!)
                    } else {
                        self.showAllFolders = false
                        self.selectedIndexPath = currentSelectedIndexPath
                        self.tableView.reloadData()
                    }
                } else {
                    if indexPath.row == k_numberOfCustomFoldersShowing {
                        self.showAllFolders = true
                        self.selectedIndexPath = currentSelectedIndexPath
                        self.tableView.reloadData()
                    } else {
                        let folder = self.customFoldersArray[indexPath.row]
                        let folderName = folder.folderName
                        self.parentViewController?.presenter?.interactor?.applyCustomFolderAction(folderName: folderName!)
                    }
                }
 
                break
            default:
                print("selected unknown section")
        }
        
        //self.selectedIndexPath = indexPath
        //self.reloadData()//for update Selection Status of Rows
    }
    
    func reloadData() {
        /*
        if self.customFoldersArray.count > k_numberOfCustomFoldersShowing {
            self.showAllFolders = false
        } else {
            self.showAllFolders = true
        }*/
        
        self.tableView.reloadData()
    }
    
    func isSelected(folderName: String) -> Bool {
        
        //if folderName == self.parentViewController?.currentParentViewController.currentFolder {
        //    return true
        //}
        
        return false
    }
    
    func isSelected(section: Int, row: Int) -> Bool {
        
        //print("selectedIndexPath:", self.selectedIndexPath.row, "/", self.selectedIndexPath.section)
        
        if self.selectedIndexPath.row == row && self.selectedIndexPath.section == section {
            return true
        }
        
        return false
    }
    
    @objc func tappedHeaderAction(sender : UITapGestureRecognizer) {
        
        print("tap to Manage Folders")
    }
}
