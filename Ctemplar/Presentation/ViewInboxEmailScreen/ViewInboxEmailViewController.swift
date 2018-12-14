//
//  ViewInboxEmailViewController.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 17.10.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import UIKit
import WebKit

class ViewInboxEmailViewController: UIViewController {
    
    var presenter   : ViewInboxEmailPresenter?
    var router      : ViewInboxEmailRouter?
    var dataSource  : ViewInboxEmailDataSource?
        
    @IBOutlet var headerLabelWidthConstraint : NSLayoutConstraint!
    @IBOutlet var fromToViewHeightConstraint : NSLayoutConstraint!
    @IBOutlet var topViewHeightConstraint    : NSLayoutConstraint!
    
    @IBOutlet var headerLabel           : UILabel!
    
    @IBOutlet var fromToBarTextView     : UITextView!
    @IBOutlet var contentTextView       : UITextView!
    
    @IBOutlet var securedImageView      : UIImageView!
    @IBOutlet var starredButton         : UIButton!
    
    @IBOutlet var dateLabel             : UILabel!
    
    @IBOutlet var scrollView            : UIScrollView!
    @IBOutlet var webView               : WKWebView!
    
    @IBOutlet var undoButton            : UIButton!
    @IBOutlet var undoBar               : UIView!
    
    @IBOutlet var replyButton           : UIButton!
    @IBOutlet var replyAllButton        : UIButton!
    @IBOutlet var forwardButton         : UIButton!
    
    @IBOutlet var messagesTableView     : UITableView!
    
    var moreActionsView : MoreActionsView?
    
    var currentFolderFilter : String?
    
    var lastAction : ActionsIndex = ActionsIndex.noAction
    
    var messageIsRead : Bool?
    var messageIsStarred: Bool?
    
    var message : EmailMessage?
    var messageID  : Int?
    
    //var mailboxesList    : Array<Mailbox> = []
    var user = UserMyself()
    
    let documentInteractionController = UIDocumentInteractionController()
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let configurator = ViewInboxEmailConfigurator()
        configurator.configure(viewController: self)
        
        self.presenter?.setupNavigationBar(enabled: false)
        self.presenter?.setupBottomBar(enabled: false)
        
        self.messagesTableView.isHidden = false
        
        dataSource?.initWith(parent: self, tableView: messagesTableView)
        
        self.initShowingMessage()
        
        self.presenter?.initMoreActionsView()
        
        documentInteractionController.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let arrowBackImage = UIImage(named: k_darkBackArrowImageName)
        self.navigationController?.navigationBar.backIndicatorImage = arrowBackImage
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = arrowBackImage
    }
    
    func initShowingMessage() {
        
        if let message = self.message {
            
            if let hasChildren = message.hasChildren {
                
                if hasChildren == true {
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200), execute: {
                        self.presenter?.interactor?.getMessage(messageID: message.messsageID!)
                    })
                    
                    self.messageIsRead = true//message.read
                    self.messageIsStarred = message.starred
                    self.presenter?.setupMessageHeader(message: message)
                    
                } else {
                    self.presenter?.interactor?.setMessageData(message: message)
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300), execute: {
                self.presenter?.checkMessaseReadStatus(message: message)
            })
        }
    }
    
    //MARK: - IBActions
    
    @IBAction func replyButtonPressed(_ sender: AnyObject) {
        
        self.router?.showComposeViewController(answerMode: AnswerMessageMode.reply, subject: self.headerLabel.text!)
    }
    
    @IBAction func replyAllButtonPressed(_ sender: AnyObject) {
        
        self.router?.showComposeViewController(answerMode: AnswerMessageMode.replyAll, subject: self.headerLabel.text!)
    }
    
    @IBAction func forwardButtonPressed(_ sender: AnyObject) {
        
        self.router?.showComposeViewController(answerMode: AnswerMessageMode.forward, subject: self.headerLabel.text!)
    }
    
    @IBAction func undoButtonPressed(_ sender: AnyObject) {
        
        self.presenter?.interactor?.undoLastAction(message: self.message!)
    }
    
    @IBAction func starButtonPressed(_ sender: AnyObject) {
        
        self.presenter?.starButtonPressed()
    }
}

extension ViewInboxEmailViewController: MoreActionsDelegate {
    
    func applyAction(_ sender: AnyObject, isButton: Bool) {
        
        presenter?.applyMoreAction(sender, isButton: isButton)
    }
}

extension ViewInboxEmailViewController: UIDocumentInteractionControllerDelegate {

    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        
        guard let navigationViewController = self.navigationController else {
            return self
        }
        
        return navigationViewController
    }
    
    func documentInteractionControllerWillBeginPreview(_ controller: UIDocumentInteractionController) {
        
        self.presenter!.interactor?.hideProgressIndicator()
    }
}
