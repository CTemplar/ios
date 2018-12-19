//
//  AddFolderViewController.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 19.12.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import UIKit

class AddFolderViewController: UIViewController {
    
    @IBOutlet var addButton                 : UIButton!
    
    @IBOutlet var folderNameTextField       : UITextField!    
    @IBOutlet var darkLineView              : UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    //MARK: - IBActions
    
    @IBAction func addButtonPressed(_ sender: AnyObject) {
        
    }
    
    @IBAction func cancelButtonPressed(_ sender: AnyObject) {
        
    }
    
    @IBAction func textTyped(_ sender: UITextField) {
        
       // self.setInputText(textField: sender)
    }
}
