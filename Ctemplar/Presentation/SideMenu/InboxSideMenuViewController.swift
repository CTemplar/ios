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
    
//    var mainViewController: MainViewController?
    
    var presenter   : InboxSideMenuPresenter?
    var router      : InboxSideMenuRouter?
    var dataSource  : InboxSideMenuDataSource?
    
    var currentParentViewController     : UIViewController!
    var inboxViewController             : InboxViewController!
    
    lazy var draftViewController : InboxViewController = {
        let storyboard: UIStoryboard = UIStoryboard(name: k_InboxStoryboardName, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: k_InboxViewControllerID) as! InboxViewController
        vc.currentFolder = InboxSideMenuOptionsName.draft.rawValue
        vc.currentFolderFilter = MessagesFoldersName.draft.rawValue
        return vc
    }()
    
    lazy var sentViewControllet : InboxViewController = {
        let storyboard: UIStoryboard = UIStoryboard(name: k_InboxStoryboardName, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: k_InboxViewControllerID) as! InboxViewController
        vc.currentFolder = InboxSideMenuOptionsName.sent.rawValue
        vc.currentFolderFilter = MessagesFoldersName.sent.rawValue
        return vc
    }()
    
    lazy var outboxViewController : InboxViewController = {
        let storyboard: UIStoryboard = UIStoryboard(name: k_InboxStoryboardName, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: k_InboxViewControllerID) as! InboxViewController
        vc.currentFolder = InboxSideMenuOptionsName.outbox.rawValue
        vc.currentFolderFilter = MessagesFoldersName.outbox.rawValue
        return vc
    }()
    
    lazy var starredViewController : InboxViewController = {
        let storyboard: UIStoryboard = UIStoryboard(name: k_InboxStoryboardName, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: k_InboxViewControllerID) as! InboxViewController
        vc.currentFolder = InboxSideMenuOptionsName.starred.rawValue
        vc.currentFolderFilter = MessagesFoldersName.starred.rawValue
        return vc
    }()
    
    lazy var archiveViewController : InboxViewController = {
        let storyboard: UIStoryboard = UIStoryboard(name: k_InboxStoryboardName, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: k_InboxViewControllerID) as! InboxViewController
        vc.currentFolder = InboxSideMenuOptionsName.archive.rawValue
        vc.currentFolderFilter = MessagesFoldersName.archive.rawValue
        return vc
    }()
    
    lazy var spamViewController : InboxViewController = {
        let storyboard: UIStoryboard = UIStoryboard(name: k_InboxStoryboardName, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: k_InboxViewControllerID) as! InboxViewController
        vc.currentFolder = InboxSideMenuOptionsName.spam.rawValue
        vc.currentFolderFilter = MessagesFoldersName.spam.rawValue
        return vc
    }()
    
    lazy var trashViewController : InboxViewController = {
        let storyboard: UIStoryboard = UIStoryboard(name: k_InboxStoryboardName, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: k_InboxViewControllerID) as! InboxViewController
        vc.currentFolder = InboxSideMenuOptionsName.trash.rawValue
        vc.currentFolderFilter = MessagesFoldersName.trash.rawValue
        return vc
    }()
    
    lazy var allMailViewController : InboxViewController = {
        let storyboard: UIStoryboard = UIStoryboard(name: k_InboxStoryboardName, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: k_InboxViewControllerID) as! InboxViewController
        vc.currentFolder = InboxSideMenuOptionsName.allMails.rawValue
        vc.currentFolderFilter = ""
        return vc
    }()
    
    lazy var customFoldersViewController: InboxViewController = {
        let storyboard: UIStoryboard = UIStoryboard(name: k_InboxStoryboardName, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: k_InboxViewControllerID) as! InboxViewController
        return vc
    }()
    
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
            
        let configurator = InboxSideMenuConfigurator()
        configurator.configure(viewController: self)
        
        dataSource?.initWith(parent: self, tableView: inboxSideMenuTableView)
        
        dataSource?.setupData(mainFoldersArray: mainFoldersNameList, mainFoldersImageNameList: mainFoldersImageNameList, customFoldersArray: customFoldersNameList, labelsArray: labelsNameList, optionsArray: optionsNameList, optionsImageNameList: optionsImageNameList)
        
        self.navigationController?.navigationBar.isHidden = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(userDataUpdate), name: NSNotification.Name(rawValue: k_updateUserDataNotificationID), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(customFoldersUpdated(notification:)), name: NSNotification.Name(rawValue: k_updateCustomFolderNotificationID), object: nil)
        
        if (Device.IS_IPAD) {
            NotificationCenter.default.addObserver(self, selector: #selector(reloadViewController), name: NSNotification.Name(rawValue: k_reloadViewControllerNotificationID), object: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        DispatchQueue.main.async {
            self.presenter?.interactor?.unreadMessagesCounter()
        }
        
//        self.scrollTableToTop()
    }
    
    func scrollTableToTop() {
        
        let firstIndexPath = IndexPath(row: 0, section: 0)
        self.inboxSideMenuTableView.scrollToRow(at: firstIndexPath, at: .top, animated: true)
    }
    
    //MARK: - IBActions
    
    @IBAction func userProfilePressed(_ sender: AnyObject) {
        

    }
    
    @objc func userDataUpdate(notification: Notification) {
        
        let userData = notification.object as! UserMyself
            
        if let folders = userData.foldersList {
            self.dataSource?.customFoldersArray = folders
            self.dataSource?.reloadData()
        }
        
        var userName : String = ""
        
        if let getUserName = userData.username {
            userName = getUserName
        }
        
        if let mailboxes = userData.mailboxesList {
            self.presenter?.setupUserProfileBar(mailboxes: mailboxes, userName: userName)
        }
        
        DispatchQueue.main.async {
            self.presenter?.interactor?.unreadMessagesCounter()
        }
    }
    
    @objc func customFoldersUpdated(notification: Notification) {
        let customFolders = notification.object as? [Folder] ?? []
        self.dataSource?.customFoldersArray = customFolders
        self.dataSource?.reloadData()
    }
    
    @objc func reloadViewController() {
        
        self.viewDidLoad()
        self.viewWillAppear(false)
    }
}
