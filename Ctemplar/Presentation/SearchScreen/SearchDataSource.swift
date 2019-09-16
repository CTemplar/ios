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
    
    var searchText              : String = ""
    
    var tableView               : UITableView!
    var parentViewController    : SearchViewController!
    var formatterService        : FormatterService?
    
    var filtered : Bool = false
    
    var currentOffset = 0
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh(_:)), for: UIControl.Event.valueChanged)
        refreshControl.tintColor = UIColor.gray
        
        return refreshControl
    }()
    
    func initWith(parent: SearchViewController, tableView: UITableView, array: Array<EmailMessage>) {
        
        self.parentViewController = parent
        self.tableView = tableView
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.messagesArray = array        
        
        self.tableView.addSubview(self.refreshControl)
        
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
        cell.setupCellWithData(message: message, foundText: searchText)
                
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsets.zero
        cell.layoutMargins = UIEdgeInsets.zero
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        var message : EmailMessage
        
        if self.filtered {
            message = filteredArray[indexPath.row]
        } else {
            message = messagesArray[indexPath.row]
        }
        
        self.parentViewController.router?.showViewInboxEmailViewController(message: message)
        
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func reloadData() {
        
        self.tableView.reloadData()
        self.refreshControl.endRefreshing()
        
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
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        currentOffset = 0
        parentViewController.presenter?.interactor!.offset = 0
        parentViewController.presenter?.interactor!.getCount = 0
        self.parentViewController.presenter?.interactor?.getAllMessagesPageByPage()
    }
}
