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
        vc.showFromSideMenu = false
        let navigationController = UINavigationController(rootViewController: vc)        
        self.viewController?.present(navigationController, animated: true, completion: nil)
    }    
}
