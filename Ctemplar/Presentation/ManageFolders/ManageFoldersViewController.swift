//
//  ManageFoldersViewController.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 17.12.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import UIKit
import SideMenu

class ManageFoldersViewController: UIViewController {
    
    @IBOutlet var leftBarButtonItem     : UIBarButtonItem!
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    //MARK: - IBActions
    
    @IBAction func menuButtonPressed(_ sender: AnyObject) {
        
        //self.router?.showInboxSideMenu()
        self.present(SideMenuManager.default.menuLeftNavigationController!, animated: true, completion: nil)
    }
    
}
