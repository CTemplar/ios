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
        
        //self.viewController?.present(SideMenuManager.default.menuLeftNavigationController!, animated: true, completion: nil)
        if (!Device.IS_IPAD) {
            self.viewController?.present(SideMenuManager.default.menuLeftNavigationController!, animated: true, completion: nil)
        } else {
            self.viewController?.splitViewController?.toggleMasterView()
        }
    }
    
    func backAction() {
        
        if (self.viewController?.showFromSettings)! {
            self.viewController?.navigationController?.popViewController(animated: true)
        } else {
            self.viewController?.dismiss(animated: true, completion: nil)
        }
    }
    
    func showAddFolderViewController() {
        
        var storyboardName : String? = k_AddFolderStoryboardName
        
        if (Device.IS_IPAD) {
            storyboardName = k_AddFolderStoryboardName_iPad
        }
        
        let storyboard: UIStoryboard = UIStoryboard(name: storyboardName!, bundle: nil)
        //let storyboard: UIStoryboard = UIStoryboard(name: k_AddFolderStoryboardName, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: k_AddFolderViewControllerID) as! AddFolderViewController
        self.viewController?.present(vc, animated: true, completion: nil)
        //self.viewController?.show(vc, sender: self)
    }
    
    func showEditFolderViewController(folder: Folder) {
        
        let storyboard: UIStoryboard = UIStoryboard(name: k_EditFolderStoryboardName, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: k_EditFolderViewControllerID) as! EditFolderViewController
        vc.folder = folder
        self.viewController?.show(vc, sender: self)
    }
}
