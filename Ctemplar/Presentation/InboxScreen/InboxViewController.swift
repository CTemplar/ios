//
//  InboxViewController.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 11.10.2018.
//  Copyright © 2018 CTemplar. All rights reserved.
//

import Foundation
import UIKit
import Utility
import Networking
import Inbox

class InboxViewController: UIViewController {
    
    var presenter   : InboxPresenter?
    var router      : InboxRouter?
    var dataSource  : InboxDataSource?
    
    var inboxFilterView : InboxFilterView?
    var moreActionsView : MoreActionsView?
    
    var inboxSideMenuViewController: InboxSideMenuViewController?
    
    //var allMessagesList : EmailMessagesList = EmailMessagesList.init()
    
    var allMessagesArray : Array<EmailMessage> = []
    var currentFolderMessagesArray : Array<EmailMessage> = []
    var mailboxesList    : Array<Mailbox> = []
    //var contactsList     : Array<Contact> = []
    var user = UserMyself()
    var messageID: Int = -1
    
    var currentFolder       : String = InboxSideMenuOptionsName.inbox.rawValue
    var currentFolderFilter : String = MessagesFoldersName.inbox.rawValue
    
    var appliedActionMessage : EmailMessage?
    
    var lastAction : ActionsIndex = ActionsIndex.noAction
    
    var mainFoldersUnreadMessagesCount: Array<Int> = [0, 0, 0, 0, 0, 0, 0, 0]
    
    var appliedFilters   : Array<Bool> = [false, false, false]
    
    //var emailsCount : Int = 0
    //var unreadEmails: Int = 0
    
    //var senderEmail: String = ""
    
    @IBOutlet var inboxTableView        : UITableView!
    @IBOutlet weak var refreshButton    : UIButton!
    @IBOutlet var messagesLabel         : UILabel!
    @IBOutlet var unreadMessagesLabel   : UILabel!
    @IBOutlet var messageAlertTitle     : UILabel!
    
    @IBOutlet var emptyInbox            : UIView!
    @IBOutlet var inboxEmptyImageView   : UIImageView!
    @IBOutlet var inboxEmptyLabel       : UILabel!
    @IBOutlet var grayBorder            : UIView!
    
    @IBOutlet var baseToolBar           : UIView!
    @IBOutlet var advancedToolBar       : UIView!
    @IBOutlet var selectionToolBar      : UIView!
    @IBOutlet var selectionDraftToolBar : UIView!
    @IBOutlet var undoBar               : UIView!
    @IBOutlet var viewMailSendingAlert  : UIView!
    
    @IBOutlet var bottomComposeButton   : UIButton!
    @IBOutlet var rightComposeButton    : UIButton!
    @IBOutlet var leftFilterButton      : UIButton!
    @IBOutlet var undoButton            : UIButton!
    @IBOutlet var alertButton           : UIButton!
    
    @IBOutlet var leftBarButtonItem     : UIBarButtonItem!
    @IBOutlet var rightBarButtonItem    : UIBarButtonItem!
    @IBOutlet var moreBarButtonItem     : UIBarButtonItem!
    
    var runOnce : Bool = true
    
    //MARK: - Lifecycle
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let configurator = InboxConfigurator()
        configurator.configure(viewController: self)
        
        dataSource?.initWith(parent: self, tableView: inboxTableView, array: allMessagesArray)
        
        presenter?.setupUI(emailsCount: 0, unreadEmails: 0, filterEnabled: false)
        presenter?.initFilterView()
        presenter?.initMoreActionsView()
        
        adddNotificationObserver()

//        self.leftBarButtonItem.isEnabled = false
        self.bottomComposeButton.isEnabled = false
        self.rightComposeButton.isEnabled = false
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100), execute: {
            self.presenter?.interactor?.updateMessages(withUndo: "", silent: false)
//        })
        
        NotificationCenter.default.addObserver(self, selector: #selector(userSettingsUpdate), name: .updateUserSettingsNotificationID, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
                
        if self.runOnce == true { //optimization for showing table already 
            self.presenter?.interactor?.userMyself()
            self.runOnce = false
        }
        
        self.navigationController?.navigationBar.backgroundColor = k_whiteColor
        //need to update after View Messge Back
        self.presenter?.setupNavigationItemTitle(selectedMessages: (self.dataSource?.selectedMessagesIDArray.count)!, selectionMode: (self.dataSource?.selectionMode)!, currentFolder: self.currentFolder)
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
        
        router?.showComposeViewController(answerMode: AnswerMessageMode.newMessage)
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
        
        //self.presenter?.showMoreActionsView(emptyFolder: false)
        if (!Device.IS_IPAD) {
            self.presenter?.showMoreActionsView(emptyFolder: false)
        } else {
            self.presenter?.showMoreActionsActionSheet()
        }
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
    
    @IBAction func alertButtonPressed(_ sender: Any) {
        viewMailSendingAlert.isHidden = true
    }
    
    
    //MARK: - notification
    
    func adddNotificationObserver() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.reciveUpdateNotification(notification:)), name: .updateInboxMessagesNotificationID, object: nil)
    }
    
    @objc func reciveUpdateNotification(notification: Notification) {
        
        var silent : Bool = false
        
        if notification.object != nil {
            silent = notification.object as! Bool
        }
        
        self.presenter?.interactor?.offset = 0
       // if self.presenter?.interactor?.offset == 0 {
            self.presenter?.interactor?.updateMessages(withUndo: "", silent: silent)
        //}
        self.presenter?.interactor?.userMyself()
    }
    
    @objc func userSettingsUpdate(notification: Notification) {
        
        self.presenter?.interactor?.userMyself()
    }
    
    //MARK: - Orientation
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        super.viewWillTransition(to: size, with: coordinator)
        
        if (Device.IS_IPAD) {
            self.presenter?.setupNavigationLeftItem()
        }
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
        
        self.presenter?.setupUI(emailsCount: presenter?.interactor!.totalItems ?? 0, unreadEmails: presenter?.interactor!.unreadEmails ?? 0, filterEnabled: false)
    }
}

extension InboxViewController: MoreActionsDelegate {
    
    func applyAction(_ sender: AnyObject, isButton: Bool) {
        
        presenter?.applyMoreAction(sender, isButton: isButton)
    }
}

extension InboxViewController: ViewInboxEmailDelegate {
    func didUpdateReadStatus(for message: EmailMessage, status: Bool) {
        for i in 0..<allMessagesArray.count {
            if allMessagesArray[i].messsageID == message.messsageID {
                allMessagesArray[i].update(readStatus: status)
                break
            }
        }
        dataSource?.updateMessageStatus(message: message, status: status)
        NotificationCenter.default.post(name: .updateMessagesReadCountNotificationID, object: ["name": self.currentFolder, "isRead": status])
    }
}
