//
//  WhiteBlackListsViewController.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 27.12.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import UIKit

class WhiteBlackListsViewController: UIViewController {
    
    var user = UserMyself()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func backButtonPressed(_ sender: AnyObject) {
        
        self.dismiss(animated: true, completion: nil)
    }
}
