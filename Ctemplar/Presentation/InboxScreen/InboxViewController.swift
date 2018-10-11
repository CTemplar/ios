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
    
    @IBOutlet var rightComposeButton    : UIButton!
    
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let configurator = InboxConfigurator()
        configurator.configure(viewController: self)
        
        dataSource?.initWith(parent: self, tableView: inboxTableView, array: messagesList)
        
        presenter?.loadMessages()
        
        presenter?.setupUI(emailsCount: 0, unreadEmails: 0)
    }
       
    //MARK: - IBActions
    
    @IBAction func menuButtonPressed(_ sender: AnyObject) {
  
    }
    
    @IBAction func searchButtonPressed(_ sender: AnyObject) {
        
    }
    
    @IBAction func composeButtonPressed(_ sender: AnyObject) {
        
    }
    
    @IBAction func filterButtonPressed(_ sender: AnyObject) {
        
    }
}
