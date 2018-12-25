//
//  ChangePasswordViewController.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 25.12.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import UIKit
import AlertHelperKit
import PKHUD

class ChangePasswordViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var leftBarButtonItem       : UIBarButtonItem!
    
    @IBOutlet var currentPasswordTextField           : UITextField!
    @IBOutlet var newPasswordTextField               : UITextField!
    @IBOutlet var confirmPasswordTextField           : UITextField!
    
    @IBOutlet var currentPasswordHintLabel           : UILabel!
    @IBOutlet var newPasswordHintLabel               : UILabel!
    @IBOutlet var confirmPasswordHintLabel           : UILabel!
    
    @IBOutlet var changePasswordButton               : UIButton!
    
    @IBOutlet var currentPassEyeIconButton           : UIButton!
    @IBOutlet var newPassEyeIconButton               : UIButton!
    @IBOutlet var confirmPassEyeIconButton           : UIButton!
    
    var currentPasswordTextFieldSecure  : Bool = true
    var newPasswordTextFieldSecure      : Bool = true
    var confirmPasswordTextFieldSecure  : Bool = true
    
    var currentPassword : String = ""
    var newPassword     : String = ""
    var confirmPassword : String = ""
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var recoveryEmail : String = ""
    var apiService      : APIService?
    
    var user = UserMyself()
    
    var formatterService        : FormatterService?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.formatterService = appDelegate.applicationManager.formatterService
        self.apiService = appDelegate.applicationManager.apiService
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: k_passwordBarTintColor]
        
        self.passwordsHintLabel(show: false, sender: self.currentPasswordTextField)
        self.passwordsHintLabel(show: false, sender: self.newPasswordTextField)
        self.passwordsHintLabel(show: false, sender: self.confirmPasswordTextField)
        
        self.setupChangeButtonState()
        
        let freeSpaceViewGesture = UITapGestureRecognizer(target: self, action:  #selector(self.tappedViewAction(sender:)))
        self.view.addGestureRecognizer(freeSpaceViewGesture)
    }
    
    //MARK: - IBActions
    
    @IBAction func changeButtonPressed(_ sender: AnyObject) {
        
    }
    
    @IBAction func backButtonPressed(_ sender: AnyObject) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func currentPasswordEyeButtonPressed(_ sender: AnyObject) {
        
        self.currentPasswordTextFieldSecure = !self.currentPasswordTextFieldSecure
        
        self.currentPasswordTextField.isSecureTextEntry = self.currentPasswordTextFieldSecure
        
        var buttonImage = UIImage()
        
        if self.currentPasswordTextFieldSecure{
            buttonImage = UIImage(named: k_darkEyeOffIconImageName)!
        } else {
            buttonImage = UIImage(named: k_darkEyeOnIconImageName)!
        }
        
        self.currentPassEyeIconButton.setImage(buttonImage, for: .normal)
    }
    
    @IBAction func newPasswordEyeButtonPressed(_ sender: AnyObject) {
        
        self.newPasswordTextFieldSecure = !self.newPasswordTextFieldSecure
        
        self.newPasswordTextField.isSecureTextEntry = self.newPasswordTextFieldSecure
        
        var buttonImage = UIImage()
        
        if self.newPasswordTextFieldSecure{
            buttonImage = UIImage(named: k_darkEyeOffIconImageName)!
        } else {
            buttonImage = UIImage(named: k_darkEyeOnIconImageName)!
        }
        
        self.newPassEyeIconButton.setImage(buttonImage, for: .normal)
    }
    
    @IBAction func confirmPasswordEyeButtonPressed(_ sender: AnyObject) {
        
        self.confirmPasswordTextFieldSecure = !self.confirmPasswordTextFieldSecure
        
        self.confirmPasswordTextField.isSecureTextEntry = self.confirmPasswordTextFieldSecure
        
        var buttonImage = UIImage()
        
        if self.confirmPasswordTextFieldSecure{
            buttonImage = UIImage(named: k_darkEyeOffIconImageName)!
        } else {
            buttonImage = UIImage(named: k_darkEyeOnIconImageName)!
        }
        
        self.confirmPassEyeIconButton.setImage(buttonImage, for: .normal)
    }
    
    @IBAction func passwordTyped(_ sender: UITextField) {
        
        switch sender {
        case self.currentPasswordTextField:
            self.currentPassword = sender.text!
            break
        case self.newPasswordTextField:
            self.newPassword = sender.text!
            break
        case self.confirmPasswordTextField:
            self.confirmPassword = sender.text!
            break
        default:
            break
        }
        
        self.setupChangeButtonState()
    }
    
    @objc func tappedViewAction(sender : UITapGestureRecognizer) {
        
        self.view.endEditing(true)
    }
    
    func passwordsHintLabel(show: Bool, sender: UITextField) {
        
        switch sender {
        case self.currentPasswordTextField:
            if show {
                self.currentPasswordHintLabel.isHidden = false
                self.currentPasswordTextField.placeholder = ""
            } else {
                if !(formatterService?.validateNameLench(enteredName: (self.currentPasswordTextField.text)!))! {
                    self.currentPasswordTextField.placeholder = "currentPasswordPlaceholder".localized()
                    self.currentPasswordHintLabel.isHidden = true
                }
            }
            break
        case self.newPasswordTextField:
            if show {
                self.newPasswordHintLabel.isHidden = false
                self.newPasswordTextField.placeholder = ""
            } else {
                if !(formatterService?.validateNameLench(enteredName: (self.newPasswordTextField.text)!))! {
                    self.newPasswordTextField.placeholder = "newPasswordPlaceholder".localized()
                    self.newPasswordHintLabel.isHidden = true
                }
            }
            break
        case self.confirmPasswordTextField:
            if show {
                self.confirmPasswordHintLabel.isHidden = false
                self.confirmPasswordTextField.placeholder = ""
            } else {
                if !(formatterService?.validateNameLench(enteredName: (self.confirmPasswordTextField.text)!))! {
                    self.confirmPasswordTextField.placeholder = "confirmPasswordPlaceholder".localized()
                    self.confirmPasswordHintLabel.isHidden = true
                }
            }
            break
        default:
            break
        }
    }
    
    func setupChangeButtonState() {
        
        if ((formatterService?.passwordsMatched(choosedPassword: self.newPassword, confirmedPassword: self.confirmPassword))!) {
            print("passwords matched")
            if ((formatterService?.validatePasswordFormat(enteredPassword: self.newPassword))!) {
                if ((formatterService?.validatePasswordFormat(enteredPassword: self.currentPassword))!) {
                    self.changeButtonState(disabled: false)
                } else {
                    self.changeButtonState(disabled: true)
                }
            } else {
                print("password wrong format")
                self.changeButtonState(disabled: true)
            }
        } else {
            print("passwords not matched!!!")
            self.changeButtonState(disabled: true)
        }
    }
    
    func changeButtonState(disabled: Bool) {
        
        if disabled {
            self.changePasswordButton.isEnabled = false
            self.changePasswordButton.alpha = 0.6
        } else {
            self.changePasswordButton.isEnabled = true
            self.changePasswordButton.alpha = 1.0
        }
    }
    
    //MARK: - textField delegate
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        self.passwordsHintLabel(show: true, sender: textField)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        self.passwordsHintLabel(show: false, sender: textField)
    }
}
