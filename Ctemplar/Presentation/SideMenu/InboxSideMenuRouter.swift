//
//  InboxSideMenuRouter.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 22.10.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import UIKit

class InboxSideMenuRouter {
    
    var viewController: InboxSideMenuViewController?
    
    func showContactsViewController() {
        
        let storyboard: UIStoryboard = UIStoryboard(name: k_ContactsStoryboardName, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: k_ContactsViewControllerID) as! ContactsViewController
        //self.viewController?.show(vc, sender: self)
        //self.viewController?.present(vc, animated: true, completion: nil)
        self.viewController?.navigationController?.pushViewController(vc, animated: true)
    }
}
