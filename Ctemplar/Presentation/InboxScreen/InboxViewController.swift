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
    var moreActionsView : MoreActionsView?
    
    var inboxSideMenuViewController: InboxSideMenuViewController?
    
    var allMessagesList : EmailMessagesList?
    
    var allMessagesArray : Array<EmailMessage> = []
    var currentFolderMessagesArray : Array<EmailMessage> = []
    var mailboxesList    : Array<Mailbox> = []
    var contactsList     : Array<Contact> = []
    
    var currentFolder       : String = InboxSideMenuOptionsName.inbox.rawValue
    var currentFolderFilter : String = MessagesFoldersName.inbox.rawValue
    
    var appliedActionMessage : EmailMessage?
    
    var lastAction : ActionsIndex = ActionsIndex.noAction
    
    var mainFoldersUnreadMessagesCount: Array<Int> = [0, 0, 0, 0, 0, 0, 0, 0]
    
    var appliedFilters   : Array<Bool> = [false, false, false]
    
    var emailsCount : Int = 0
    var unreadEmails: Int = 0
    
    @IBOutlet var inboxTableView        : UITableView!
    
    @IBOutlet var messagesLabel         : UILabel!
    @IBOutlet var unreadMessagesLabel   : UILabel!
    
    @IBOutlet var emptyInbox            : UIView!
    @IBOutlet var inboxEmptyImageView   : UIImageView!
    @IBOutlet var inboxEmptyLabel       : UILabel!
    @IBOutlet var grayBorder            : UIView!
    
    @IBOutlet var baseToolBar           : UIView!
    @IBOutlet var advancedToolBar       : UIView!
    @IBOutlet var selectionToolBar      : UIView!
    @IBOutlet var selectionDraftToolBar : UIView!
    @IBOutlet var undoBar               : UIView!
    
    @IBOutlet var rightComposeButton    : UIButton!
    @IBOutlet var leftFilterButton      : UIButton!
    @IBOutlet var undoButton            : UIButton!
    
    @IBOutlet var leftBarButtonItem     : UIBarButtonItem!
    @IBOutlet var rightBarButtonItem    : UIBarButtonItem!
    @IBOutlet var moreBarButtonItem     : UIBarButtonItem!
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let configurator = InboxConfigurator()
        configurator.configure(viewController: self)
        
        dataSource?.initWith(parent: self, tableView: inboxTableView, array: allMessagesArray)
        
        presenter?.setupUI(emailsCount: 0, unreadEmails: 0, filterEnabled: false)
        presenter?.initFilterView()
        presenter?.initMoreActionsView()
        
        adddNotificationObserver()
        
        self.navigationItem.title = currentFolder
        self.leftBarButtonItem.isEnabled = false
        
        self.presenter?.interactor?.updateMessages(withUndo: "", silent: false)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //self.presenter?.interactor?.updateMessages(withUndo: "")
        self.presenter?.interactor?.userMyself()
        
        navigationController?.navigationBar.backgroundColor = k_whiteColor
    }
       
    //MARK: - IBActions
    
    @IBAction func menuButtonPressed(_ sender: AnyObject) {
  
        router?.showInboxSideMenu()
    }
    
    @IBAction func searchButtonPressed(_ sender: AnyObject) {
        
    //    presenter?.searchButtonPressed(sender: self)
    }
    
    @IBAction func moreNavButtonPressed(_ sender: AnyObject) {
        
    //    presenter?.searchButtonPressed(sender: self)
    }
    
    @IBAction func composeButtonPressed(_ sender: AnyObject) {
        
        router?.showComposeViewController(title: "newMessage".localized())
    }
    
    @IBAction func filterButtonPressed(_ sender: AnyObject) {
        
        presenter?.showFilterView()
    }
    
    //MARK: - Selected Actions
    
    @IBAction func unreadButtonPressed(_ sender: AnyObject) {
        
        self.presenter?.markSelectedMessagesAsRead()
    }
    
    @IBAction func spamButtonPressed(_ sender: AnyObject) {
        
        self.presenter?.markSelectedMessagesAsSpam()
    }
    
    @IBAction func moveButtonPressed(_ sender: AnyObject) {
        
        self.router?.showMoveToViewController()
    }
    
    @IBAction func garbageButtonPressed(_ sender: AnyObject) {
        
        self.presenter?.markSelectedMessagesAsTrash()
    }
    
    @IBAction func moreButtonPressed(_ sender: AnyObject) {
        
        self.presenter?.showMoreActionsView(emptyFolder: false)
    }
    
    @IBAction func undoButtonPressed(_ sender: AnyObject) {
        
        if appliedActionMessage != nil {
            if (self.dataSource?.selectedMessagesIDArray.count)! > 0 {
                self.presenter?.interactor?.undoLastAction(message: appliedActionMessage!)
            } else {
                print("messages not selected!!!")
            }
        }
    }
    
    //MARK: - notification
    
    func adddNotificationObserver() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.reciveUpdateNotification(notification:)), name: Notification.Name(k_updateInboxMessagesNotificationID), object: nil)
    }
    
    @objc func reciveUpdateNotification(notification: Notification) {
        
        var silent : Bool = false
        
        if notification.object != nil {
            silent = notification.object as! Bool
        }
        
        self.presenter?.interactor?.updateMessages(withUndo: "", silent: silent)
    }    
}

extension InboxViewController: InboxFilterDelegate {
    
    func applyAction(_ sender: AnyObject, appliedFilters: Array<Bool>) {
        
        self.appliedFilters = appliedFilters
        presenter?.showFilterView()
        presenter?.applyFilterAction(sender)
    }
    
    func cancelAction() {
        
        presenter?.showFilterView()
        
        self.presenter?.setupUI(emailsCount: emailsCount, unreadEmails: unreadEmails, filterEnabled: false)
    }
}

extension InboxViewController: MoreActionsDelegate {
    
    func applyAction(_ sender: AnyObject, isButton: Bool) {
        
        presenter?.applyMoreAction(sender, isButton: isButton)
    }
}
