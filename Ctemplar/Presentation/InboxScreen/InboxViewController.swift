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
    
    var inboxFilterView : InboxFilterView?
    
    var currentMessagesList : EmailMessagesList?
    
    var messagesList    : Array<EmailMessage> = []
    var mailboxesList   : Array<Mailbox> = []
    
    var currentFolder       : String = InboxSideMenuOptionsName.inbox.rawValue
    var currentFolderFilter : String = MessagesFoldersName.inbox.rawValue
    
    var appliedActionMessage : EmailMessage?
    
    var mainFoldersUnreadMessagesCount: Array<Int> = []
    
    @IBOutlet var inboxTableView        : UITableView!
    
    @IBOutlet var messagesLabel         : UILabel!
    @IBOutlet var unreadMessagesLabel   : UILabel!
    
    @IBOutlet var emptyInbox            : UIView!
    @IBOutlet var grayBorder            : UIView!
    
    @IBOutlet var baseToolBar           : UIView!
    @IBOutlet var advancedToolBar       : UIView!
    @IBOutlet var selectionToolBar      : UIView!
    @IBOutlet var undoBar               : UIView!
    
    @IBOutlet var rightComposeButton    : UIButton!
    @IBOutlet var leftFilterButton      : UIButton!
    @IBOutlet var undoButton            : UIButton!
    
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
        presenter?.initFilterView()
        
        adddNotificationObserver()
        
        self.navigationItem.title = currentFolder
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.presenter?.interactor?.updateMessages()
        
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
        
        presenter?.showFilterView()
    }
    
    @IBAction func unreadButtonPressed(_ sender: AnyObject) {
        
        self.presenter?.showUndoBar(text: "Undo mark as Read")
    }
    
    @IBAction func moveButtonPressed(_ sender: AnyObject) {
        
        self.presenter?.showUndoBar(text: "Undo moving")
    }
    
    @IBAction func garbageButtonPressed(_ sender: AnyObject) {
        
        self.presenter?.showUndoBar(text: "Undo delete")
    }
    
    @IBAction func moreButtonPressed(_ sender: AnyObject) {
        
        self.presenter?.showUndoBar(text: "Undo ...")
    }
    
    @IBAction func undoButtonPressed(_ sender: AnyObject) {
        
        if appliedActionMessage != nil {
            self.presenter?.interactor?.undoLastAction(message: appliedActionMessage!)
        }        
    }
    
    //MARK: - notification
    
    func adddNotificationObserver() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.reciveUpdateNotification(notification:)), name: Notification.Name(k_updateInboxMessagesNotificationID), object: nil)
    }
    
    @objc func reciveUpdateNotification(notification: Notification) {
        
        self.presenter?.interactor?.updateMessages()
    }    
}

extension InboxViewController: InboxFilterDelegate {
    
    func applyAction(_ sender: AnyObject) {
        
       presenter?.showFilterView()
       presenter?.applyFilterAction(sender)
    }
}
