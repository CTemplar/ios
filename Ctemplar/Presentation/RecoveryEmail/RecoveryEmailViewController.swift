//
//  RecoveryEmailViewController.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 24.12.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import UIKit

class RecoveryEmailViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
            self.setupRightBarButton()
    }
    
    @IBAction func cancelButtonPressed(_ sender: AnyObject) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButtonPressed(_ sender: AnyObject) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func setupRightBarButton() {
        
        self.navigationItem.rightBarButtonItem = nil
    }
}
