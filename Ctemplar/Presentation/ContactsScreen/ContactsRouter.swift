//
//  ContactsRouter.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 14.11.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import UIKit
import SideMenu

class ContactsRouter {
    
    var viewController: ContactsViewController?
    
    func showInboxSideMenu() {
          
        if (!Device.IS_IPAD) {
            self.viewController?.present(SideMenuManager.default.menuLeftNavigationController!, animated: true, completion: nil)
        } else {
            self.viewController?.splitViewController?.toggleMasterView()
        }
    }
    
    func showAddContactViewController(editMode: Bool, contact: Contact, contactsEncrypted: Bool) {
        
        let storyboard: UIStoryboard = UIStoryboard(name: k_AddContactStoryboardName, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: k_AddContactViewControllerID) as! AddContactViewController
        vc.editMode = editMode
        vc.contact = contact
        vc.contactsEncrypted = contactsEncrypted
        self.viewController?.show(vc, sender: self)        
    }
}
