//
//  InboxSideMenuRouter.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 22.10.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import UIKit

class InboxSideMenuRouter {
    
    var viewController: InboxSideMenuViewController?
    
    func showInboxViewController() {
        
        let storyboard: UIStoryboard = UIStoryboard(name: k_InboxStoryboardName, bundle: nil)
        let inboxNavigationController = storyboard.instantiateViewController(withIdentifier: k_InboxNavigationControllerID) as? InboxNavigationController
        
        self.viewController?.splitViewController?.showDetailViewController(inboxNavigationController!, sender: self)
    }
    
    func showMessagesViewController(vc: InboxViewController) {
        
        self.viewController?.currentParentViewController = vc
        if Device.IS_IPAD {
            self.viewController?.splitViewController?.secondaryViewController?.show(vc, sender: self)
            self.viewController?.splitViewController?.toggleMasterView()
        }else {
            var currentVCStack = self.viewController?.navigationController?.viewControllers
            if (currentVCStack ?? []).count > 1 {
                currentVCStack?.removeSubrange(2...3)
            }
            
            currentVCStack?.append(vc)
            self.viewController?.navigationController?.setViewControllers(currentVCStack!, animated: true)
//            if let navController = self.viewController?.navigationController {
//                for i in 0..<navController.viewControllers.count {
//                    if navController.viewControllers[i] == vc {
//                        navController.viewControllers.remove(at: i)
//                        break
//                    }
//                }
//            }
//            self.viewController?.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func showContactsViewController() {
        
        let storyboard: UIStoryboard = UIStoryboard(name: k_ContactsStoryboardName, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: k_ContactsViewControllerID) as! ContactsViewController
        self.viewController?.currentParentViewController = vc
        vc.contactsList = (self.viewController?.inboxViewController?.user.contactsList)! //temp
        vc.contactsEncrypted = self.viewController?.inboxViewController?.user.settings.isContactsEncrypted ?? false
        //vc.sideMenuViewController = self.viewController
       
        if (!Device.IS_IPAD) {
            self.viewController?.navigationController?.pushViewController(vc, animated: true)
        } else {
            //let navigationController = UINavigationController(rootViewController: vc)
            //self.viewController?.splitViewController?.showDetailViewController(navigationController, sender: self)
            self.viewController?.splitViewController?.secondaryViewController?.show(vc, sender: self)
            self.viewController?.splitViewController?.toggleMasterView()
        }
    }
    
    func showManageFoldersViewController() {
        
        let storyboard: UIStoryboard = UIStoryboard(name: k_ManageFoldersStoryboardName, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: k_ManageFoldersViewControllerID) as! ManageFoldersViewController
        self.viewController?.currentParentViewController = vc
        vc.foldersList = (self.viewController?.inboxViewController?.user.foldersList)!
        vc.user = (self.viewController?.inboxViewController?.user)!
        if (!Device.IS_IPAD) {
            self.viewController?.navigationController?.pushViewController(vc, animated: true)
        } else {
            //let navigationController = UINavigationController(rootViewController: vc)
            //self.viewController?.splitViewController?.showDetailViewController(navigationController, sender: self)
            self.viewController?.splitViewController?.secondaryViewController?.show(vc, sender: self)
            self.viewController?.splitViewController?.toggleMasterView()
        }
    }
    
    func showSettingsViewController() {
        
        let storyboard: UIStoryboard = UIStoryboard(name: k_SettingsStoryboardName, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: k_SettingsViewControllerID) as! SettingsViewController
        self.viewController?.currentParentViewController = vc
        vc.sideMenuViewController = self.viewController
        vc.user = (self.viewController?.inboxViewController?.user)!
        if (!Device.IS_IPAD) {
            self.viewController?.navigationController?.pushViewController(vc, animated: true)
        } else {
            //let navigationController = UINavigationController(rootViewController: vc)
            //self.viewController?.splitViewController?.showDetailViewController(navigationController, sender: self)
            self.viewController?.splitViewController?.secondaryViewController?.show(vc, sender: self)
            self.viewController?.splitViewController?.toggleMasterView()
        }
    }
    
}
