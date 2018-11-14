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
    
    var moreActionsView : MoreActionsView?
    
    var currentFolderFilter : String?
    
    var lastAction : ActionsIndex = ActionsIndex.noAction
    
    var messageIsRead : Bool?
    var messageIsStarred: Bool?
    
    var message : EmailMessage?
    var messageID  : Int?
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let configurator = ViewInboxEmailConfigurator()
        configurator.configure(viewController: self)
        
        self.presenter?.setupNavigationBar(enabled: false)
        self.presenter?.setupBottomBar(enabled: false)
        //self.presenter?.setupMessageHeader(message: self.message!)
        
        self.presenter?.initMoreActionsView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let messageID = self.messageID {
            self.presenter?.interactor?.getMessage(messageID: messageID)
        }        
    }
    
    //MARK: - IBActions
    
    @IBAction func replyButtonPressed(_ sender: AnyObject) {
        
        self.router?.showComposeViewController(title: "reply".localized())
    }
    
    @IBAction func replyAllButtonPressed(_ sender: AnyObject) {
        
        self.router?.showComposeViewController(title: "relpyAll".localized())
    }
    
    @IBAction func forwardButtonPressed(_ sender: AnyObject) {
        
        self.router?.showComposeViewController(title: "forward".localized())
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
