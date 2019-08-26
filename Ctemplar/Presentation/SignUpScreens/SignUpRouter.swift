//
//  SignUpRouter.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 03.10.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import UIKit

class SignUpRouter {
    
    var viewController: SignUpPageViewController?
    
    func showInboxScreen() {
        
        let currentPresentingViewController = self.viewController?.presentingViewController as? LoginViewController
        
        self.viewController?.dismiss(animated: true) {
            
            currentPresentingViewController?.dismiss(animated: true, completion: {
                
                self.viewController?.mainViewController?.setAutoUpdaterTimer()
                
                if (!Device.IS_IPAD) {
                    self.viewController?.mainViewController?.showInboxNavigationController()
                } else {
                    self.viewController?.mainViewController?.showSplitViewController()
                }
            })
        }
    }
}
