//
//  AddContactToWhiteBlackListViewController.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 28.12.2018.
//  Copyright © 2018 CTemplar. All rights reserved.
//

import Foundation
import UIKit
import Utility

protocol AddContactToWhiteBlackListDelegate {
    func addAction(name: String, email: String)
}

class AddContactToWhiteBlackListViewController: UIViewController, UITextFieldDelegate {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var formatterService : FormatterService?

    @IBOutlet var addButton          : UIButton!
    
    @IBOutlet var nameTextField      : UITextField!
    @IBOutlet var emailTextField     : UITextField!
    
    @IBOutlet var nameDarkLineView              : UIView!
    @IBOutlet var emailDarkLineView             : UIView!
    
    var name        : String = ""
    var email       : String = ""
    
    var delegate    : AddContactToWhiteBlackListDelegate?
    var mode: WhiteBlackListsMode!
    
    var keyboardOffset = 0.0
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.formatterService = UtilityManager.shared.formatterService
        
        self.nameTextField.delegate = self
        self.emailTextField.delegate = self
        
        self.setupHints()
        
        let swipeDownGesture = UISwipeGestureRecognizer(target: self, action: #selector(self.handleGesture(gesture:)))
        swipeDownGesture.direction = .down
        self.view.addGestureRecognizer(swipeDownGesture)
        
        if (Device.IS_IPHONE_5) {
            keyboardOffset = k_addContactKeyboardOffset
        } else {
            keyboardOffset = 0.0
        }
        
        adddNotificationObserver()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.nameTextField.becomeFirstResponder()
    }
    
    //MARK: - IBActions
    
    @IBAction func addButtonPressed(_ sender: AnyObject) {
        
        self.delegate?.addAction(name: self.name, email: self.email)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelButtonPressed(_ sender: AnyObject) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
        
        if gesture.direction == UISwipeGestureRecognizer.Direction.down {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    //MARK: - textField delegate
    
    @IBAction func textTyped(_ sender: UITextField) {
        
        self.setInputText(textField: sender)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        self.setInputText(textField: textField)
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        self.setInputText(textField: textField)
        
        self.setUnderlines(textField: textField)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        self.setInputText(textField: textField)
        // print("textFieldDidEndEditing:", textField.text!)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        self.view.endEditing(true)
        //textField.resignFirstResponder()
        return true
    }
    
    func setInputText(textField: UITextField) {
        
        switch textField {
        case self.nameTextField:
            self.name = textField.text!
            break
        case self.emailTextField:
            self.email = textField.text!
            break

        default:
            break
        }
        
        print("typed:", textField.text!)
        
        self.setupHints()
    }
    
    func setUnderlines(textField: UITextField) {
        
        switch textField {
        case self.nameTextField:
            self.nameDarkLineView.isHidden = false
            self.emailDarkLineView.isHidden = true
            break
        case self.emailTextField:
            self.nameDarkLineView.isHidden = true
            self.emailDarkLineView.isHidden = false
            break
        default:
            break
        }
    }
    
    func setupHints() {
        
        self.nameDarkLineView.backgroundColor = k_sideMenuColor
        self.emailDarkLineView.backgroundColor = k_sideMenuColor
        
        var enabledAddButton: Bool = false
        
        if (self.formatterService?.validateNameLench(enteredName: self.name))! {
            if (self.formatterService?.validateEmailFormat(enteredEmail: self.email))! {
                enabledAddButton = true
            } else {
                enabledAddButton = false
            }
        } else {
            enabledAddButton = false
        }
        
        self.setApplyButton(enable: enabledAddButton)
    }
    
    func setApplyButton(enable: Bool) {
        
        if enable {
            self.addButton.isEnabled = true
            self.addButton.alpha = 1.0
        } else {
            self.addButton.isEnabled = false
            self.addButton.alpha = 0.6
        }
    }
    
    //MARK: - notification
    
    func adddNotificationObserver() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        
        if self.view.frame.origin.y == 0 {
            self.view.frame.origin.y -= CGFloat(keyboardOffset)
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y += CGFloat(keyboardOffset)
        }
    }
}
