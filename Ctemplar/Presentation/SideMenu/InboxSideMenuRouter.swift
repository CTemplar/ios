//
//  InboxSideMenuRouter.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 22.10.2018.
//  Copyright © 2018 CTemplar. All rights reserved.
//

import Foundation
import UIKit
import SideMenu

class InboxSideMenuRouter {
    var viewController: InboxSideMenuViewController?
    
    func showMessagesViewController(vc: InboxViewController) {
        self.viewController?.currentParentViewController = vc
        let navController = UINavigationController.getNavController(rootViewController: vc)
        viewController?.sideMenuController?.setContentViewController(to: navController,
                                                                     animated: true,
                                                                     completion: { [weak self] in
                                                                        self?.viewController?.sideMenuController?.hideMenu()
        })
    }
    
    func showContactsViewController() {
        let contactsVC = ContactsViewController.instantiate(fromAppStoryboard: .Contacts)
        self.viewController?.currentParentViewController = contactsVC
        contactsVC.contactsList = (self.viewController?.inboxViewController?.user.contactsList)! //temp
        contactsVC.contactsEncrypted = self.viewController?.inboxViewController?.user.settings.isContactsEncrypted ?? false
        let navController = UIViewController.getNavController(rootViewController: contactsVC)
        viewController?.sideMenuController?.setContentViewController(to: navController,
                                                                     animated: true,
                                                                     completion: { [weak self] in
                                                                        self?.viewController?.sideMenuController?.hideMenu()
        })
        
    }
    
    func showManageFoldersViewController() {
    }
    
    func showSettingsViewController() {
        let vc = SettingsViewController.instantiate(fromAppStoryboard: .Settings)
        self.viewController?.currentParentViewController = vc
        vc.sideMenuViewController = self.viewController
        vc.user = (self.viewController?.inboxViewController?.user)!
        let navController = UIViewController.getNavController(rootViewController: vc)
        viewController?.sideMenuController?.setContentViewController(to: navController,
                                                                     animated: true,
                                                                     completion: { [weak self] in
                                                                        self?.viewController?.sideMenuController?.hideMenu()
        })
    }
    
    func showFAQ() {
        let vc = FAQViewController.instantiate(fromAppStoryboard: .FAQ)
        viewController?.currentParentViewController = vc
        vc.sideMenuViewController = viewController
        let navController = UIViewController.getNavController(rootViewController: vc)
        viewController?.sideMenuController?.setContentViewController(to: navController,
                                                                     animated: true,
                                                                     completion: { [weak self] in
                                                                        self?.viewController?.sideMenuController?.hideMenu()
        })
    }
}
