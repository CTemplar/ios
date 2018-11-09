//
//  SearchDataSource.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 09.11.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import UIKit

class SearchDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {
    
    var messagesArray           : Array<EmailMessage> = []
    var customFoldersArray      : Array<Folder> = []
    var filteredArray           : Array<EmailMessage> = []
    
    var tableView               : UITableView!
    var parentViewController    : SearchViewController!
    var formatterService        : FormatterService?
    
    var filtered : Bool = false
    
    func initWith(parent: SearchViewController, tableView: UITableView, array: Array<EmailMessage>) {
        
        self.parentViewController = parent
        self.tableView = tableView
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.messagesArray = array        
        
        registerTableViewCell()
    }
    
    //MARK: - table view
    
    func registerTableViewCell() {
        
        self.tableView.register(UINib(nibName: k_SearchCellXibName, bundle: nil), forCellReuseIdentifier: k_SearchTableViewCellIdentifier)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if self.filtered {
            return self.filteredArray.count
        }
        
        return self.messagesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell : SearchTableViewCell = tableView.dequeueReusableCell(withIdentifier: k_SearchTableViewCellIdentifier)! as! SearchTableViewCell
      
        cell.parentController = self
        
        var message : EmailMessage
        
        if self.filtered {
            message = filteredArray[indexPath.row]
        } else {
            message = messagesArray[indexPath.row]
        }
        
        //let message = messagesArray[indexPath.row]
        cell.setupCellWithData(message: message)
                
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsets.zero
        cell.layoutMargins = UIEdgeInsets.zero
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func reloadData() {
        
        self.tableView.reloadData()
        
        if self.filtered {
            if self.filteredArray.count > 0 {
                self.tableView.isHidden = false
            } else {
                self.tableView.isHidden = true
            }
        } else {
            self.tableView.isHidden = false
        }
    }
}
