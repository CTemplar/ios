//
//  WhiteBlackListsRouter.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 27.12.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import UIKit


class WhiteBlackListsRouter {
    
    var viewController: WhiteBlackListsViewController?

    func showAddContactToWhiteBlackList(mode: WhiteBlackListsMode) {
        
        let storyboard: UIStoryboard = UIStoryboard(name: k_AddContackToWhiteBlackListsStoryboardName, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: k_AddContactToWhiteBlackListsViewControllerID) as! AddContactToWhiteBlackListViewController
        vc.delegate = self.viewController
        vc.mode = mode
        self.viewController?.present(vc, animated: true, completion: nil)
    }
}
