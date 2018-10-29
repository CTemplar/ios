//
//  InboxSideMenuViewController.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 12.10.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import UIKit
import AlertHelperKit //temp

class InboxSideMenuViewController: UIViewController {
    
    var presenter   : InboxSideMenuPresenter?
    var router      : InboxSideMenuRouter?
    var dataSource  : InboxSideMenuDataSource?
    
    var currentParentViewController    : InboxViewController!
    
    var mainFoldersNameList: Array<String> = [InboxSideMenuOptionsName.inbox.rawValue, InboxSideMenuOptionsName.draft.rawValue, InboxSideMenuOptionsName.sent.rawValue, InboxSideMenuOptionsName.starred.rawValue, InboxSideMenuOptionsName.archive.rawValue, InboxSideMenuOptionsName.spam.rawValue, InboxSideMenuOptionsName.trash.rawValue, InboxSideMenuOptionsName.allMails.rawValue]
    
    var customFoldersNameList: Array<String> = []
    var labelsNameList: Array<String> = []
    
    var optionsNameList: Array<String> = [InboxSideMenuOptionsName.logout.rawValue]
                                          
    
    @IBOutlet var inboxSideMenuTableView        : UITableView!
    
    @IBOutlet var nameLabel  : UILabel!
    @IBOutlet var emailLabel : UILabel!
    @IBOutlet var triangle   : UIImageView!
    
    @IBOutlet var triangleTrailingConstraint : NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
            
        let configurator = InboxSideMenuConfigurator()
        configurator.configure(viewController: self)
        
        dataSource?.initWith(parent: self, tableView: inboxSideMenuTableView, mainFoldersArray: mainFoldersNameList, customFoldersArray: customFoldersNameList, labelsArray: labelsNameList, optionsArray: optionsNameList)
        
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        presenter?.setupUserProfileBar()
    }
    
    //MARK: - IBActions
    
    @IBAction func userProfilePressed(_ sender: AnyObject) {
        

    }    
}
