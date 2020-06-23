//
//  InboxSideMenuRouter.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 22.10.2018.
//  Copyright © 2018 CTemplar. All rights reserved.
//

import Foundation
import UIKit

class InboxSideMenuRouter {
    
    var viewController: InboxSideMenuViewController?
    
    func showMessagesViewController(vc: InboxViewController) {
        
        self.viewController?.currentParentViewController = vc
//        if Device.IS_IPAD {
//            self.viewController?.splitViewController?.secondaryViewController?.show(vc, sender: self)
//            self.viewController?.splitViewController?.toggleMasterView()
//        }else {
            let navController = UINavigationController.getNavController(rootViewController: vc)
            self.viewController?.slideMenuController()?.changeMainViewController(navController, close: true)
//        }
    }
    
    func showContactsViewController() {
        
        let contactsVC = ContactsViewController.instantiate(fromAppStoryboard: .Contacts)
        self.viewController?.currentParentViewController = contactsVC
        contactsVC.contactsList = (self.viewController?.inboxViewController?.user.contactsList)! //temp
        contactsVC.contactsEncrypted = self.viewController?.inboxViewController?.user.settings.isContactsEncrypted ?? false
        
//        if (!Device.IS_IPAD) {
        let navController = UIViewController.getNavController(rootViewController: contactsVC)
            self.viewController?.slideMenuController()?.changeMainViewController(navController, close: true)
//        } else {
//            self.viewController?.splitViewController?.secondaryViewController?.show(contactsVC, sender: self)
//            self.viewController?.splitViewController?.toggleMasterView()
//        }
    }
    
    func showManageFoldersViewController() {
        
        let vc = ManageFoldersViewController.instantiate(fromAppStoryboard: .ManageFolders)
        self.viewController?.currentParentViewController = vc
        vc.foldersList = (self.viewController?.inboxViewController?.user.foldersList)!
        vc.user = (self.viewController?.inboxViewController?.user)!
//        if (!Device.IS_IPAD) {
            let navController = UIViewController.getNavController(rootViewController: vc)
            self.viewController?.slideMenuController()?.changeMainViewController(navController, close: true)
//        } else {
//            self.viewController?.splitViewController?.secondaryViewController?.show(vc, sender: self)
//            self.viewController?.splitViewController?.toggleMasterView()
//        }
    }
    
    func showSettingsViewController() {
        let vc = SettingsViewController.instantiate(fromAppStoryboard: .Settings)
        self.viewController?.currentParentViewController = vc
        vc.sideMenuViewController = self.viewController
        vc.user = (self.viewController?.inboxViewController?.user)!
        let navController = UIViewController.getNavController(rootViewController: vc)
        self.viewController?.slideMenuController()?.changeMainViewController(navController, close: true)
    }
    
    func showFAQ() {
        let vc = FAQViewController.instantiate(fromAppStoryboard: .FAQ)
        viewController?.currentParentViewController = vc
        vc.sideMenuViewController = viewController
        let navController = UIViewController.getNavController(rootViewController: vc)
        viewController?.slideMenuController()?.changeMainViewController(navController, close: true)
    }
}
