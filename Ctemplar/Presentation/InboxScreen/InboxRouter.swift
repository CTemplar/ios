//
//  InboxRouter.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 11.10.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import UIKit
import SideMenu

class InboxRouter {
    
    var viewController: InboxViewController?
    
    func showInboxSideMenu() {
 
        if (!Device.IS_IPAD) {
            viewController?.present(SideMenuManager.default.menuLeftNavigationController!, animated: true, completion: nil)
        } else {
            self.viewController?.splitViewController?.toggleMasterView()
        }
    }
    
    func showComposeViewController(answerMode: AnswerMessageMode) {
 
        let storyboard: UIStoryboard = UIStoryboard(name: k_ComposeStoryboardName, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: k_ComposeViewControllerID) as! ComposeViewController        
        vc.answerMode = answerMode
        //vc.mailboxesList = (self.viewController?.mailboxesList)!
        vc.user = (self.viewController?.user)!
        self.viewController?.show(vc, sender: self)   
    }
    
    func showSearchViewController() {
        
        let storyboard: UIStoryboard = UIStoryboard(name: k_SearchStoryboardName, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: k_SearchViewControllerID) as! SearchViewController
        vc.messagesList = (self.viewController?.allMessagesArray)!//(self.viewController?.dataSource?.messagesArray)!
        //vc.mailboxesList = (self.viewController?.mailboxesList)!
        vc.user = (self.viewController?.user)!
        self.viewController?.show(vc, sender: self)
    }
    
    func showViewInboxEmailViewController(message: EmailMessage) {
        
        let storyboard: UIStoryboard = UIStoryboard(name: k_ViewInboxEmailStoryboardName, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: k_ViewInboxEmailViewControllerID) as! ViewInboxEmailViewController
        vc.message = message
        vc.messageID = message.messsageID
        vc.currentFolderFilter = self.viewController?.currentFolderFilter
        //vc.mailboxesList = (self.viewController?.mailboxesList)!
        vc.user = (self.viewController?.user)!
        //self.viewController?.show(vc, sender: self)
        //self.viewController?.present(vc, animated: true, completion: nil)
        self.viewController?.navigationController?.pushViewController(vc, animated: true)
    }
    
    func showMoveToViewController() {
        
        let storyboard: UIStoryboard = UIStoryboard(name: k_MoveToStoryboardName, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: k_MoveToViewControllerID) as! MoveToViewController
        if let selectedMessages = self.viewController?.dataSource?.selectedMessagesIDArray {
            vc.selectedMessagesIDArray = selectedMessages
        }
        vc.user = (self.viewController?.user)!
        self.viewController?.present(vc, animated: true, completion: nil)
        //self.viewController?.show(vc, sender: self)
    }
}
