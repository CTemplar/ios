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
        
        //let dollarSign = "\u{24}"        // $,  Unicode scalar U+0024
        //U+25BD white triangle and  U+25B3  // \u{25BD}
        
        //self.view.backgroundColor = k_sideMenuColor
        
        self.navigationController?.navigationBar.isHidden = true
        
    }
}
