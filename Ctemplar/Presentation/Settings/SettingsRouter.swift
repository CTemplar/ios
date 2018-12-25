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
    
    func showRecoveryEmailViewController() {
        
        let storyboard: UIStoryboard = UIStoryboard(name: k_RecoveryEmailStoryboardName, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: k_RecoveryEmailViewControllerID) as! RecoveryEmailViewController
        vc.user = (self.viewController?.user)!
        let navigationController = UINavigationController(rootViewController: vc)
        self.viewController?.present(navigationController, animated: true, completion: nil)
    }
    
    func showChangePasswordViewController() {
        
        let storyboard: UIStoryboard = UIStoryboard(name: k_ChangePasswordStoryboardName, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: k_ChangePasswordViewControllerID) as! ChangePasswordViewController
        vc.user = (self.viewController?.user)!
        let navigationController = UINavigationController(rootViewController: vc)
        self.viewController?.present(navigationController, animated: true, completion: nil)
    }
    
    func showManageFoldersViewController() {
        
        let storyboard: UIStoryboard = UIStoryboard(name: k_ManageFoldersStoryboardName, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: k_ManageFoldersViewControllerID) as! ManageFoldersViewController
        vc.foldersList = (self.viewController?.user.foldersList)!
        vc.user = (self.viewController?.user)!
        vc.showFromSideMenu = false
        let navigationController = UINavigationController(rootViewController: vc)
        self.viewController?.present(navigationController, animated: true, completion: nil)
    }
    
    func showSetSignatureViewController() {
        
        let storyboard: UIStoryboard = UIStoryboard(name: k_SetSignatureStoryboardName, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: k_SetSignatureViewControllerID) as! SetSignatureViewController
        vc.user = (self.viewController?.user)!
        let navigationController = UINavigationController(rootViewController: vc)
        self.viewController?.present(navigationController, animated: true, completion: nil)
    }
    
    func showAboutAsViewController() {
        
        let storyboard: UIStoryboard = UIStoryboard(name: k_AboutAsStoryboardName, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: k_AboutAsViewControllerID) as! AboutAsViewController
        self.viewController?.present(vc, animated: true, completion: nil)
    }
}
