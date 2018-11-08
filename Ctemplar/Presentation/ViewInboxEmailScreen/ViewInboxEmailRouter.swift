//
//  ViewInboxEmailRouter.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 01.11.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import UIKit


class ViewInboxEmailRouter {
    
    var viewController: ViewInboxEmailViewController?
    
    func showMoveToViewController() {
        
        let storyboard: UIStoryboard = UIStoryboard(name: k_MoveToStoryboardName, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: k_MoveToViewControllerID) as! MoveToViewController
        
        let selectedMessages: Array<Int> = [(self.viewController?.message?.messsageID)!]
        vc.selectedMessagesIDArray = selectedMessages
        
        self.viewController?.present(vc, animated: true, completion: nil)
    }

}
