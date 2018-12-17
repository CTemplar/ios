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
    
    @IBOutlet var leftBarButtonItem        : UIBarButtonItem!
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let configurator = ManageFoldersConfigurator()
        configurator.configure(viewController: self)
        
        dataSource?.initWith(parent: self, tableView: foldersTableView)
        
        //temp
        dataSource?.foldersArray = foldersList
        dataSource?.reloadData()
        if foldersList.count > 0 {
            self.foldersTableView.isHidden = false
        }
    }
    
    //MARK: - IBActions
    
    @IBAction func menuButtonPressed(_ sender: AnyObject) {
        
        //self.router?.showInboxSideMenu()
        self.present(SideMenuManager.default.menuLeftNavigationController!, animated: true, completion: nil)
    }
    
}
