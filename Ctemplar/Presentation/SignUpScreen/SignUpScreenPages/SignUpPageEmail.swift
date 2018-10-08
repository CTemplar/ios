//
//  SignUpPageEmail.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 03.10.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import UIKit

class SignUpPageEmailViewController: UIViewController, UITextFieldDelegate {
    
    var parentSignUpPageViewController : SignUpPageViewController?
    
    var termsBoxChecked : Bool = false
    
    @IBOutlet var recoveryEmailTextField : UITextField!
    @IBOutlet var recoveryEmailHintLabel : UILabel!
    @IBOutlet var createAccountButton    : UIButton!
    @IBOutlet var checkBoxButton         : UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        parentSignUpPageViewController = self.parent as? SignUpPageViewController
        parentSignUpPageViewController?.presenter?.setupRecoveryEmailTextFieldAndHintLabel(childViewController: self)
        //parentSignUpPageViewController?.presenter?.pressedCheckBoxButton(childViewController: self)
        
        adddNotificationObserver()
        
    }
    
    //MARK: - IBActions
    
    @IBAction func createAccountPressed(_ sender: AnyObject) {
        
        parentSignUpPageViewController?.presenter?.createUserAccount()
    }
    
    @IBAction func backButtonPressed(_ sender: AnyObject) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func checkBoxButtonPressed(_ sender: AnyObject) {
        
        parentSignUpPageViewController?.presenter?.pressedCheckBoxButton(childViewController: self)
    }
    
    @IBAction func recoveryEmailTyped(_ sender: UITextField) {
        
        parentSignUpPageViewController?.recoveryEmail = sender.text
        
        parentSignUpPageViewController?.presenter?.setupRecoveryEmailTextFieldAndHintLabel(childViewController: self)
    }
    
    //MARK: - notification
    
    func adddNotificationObserver() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(SignUpPageNameViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SignUpPageNameViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        
        if self.view.frame.origin.y == 0 {
            self.view.frame.origin.y -= CGFloat(k_signUpPageNameKeyboardHeight)//keyboardSize.height
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y += CGFloat(k_signUpPageNameKeyboardHeight)//keyboardSize.height
        }
    }
}
