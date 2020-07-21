//
//  InboxRouter.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 11.10.2018.
//  Copyright © 2018 CTemplar. All rights reserved.
//

import Foundation
import UIKit
import Networking
import SideMenu
import Inbox

class InboxRouter {
    
    var viewController: InboxViewController?
    
    func showInboxSideMenu() {
        viewController?.sideMenuController?.revealMenu()
    }
    
    func showComposeViewController(answerMode: AnswerMessageMode) {
        
        let storyboard: UIStoryboard = UIStoryboard(name: k_ComposeStoryboardName, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: k_ComposeViewControllerID) as! ComposeViewController
        vc.answerMode = answerMode
        vc.user = (self.viewController?.user)!
        self.viewController?.show(vc, sender: self)
    }
    
    func showComposeViewControllerWithDraft(answerMode: AnswerMessageMode, message: EmailMessage) {
 
        let storyboard: UIStoryboard = UIStoryboard(name: k_ComposeStoryboardName, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: k_ComposeViewControllerID) as! ComposeViewController
        
        vc.answerMode = answerMode
        vc.user = (self.viewController?.user)!
        vc.message = message
        
        if let children = message.children {
            if children.count > 0 {
                vc.messagesArray = children
            }
        }
       
        if let draftSubject = message.subject {
            vc.subject = draftSubject
        }
        
        self.viewController?.show(vc, sender: self)   
    }
    
    func showSearchViewController() {
    }
    
    func showViewInboxEmailViewController(message: EmailMessage) {
        
        let storyboard: UIStoryboard = UIStoryboard(name: k_ViewInboxEmailStoryboardName, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: k_ViewInboxEmailViewControllerID) as! ViewInboxEmailViewController
        vc.message = message
        vc.messageID = message.messsageID
        vc.currentFolderFilter = self.viewController?.currentFolderFilter
        vc.viewInboxEmailDelegate = self.viewController
        //vc.mailboxesList = (self.viewController?.mailboxesList)!
        vc.user = (self.viewController?.user)!
        //self.viewController?.show(vc, sender: self)
        //self.viewController?.present(vc, animated: true, completion: nil)
        self.viewController?.navigationController?.pushViewController(vc, animated: true)
    }
    
    func showMoveToViewController() {
    }
}
