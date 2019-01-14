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
    
    var showFromSideMenu : Bool = true
    
    var foldersList : Array<Folder> = []
    
    var user = UserMyself()
    
    @IBOutlet var foldersTableView         : UITableView!
    @IBOutlet var addFolderView            : UIView!
    @IBOutlet var redBottomView            : UIView!
    
    @IBOutlet var leftBarButtonItem        : UIBarButtonItem!
    @IBOutlet var addFolderButton          : UIButton!
    
    @IBOutlet var addFolderLabel           : UILabel!
    @IBOutlet var addFolderImage           : UIImageView!
    
    @IBOutlet var addFolderViewHeightConstraint          : NSLayoutConstraint!
    
    @IBOutlet var addFolderViewWithConstraint            : NSLayoutConstraint!
    @IBOutlet var addFolderLabelWidthConstraint          : NSLayoutConstraint!
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let configurator = ManageFoldersConfigurator()
        configurator.configure(viewController: self)
        
        if !self.showFromSideMenu {
            self.presenter?.setupBackButton()
        }
        
        self.dataSource?.initWith(parent: self, tableView: foldersTableView)
        
        self.presenter?.setDataSource(folders: self.foldersList)
        self.presenter?.setupAddFolderButton()
        self.presenter?.setupAddFolderButtonLabel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.presenter?.interactor?.foldersList()
    }
    
    //MARK: - IBActions
    
    @IBAction func menuButtonPressed(_ sender: AnyObject) {
        
        if self.showFromSideMenu {
            self.router?.showInboxSideMenu()
        } else {
            self.router?.backAction()
        }
    }
    
    @IBAction func addFolderButtonPressed(_ sender: AnyObject) {
        
        self.router?.showAddFolderViewController()
    }
}
