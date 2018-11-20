//
//  AddContactScreenViewController.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 20.11.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import UIKit

class AddContactViewController: UIViewController, UITextFieldDelegate {
    
    var navBarTitle: String? = ""
    
    var contactName     : String? = ""
    var contactEmail    : String? = ""
    var contactPhone    : String? = ""
    var contactAddress  : String? = ""
    var contactNote     : String? = ""
    
    @IBOutlet var contactNameTextField      : UITextField!
    @IBOutlet var contactEmailTextField     : UITextField!
    @IBOutlet var contactPhoneTextField     : UITextField!
    @IBOutlet var contactAddressTextField   : UITextField!
    @IBOutlet var contactNoteTextField      : UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        self.navigationItem.rightBarButtonItem = nil
        self.navigationItem.title = navBarTitle
    }
    
    //MARK: - IBActions
    
    @IBAction func cancelButtonPressed(_ sender: AnyObject) {
    
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func saveButtonPressed(_ sender: AnyObject) {
  
    }
    
    @IBAction func textFieldTyped(_ sender: UITextField) {
        
        print("typed:", sender.text as Any)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        //print("input:", textField.text as Any)
    }
}
