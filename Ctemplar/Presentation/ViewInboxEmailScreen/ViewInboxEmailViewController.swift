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
    
    var moreActionsView : MoreActionsView?
    
    var currentFolderFilter : String?
    
    var lastAction : ActionsIndex = ActionsIndex.noAction
    
    var messageIsRead : Bool?
    var messageIsStarred: Bool?
    
    var message : EmailMessage?
    //var header  : String?
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let configurator = ViewInboxEmailConfigurator()
        configurator.configure(viewController: self)
        
        self.messageIsRead = message?.read
        self.messageIsStarred = message?.starred
        
        self.presenter?.setupNavigationBar()
        self.presenter?.setupMessageHeader(message: self.message!)
        
        self.presenter?.initMoreActionsView()
    }
    
    //MARK: - IBActions
    
    @IBAction func replyButtonPressed(_ sender: AnyObject) {
        
        
    }
    
    @IBAction func replyAllButtonPressed(_ sender: AnyObject) {
        
        
    }
    
    @IBAction func forwardButtonPressed(_ sender: AnyObject) {
        
        
    }
    
    @IBAction func undoButtonPressed(_ sender: AnyObject) {
        
        self.presenter?.interactor?.undoLastAction(message: self.message!)
    }
    
    @IBAction func starButtonPressed(_ sender: AnyObject) {
        
        self.presenter?.starButtonPressed()
    }
}

extension ViewInboxEmailViewController: MoreActionsDelegate {
    
    func applyAction(_ sender: AnyObject) {
        
        presenter?.applyMoreAction(sender)
    }
}
