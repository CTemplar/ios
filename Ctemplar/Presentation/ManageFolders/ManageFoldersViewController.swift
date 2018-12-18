//
//  ManageFoldersViewController.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 17.12.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import UIKit
import SideMenu

class ManageFoldersViewController: UIViewController {
    
    var presenter   : ManageFoldersPresenter?
    var router      : ManageFoldersRouter?
    var dataSource  : ManageFoldersDataSource?
    
    var foldersList : Array<Folder> = []
    
    @IBOutlet var foldersTableView         : UITableView!
    @IBOutlet var addFolderView            : UIView!
    
    @IBOutlet var leftBarButtonItem        : UIBarButtonItem!
    
    @IBOutlet var addFolderViewHeightConstraint          : NSLayoutConstraint!
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let configurator = ManageFoldersConfigurator()
        configurator.configure(viewController: self)
        
        self.dataSource?.initWith(parent: self, tableView: foldersTableView)
        
        self.presenter?.setupTableView()
    }
    
    //MARK: - IBActions
    
    @IBAction func menuButtonPressed(_ sender: AnyObject) {
        
        self.router?.showInboxSideMenu()        
    }
    
    @IBAction func addFolderButtonPressed(_ sender: AnyObject) {
        
    }
}
