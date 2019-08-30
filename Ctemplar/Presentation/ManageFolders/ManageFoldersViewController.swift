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
    var showFromSettings : Bool = false
    
    var foldersList : Array<Folder> = []
    
    var user = UserMyself()
    
    var upgradeToPrimeView : UpgradeToPrimeView?
    
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

        self.presenter?.setupAddFolderButtonLabel()
        //self.presenter?.setupAddFolderButton()
        self.presenter?.setAddFolderButton(enable: true)
        self.presenter?.initAddFolderLimitView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.presenter?.interactor?.foldersList(silent: false)
        
        if (Device.IS_IPAD) {
            if self.showFromSideMenu {
                self.presenter?.setupNavigationLeftItem()
            }
        }
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
        
        self.presenter?.addFolderButtonPressed()
    }
    
    //MARK: - Orientation
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        super.viewWillTransition(to: size, with: coordinator)
        
        if (Device.IS_IPAD) {
            if self.showFromSideMenu {
                self.presenter?.setupNavigationLeftItem()
            }
        }
    }
}
