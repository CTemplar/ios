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
    
    var presenter   : AddContactPresenter?
    var router      : AddContactRouter?
    
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
    
    var keyboardOffset = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let configurator =  AddContactConfigurator()
        configurator.configure(viewController: self)
        
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        self.navigationItem.rightBarButtonItem = nil
        self.navigationItem.title = navBarTitle
        
        if (Device.IS_IPHONE_5) {
            keyboardOffset = k_signUpPageKeyboardOffsetLarge
        } else {
            keyboardOffset = 0.0
        }
        
        let freeSpaceViewGesture = UITapGestureRecognizer(target: self, action:  #selector(self.tappedViewAction(sender:)))
        self.view.addGestureRecognizer(freeSpaceViewGesture)
        
        adddNotificationObserver()
    }
    
    //MARK: - IBActions
    
    @IBAction func cancelButtonPressed(_ sender: AnyObject) {
    
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func saveButtonPressed(_ sender: AnyObject) {
  
    }
    
    @IBAction func textFieldTyped(_ sender: UITextField) {
        
//        print("typed:", sender.text as Any)
        presenter?.setInputs(sender: sender)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        //print("input:", textField.text as Any)
    }
    
    @objc func tappedViewAction(sender : UITapGestureRecognizer) {
        
        view.endEditing(true)
    }
    
    //MARK: - notification
    
    func adddNotificationObserver() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        
        if contactNoteTextField.isEditing {
        
            if (Device.IS_IPHONE_5) {
                keyboardOffset = k_signUpPageKeyboardOffsetExtraLarge
            } else {
                keyboardOffset = k_signUpPageKeyboardOffsetLarge
            }
        }
        
        if contactAddressTextField.isEditing {
            
            if (Device.IS_IPHONE_5) {
                keyboardOffset = k_signUpPageKeyboardOffsetExtraLarge
            } else {
                keyboardOffset = k_signUpPageKeyboardOffsetMedium
            }
        }
        
        if contactPhoneTextField.isEditing || contactAddressTextField.isEditing || contactNoteTextField.isEditing {
        
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= CGFloat(keyboardOffset)
            }
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y += CGFloat(keyboardOffset)
        }
    }
}
