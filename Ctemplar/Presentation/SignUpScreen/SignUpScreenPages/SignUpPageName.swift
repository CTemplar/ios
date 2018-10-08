//
//  SignUpPageName.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 03.10.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import UIKit

class SignUpPageNameViewController: UIViewController, UITextFieldDelegate {
    
    var parentSignUpPageViewController : SignUpPageViewController?
    
    var userName    : String? = ""
    
    @IBOutlet var userNameTextField : UITextField!
    @IBOutlet var userNameHintLabel : UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        parentSignUpPageViewController = self.parent as? SignUpPageViewController
        parentSignUpPageViewController?.presenter?.setupNameTextFieldsAndHintLabel(childViewController: self)
    }
    
    //MARK: - IBActions
    
    @IBAction func nextButtonPressed(_ sender: AnyObject) {
        
         parentSignUpPageViewController?.presenter?.nextViewController(childViewController: self)
    }
    
    @IBAction func backButtonPressed(_ sender: AnyObject) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func userNameTyped(_ sender: UITextField) {
        
        userName = sender.text
    
        parentSignUpPageViewController?.presenter?.setupNameTextFieldsAndHintLabel(childViewController: self)
    }
}
