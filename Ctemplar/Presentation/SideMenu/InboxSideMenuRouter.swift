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
    
    func showContactsViewController() {
        
        let storyboard: UIStoryboard = UIStoryboard(name: k_ContactsStoryboardName, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: k_ContactsViewControllerID) as! ContactsViewController
        self.viewController?.currentParentViewController = vc
        vc.contactsList = (self.viewController?.inboxViewController?.user.contactsList)! //temp
        //vc.sideMenuViewController = self.viewController
        self.viewController?.navigationController?.pushViewController(vc, animated: true)
    }
    
    func showManageFoldersViewController() {
        
        let storyboard: UIStoryboard = UIStoryboard(name: k_ManageFoldersStoryboardName, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: k_ManageFoldersViewControllerID) as! ManageFoldersViewController
        self.viewController?.currentParentViewController = vc //?
        self.viewController?.navigationController?.pushViewController(vc, animated: true)
    }
}
