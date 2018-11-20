//
//  AddContactScreenViewController.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 20.11.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import UIKit

class AddContactViewController: UIViewController {
    
    var navBarTitle: String? = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        self.navigationItem.title = navBarTitle
    }
    
    //MARK: - IBActions
    
    @IBAction func cancelButtonPressed(_ sender: AnyObject) {
    
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func saveButtonPressed(_ sender: AnyObject) {
  
    }
}
