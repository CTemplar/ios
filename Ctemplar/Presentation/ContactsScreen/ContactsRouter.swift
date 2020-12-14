//
//  ContactsRouter.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 14.11.2018.
//  Copyright © 2018 CTemplar. All rights reserved.
//

import Foundation
import UIKit
import Networking
import SideMenu

class ContactsRouter {
    
    var viewController: ContactsViewController?
    
    func showInboxSideMenu() {
        viewController?.sideMenuController?.revealMenu()
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
