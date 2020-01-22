//
//  MoveToRouter.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 06.11.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import UIKit


class MoveToRouter {
    
    var viewController: MoveToViewController?
    
    func showFoldersManagerViewController() {
        
        let storyboard: UIStoryboard = UIStoryboard(name: k_ManageFoldersStoryboardName, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: k_ManageFoldersViewControllerID) as! ManageFoldersViewController
        vc.foldersList = (self.viewController?.dataSource?.customFoldersArray)!
        vc.user = (self.viewController?.user)!
        vc.showFromSideMenu = false
        let navigationController = UINavigationController(rootViewController: vc)        
        self.viewController?.present(navigationController, animated: true, completion: nil)
    }
    
    func showAddFolderViewController() {
        
        var storyboardName : String? = k_AddFolderStoryboardName
        
        if (Device.IS_IPAD) {
            storyboardName = k_AddFolderStoryboardName_iPad
        }
        
        let storyboard: UIStoryboard = UIStoryboard(name: storyboardName!, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: k_AddFolderViewControllerID) as! AddFolderViewController
        self.viewController?.present(vc, animated: true, completion: nil)
    }
}
