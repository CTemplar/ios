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
    
    var choosedPassword       : String? = ""
    var confirmedPassword     : String? = ""
    
    @IBOutlet var choosePasswordTextField   : UITextField!
    @IBOutlet var confirmPasswordTextField  : UITextField!
    
    @IBOutlet var choosePasswordHintLabel   : UILabel!
    @IBOutlet var confirmPasswordHintLabel  : UILabel!
    
    @IBOutlet var nextButton                : UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        parentSignUpPageViewController = self.parent as? SignUpPageViewController
        parentSignUpPageViewController?.presenter?.setupPasswordTextFieldsAndHintLabels(childViewController: self, sender: choosePasswordTextField)
        parentSignUpPageViewController?.presenter?.setupPasswordTextFieldsAndHintLabels(childViewController: self, sender: confirmPasswordTextField)
        
        adddNotificationObserver()
    }
    
    //MARK: - IBActions
    
    @IBAction func nextButtonPressed(_ sender: AnyObject) {
        
        parentSignUpPageViewController?.presenter?.nextViewController(childViewController: self)
    }
    
    @IBAction func backButtonPressed(_ sender: AnyObject) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func passwordTyped(_ sender: UITextField) {
        
        parentSignUpPageViewController?.presenter?.setupPasswordTextFieldsAndHintLabels(childViewController: self, sender: sender)
    }
    
    //MARK: - notification
    
    func adddNotificationObserver() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(SignUpPageNameViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SignUpPageNameViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
        
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0 {
                self.view.frame.origin.y += keyboardSize.height
            }
        }
    }
}
