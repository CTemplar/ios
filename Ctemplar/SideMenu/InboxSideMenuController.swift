//
//  InboxSideMenuController.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 12.10.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation

import UIKit

class InboxSideMenuController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.view.backgroundColor = k_sideMenuColor
        
        self.navigationController?.navigationBar.isHidden = true
        
    }
}
