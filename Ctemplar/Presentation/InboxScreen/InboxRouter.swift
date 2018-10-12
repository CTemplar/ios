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
    
    func showComposeViewController() {
 
        let storyboard: UIStoryboard = UIStoryboard(name: k_ComposeStoryboardName, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: k_ComposeViewControllerID) as! ComposeViewController
        self.viewController?.show(vc, sender: self)   
    }
}
