//
//  ContactsViewController.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 14.11.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import UIKit
import SideMenu


class ContactsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
        
    //MARK: - IBActions
    
    @IBAction func menuButtonPressed(_ sender: AnyObject) {
        
        self.showInboxSideMenu()
        //self.dismiss(animated: true, completion: nil)
        //self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func addContactButtonPressed(_ sender: AnyObject) {
        
       
    }
    
    func showInboxSideMenu() {
        
        //self.viewController?.inboxSideMenuViewController?.currentParentViewController = self.viewController
        let inboxSideMenuViewController = SideMenuManager.default.menuLeftNavigationController?.children.first as! InboxSideMenuViewController
        inboxSideMenuViewController.currentParentViewController = self
        self.present(SideMenuManager.default.menuLeftNavigationController!, animated: true, completion: nil)
    }
}
