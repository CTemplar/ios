//
//  ContactsRouter.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 14.11.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import UIKit
import SideMenu

class ContactsRouter {
    
    var viewController: ContactsViewController?
    
    func showInboxSideMenu() {
        
        //self.viewController?.inboxSideMenuViewController?.currentParentViewController = self.viewController
        let inboxSideMenuViewController = SideMenuManager.default.menuLeftNavigationController?.children.first as! InboxSideMenuViewController
        inboxSideMenuViewController.currentParentViewController = self.viewController
        self.viewController?.present(SideMenuManager.default.menuLeftNavigationController!, animated: true, completion: nil)
    }
}
