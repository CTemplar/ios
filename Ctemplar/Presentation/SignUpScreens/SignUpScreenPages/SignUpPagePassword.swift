//
//  SignUpPagePassword.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 03.10.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import UIKit

class SignUpPagePasswordViewController: UIViewController, UITextFieldDelegate {
    
    var parentSignUpPageViewController : SignUpPageViewController?
    
    var choosePasswordTextFieldSecure   : Bool = true
    var confirmPasswordTextFieldSecure  : Bool = true
    
    var choosedPassword                 : String? = ""
    var confirmedPassword               : String? = ""
    
    @IBOutlet var choosePasswordTextField   : UITextField!
    @IBOutlet var confirmPasswordTextField  : UITextField!
    
    @IBOutlet var choosePasswordHintLabel   : UILabel!
    @IBOutlet var confirmPasswordHintLabel  : UILabel!
    
    @IBOutlet var nextButton                : UIButton!
    
    @IBOutlet var choosePassEyeIconButton   : UIButton!
    @IBOutlet var confirmPassEyeIconButton  : UIButton!
    
    var keyboardOffset = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        parentSignUpPageViewController = self.parent as? SignUpPageViewController
        parentSignUpPageViewController?.presenter?.setupPasswordsNextButtonState(childViewController: self, sender: choosePasswordTextField)
        parentSignUpPageViewController?.presenter?.setupPasswordsNextButtonState(childViewController: self, sender: confirmPasswordTextField)
        
        parentSignUpPageViewController?.presenter?.passwordsHintLabel(show: false, sender: choosePasswordTextField, childViewController: self)
        parentSignUpPageViewController?.presenter?.passwordsHintLabel(show: false, sender: confirmPasswordTextField, childViewController: self)
        
        if Device.IS_IPHONE_5 {
            keyboardOffset = k_signUpPageKeyboardOffsetLarge        
        } else {
            keyboardOffset = k_signUpPageKeyboardOffsetBig
        }
        
        let freeSpaceViewGesture = UITapGestureRecognizer(target: self, action:  #selector(self.tappedViewAction(sender:)))
        self.view.addGestureRecognizer(freeSpaceViewGesture)
        
        adddNotificationObserver()  
    }
    
    //MARK: - IBActions
    
    @IBAction func nextButtonPressed(_ sender: AnyObject) {
        
        parentSignUpPageViewController?.presenter?.showNextViewController(childViewController: self)
    }
    
    @IBAction func backButtonPressed(_ sender: AnyObject) {
        
        parentSignUpPageViewController?.presenter?.showPreviousViewController(childViewController: self)
    }
    
    @IBAction func choosePasswordEyeButtonPressed(_ sender: AnyObject) {
        
        choosePasswordTextFieldSecure = !choosePasswordTextFieldSecure
        choosePasswordTextField.isSecureTextEntry = choosePasswordTextFieldSecure
        
        var buttonImage = UIImage()
        
        if choosePasswordTextFieldSecure {
            buttonImage = UIImage(named: k_darkEyeOffIconImageName)!
        } else {
            buttonImage = UIImage(named: k_darkEyeOnIconImageName)!
        }
        
        choosePassEyeIconButton.setImage(buttonImage, for: .normal)
    }
    
    @IBAction func confirmPasswordEyeButtonPressed(_ sender: AnyObject) {
        
        confirmPasswordTextFieldSecure = !confirmPasswordTextFieldSecure
        confirmPasswordTextField.isSecureTextEntry = confirmPasswordTextFieldSecure
        
        var buttonImage = UIImage()
        
        if confirmPasswordTextFieldSecure {
            buttonImage = UIImage(named: k_darkEyeOffIconImageName)!
        } else {
            buttonImage = UIImage(named: k_darkEyeOnIconImageName)!
        }
        
        confirmPassEyeIconButton.setImage(buttonImage, for: .normal)
    }
    
    @IBAction func passwordTyped(_ sender: UITextField) {
        
        parentSignUpPageViewController?.presenter?.setupPasswordsNextButtonState(childViewController: self, sender: sender)
    }
    
    @objc func tappedViewAction(sender : UITapGestureRecognizer) {
        
        view.endEditing(true)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        parentSignUpPageViewController?.presenter?.passwordsHintLabel(show: true, sender: textField, childViewController: self)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        parentSignUpPageViewController?.presenter?.passwordsHintLabel(show: false, sender: textField, childViewController: self)
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
