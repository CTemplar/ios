//
//  InboxViewController.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 11.10.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import UIKit

class InboxViewController: UIViewController {
    
    var presenter   : InboxPresenter?
    var router      : InboxRouter?
    var dataSource  : InboxDataSource?
    
    var messagesList: Array<EmailMessage> = []
    
    @IBOutlet var inboxTableView        : UITableView!
    
    @IBOutlet var messagesLabel         : UILabel!
    @IBOutlet var unreadMessagesLabel   : UILabel!
    
    @IBOutlet var emptyInbox            : UIView!
    @IBOutlet var grayBorder            : UIView!
    
    @IBOutlet var baseToolBar           : UIView!
    @IBOutlet var advancedToolBar       : UIView!
    @IBOutlet var selectionToolBar      : UIView!
    
    @IBOutlet var rightComposeButton    : UIButton!
    
    @IBOutlet var leftBarButtonItem     : UIBarButtonItem!
    @IBOutlet var rightBarButtonItem    : UIBarButtonItem!
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let configurator = InboxConfigurator()
        configurator.configure(viewController: self)
        
        presenter?.initAndSetupInboxSideMenuController()
        
        dataSource?.initWith(parent: self, tableView: inboxTableView, array: messagesList)
        
        presenter?.setupUI(emailsCount: 0, unreadEmails: 0)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        presenter?.loadMessages()
        navigationController?.navigationBar.backgroundColor = k_whiteColor
    }
       
    //MARK: - IBActions
    
    @IBAction func menuButtonPressed(_ sender: AnyObject) {
  
        router?.showInboxSideMenu()
    }
    
    @IBAction func searchButtonPressed(_ sender: AnyObject) {
        
        presenter?.searchButtonPressed(sender: self)
    }
    
    @IBAction func composeButtonPressed(_ sender: AnyObject) {
        
        router?.showComposeViewController()
    }
    
    @IBAction func filterButtonPressed(_ sender: AnyObject) {
        
    }
    
    @IBAction func unreadButtonPressed(_ sender: AnyObject) {
        
    }
    
    @IBAction func moveButtonPressed(_ sender: AnyObject) {
        
    }
    
    @IBAction func garbageButtonPressed(_ sender: AnyObject) {
        
    }
    
    @IBAction func moreButtonPressed(_ sender: AnyObject) {
        
    }
}
