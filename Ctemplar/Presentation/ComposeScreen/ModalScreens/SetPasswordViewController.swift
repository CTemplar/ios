//
//  SetPasswordViewController.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 03.12.2018.
//  Copyright © 2018 CTemplar. All rights reserved.
//

import Foundation
import UIKit
import Utility
import IQKeyboardManagerSwift

protocol SetPasswordDelegate {
    func applyAction(password: String, passwordHint: String, expiredTime: Int)
    func cancelAction()
}

class SetPasswordViewController: UIViewController, UITextFieldDelegate {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var formatterService: FormatterService?
    
    var delegate: SetPasswordDelegate?

    @IBOutlet weak var subtitleLabel: UILabel! {
        didSet {
            subtitleLabel.text = Strings.Scheduler.encryptForNon.localized
        }
    }
    
    @IBOutlet weak var setPasswordTextField: UITextField! {
        didSet {
            setPasswordTextField.placeholder = Strings.Scheduler.messagePassword.localized
        }
    }
    
    @IBOutlet weak var confirmPasswordTextField: UITextField! {
        didSet {
            confirmPasswordTextField.placeholder = Strings.Signup.confirmPasswordPlaceholder.localized
        }
    }
    
    @IBOutlet weak var hintPasswordTextField: UITextField! {
        didSet {
            hintPasswordTextField.placeholder = Strings.Scheduler.passwordHint.localized
        }
    }
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    @IBOutlet weak var applyBarButtonItem: UIBarButtonItem! {
        didSet {
            applyBarButtonItem.isEnabled = false
        }
    }
    
    @IBOutlet var daysTextField: UITextField!
    @IBOutlet var hoursTextField: UITextField!
    @IBOutlet var darkLineView: UIView!
    @IBOutlet var redLineView: UIView!
    @IBOutlet var passWarningLabel: UILabel!

    var keyboardOffset = 0.0
    
    var password = ""
    var confirmedPassword = ""
    var passwordHint = ""
    var days = ""
    var hours = ""

    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !IQKeyboardManager.shared.enable {
            IQKeyboardManager.shared.enable = true
        }
        
        self.formatterService = UtilityManager.shared.formatterService
        
        setPasswordTextField.delegate = self
        confirmPasswordTextField.delegate = self
        hintPasswordTextField.delegate = self
        daysTextField.delegate = self
        hoursTextField.delegate = self
        
        self.setupHints()
        
        daysTextField.text = "5"
        hoursTextField.text = "0"
        
        days = "5"
        hours = "0"
        
        navigationBar.topItem?.title = Strings.Scheduler.setPassword.localized
        
        if (Device.IS_IPHONE_5) {
            keyboardOffset = k_setPasswordKeyboardOffset
        } else {
            keyboardOffset = 0.0
        }
        
        adddNotificationObserver()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.setPasswordTextField.becomeFirstResponder()
    }
    
    //MARK: - IBActions
    
    @IBAction func applyButtonPressed(_ sender: AnyObject) {

        if self.checkExpirationTime() {
            if let daysInt = Int(self.days), let hoursInt = Int(self.hours) {
                
                let overallHours = (daysInt * 24) + hoursInt
            
                self.delegate?.applyAction(password: self.password, passwordHint: self.passwordHint, expiredTime: overallHours)
            }
            self.dismiss(animated: true, completion: nil)
        } else {
            self.showExpirationTimeAlert()
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: AnyObject) {
        
        self.delegate?.cancelAction()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func passwordTyped(_ sender: UITextField) {
        
        self.setInputText(textField: sender)
    }
    
    //MARK: - textField delegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        //self.setInputText(textField: textField)
        
        switch textField {
        case self.daysTextField:
            let char = string.cString(using: String.Encoding.utf8)
            let isBackSpace = strcmp(char, "\\b")
            if isBackSpace == -92 {
                return true
            }
            return textField.text!.count <= 0
        case self.hoursTextField:
            let char = string.cString(using: String.Encoding.utf8)
            let isBackSpace = strcmp(char, "\\b")
            if isBackSpace == -92 {
                return true
            }
            return textField.text!.count <= 1
        default:
            break
        }

        self.setInputText(textField: textField)
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        //print("textFieldDidBeginEditing:", textField.text as Any)
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
        case self.setPasswordTextField:
            self.password = textField.text!
            break
        case self.confirmPasswordTextField:
            self.confirmedPassword = textField.text!
            break
        case self.hintPasswordTextField:
            self.passwordHint = textField.text!
            break
        case self.daysTextField:
            self.days = textField.text!
            break
        case self.hoursTextField:
            self.hours = textField.text!
            break
        default:
            break
        }
        
        self.setupHints()
    }
    
    func setUnderlines(textField: UITextField) {
        
        switch textField {
        case self.setPasswordTextField:
            self.darkLineView.isHidden = false
            self.redLineView.isHidden = true
            break
        case self.confirmPasswordTextField:
            self.darkLineView.isHidden = true
            self.redLineView.isHidden = false
            break
        case self.hintPasswordTextField:
            self.darkLineView.isHidden = true
            self.redLineView.isHidden = true
            break
        default:
            break
        }
    }
    
    func setupHints() {
        
        self.redLineView.backgroundColor = .label
        
        var passwordMatched: Bool = false
        
        if (self.formatterService?.validatePasswordLench(enteredPassword: self.password))! {
            if (self.formatterService?.comparePasswordsLench(enteredPassword: self.confirmedPassword, password: self.password))! {
                if (self.formatterService?.passwordsMatched(choosedPassword: self.password, confirmedPassword: self.confirmedPassword))! {
                    self.passWarningLabel.isHidden = true
                    passwordMatched = true
                } else {
                    self.passWarningLabel.isHidden = false
                    self.redLineView.backgroundColor = k_redColor
                }
            } else {
                self.passWarningLabel.isHidden = true
            }
        } else {
            self.passWarningLabel.isHidden = true
        }
        
        //if (self.formatterService?.validatePasswordLench(enteredPassword: self.passwordHint))! {
            if passwordMatched {
                self.setApplyButton(enabled: true)
            } else {
                self.setApplyButton(enabled: false)
            }
        //} else {
        //    self.setApplyButton(enabel: false)
        //}
    }
    
    func setApplyButton(enabled: Bool) {
        
        if enabled {
            applyBarButtonItem.isEnabled = true
        } else {
            applyBarButtonItem.isEnabled = false
        }
    }
    
    func checkExpirationTime() -> Bool {
        
        if let daysInt = Int(self.days), let hoursInt = Int(self.hours) {
        
            let overallHours = (daysInt * 24) + hoursInt
        
            if overallHours <= 120 && overallHours > 0 {
                return true
            }
        }
        
        return false
    }
    
    func showExpirationTimeAlert() {
        showAlert(with: "Info:".localized(),
                  message: "expireTimeAlert".localized(),
                  buttonTitle: Strings.Button.closeButton.localized)
    }
    
    @objc func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
        
        if gesture.direction == UISwipeGestureRecognizer.Direction.down {
            self.delegate?.cancelAction()
            self.dismiss(animated: true, completion: nil)
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
