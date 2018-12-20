//
//  SettingsRouter.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 20.12.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import UIKit
import SideMenu

class SettingsRouter {
    
    var viewController: SettingsViewController?

    func showInboxSideMenu() {
        
        self.viewController?.present(SideMenuManager.default.menuLeftNavigationController!, animated: true, completion: nil)
    }
}
