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
        
        viewController?.present(SideMenuManager.default.menuLeftNavigationController!, animated: true, completion: nil)
    }
    
    func showComposeViewController(title: String) {
 
        let storyboard: UIStoryboard = UIStoryboard(name: k_ComposeStoryboardName, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: k_ComposeViewControllerID) as! ComposeViewController
        vc.navBarTitle = title
        self.viewController?.show(vc, sender: self)   
    }
    
    func showSearchViewController() {
        
        let storyboard: UIStoryboard = UIStoryboard(name: k_SearchStoryboardName, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: k_SearchViewControllerID) as! SearchViewController
        //vc.messagesList = (self.viewController?.dataSource?.messagesArray)!
        self.viewController?.show(vc, sender: self)
    }
    
    func showViewInboxEmailViewController(message: EmailMessage) {
        
        let storyboard: UIStoryboard = UIStoryboard(name: k_ViewInboxEmailStoryboardName, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: k_ViewInboxEmailViewControllerID) as! ViewInboxEmailViewController
        //vc.message = message
        vc.messageID = message.messsageID
        vc.currentFolderFilter = self.viewController?.currentFolderFilter
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
        self.viewController?.present(vc, animated: true, completion: nil)
    }
}
