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
    
    var currentParentViewController     : UIViewController!
    var inboxViewController             : InboxViewController!
    
    var mainFoldersNameList: Array<String> = [
        InboxSideMenuOptionsName.inbox.rawValue,
        InboxSideMenuOptionsName.draft.rawValue,
        InboxSideMenuOptionsName.sent.rawValue,
        InboxSideMenuOptionsName.outbox.rawValue,
        InboxSideMenuOptionsName.starred.rawValue,
        InboxSideMenuOptionsName.archive.rawValue,
        InboxSideMenuOptionsName.spam.rawValue,
        InboxSideMenuOptionsName.trash.rawValue,
        //InboxSideMenuOptionsName.allMails.rawValue
    ]
    
    var mainFoldersImageNameList: Array<String> = [
        k_darkInboxIconImageName,
        k_darkDraftIconImageName,
        k_darkSentIconImageName,
        k_darkOutboxIconImageName,
        k_darkStarIconImageName,
        k_darkArchiveIconImageName,
        k_darkSpamIconImageName,
        k_darkTrashIconImageName,
       //k_darkAllMailsIconImageName
    ]
    
    //var mainFoldersUnreadMessagesCount: Array<Int> = []
    
    var customFoldersNameList: Array<String> = []
    var labelsNameList: Array<String> = []
    
    var optionsNameList: Array<String> = [
        InboxSideMenuOptionsName.contacts.rawValue,
        InboxSideMenuOptionsName.settings.rawValue,
        InboxSideMenuOptionsName.help.rawValue,
        InboxSideMenuOptionsName.logout.rawValue
    ]
    
    var optionsImageNameList: Array<String> = [
        k_darkContactIconImageName,
        k_darkSettingsIconImageName,
        k_darkHelpconImageName,
        k_darkExitIconImageName
    ]
                                          
    
    @IBOutlet var inboxSideMenuTableView        : UITableView!
    
    @IBOutlet var nameLabel  : UILabel!
    @IBOutlet var emailLabel : UILabel!
    @IBOutlet var triangle   : UIImageView!
    
    @IBOutlet var triangleTrailingConstraint : NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
            
        let configurator = InboxSideMenuConfigurator()
        configurator.configure(viewController: self)
        
        dataSource?.initWith(parent: self, tableView: inboxSideMenuTableView)
        
        dataSource?.setupData(mainFoldersArray: mainFoldersNameList, mainFoldersImageNameList: mainFoldersImageNameList, customFoldersArray: customFoldersNameList, labelsArray: labelsNameList, optionsArray: optionsNameList, optionsImageNameList: optionsImageNameList)
        
        self.navigationController?.navigationBar.isHidden = true
        
        //DispatchQueue.main.async {
            self.presenter?.interactor?.customFoldersList()
        //}
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
        //self.presenter?.setupUserProfileBar()
      
        //self.presenter?.interactor?.customFoldersList()
        DispatchQueue.main.async {
            self.presenter?.interactor?.unreadMessagesCounter()
        }
        //self.presenter?.interactor?.userMyself()
    }
    
    //MARK: - IBActions
    
    @IBAction func userProfilePressed(_ sender: AnyObject) {
        

    }    
}
