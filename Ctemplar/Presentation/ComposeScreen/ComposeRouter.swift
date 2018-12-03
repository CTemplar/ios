//
//  ComposeRouter.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 27.11.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import UIKit


class ComposeRouter {
    
    var viewController: ComposeViewController?
    
    func showSetPasswordViewController() {
        
        let storyboard: UIStoryboard = UIStoryboard(name: k_SetPasswordStoryboardName, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: k_SetPasswordViewControllerID) as! SetPasswordViewController
        self.viewController?.present(vc, animated: true, completion: nil)
    }
}
