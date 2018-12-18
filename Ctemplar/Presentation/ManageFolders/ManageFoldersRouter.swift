//
//  ManageFoldersRouter.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 17.12.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import UIKit
import SideMenu

class ManageFoldersRouter {
    
    var viewController: ManageFoldersViewController?

    func showInboxSideMenu() {
        
        self.viewController?.present(SideMenuManager.default.menuLeftNavigationController!, animated: true, completion: nil)
    }
    
    func backAction() {
        
        self.viewController?.dismiss(animated: true, completion: nil)
    }
}