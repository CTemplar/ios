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
    
    //var userName    : String? = ""
    
    @IBOutlet var userNameTextField : UITextField!
    @IBOutlet var userNameHintLabel : UILabel!
    @IBOutlet var nextButton        : UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        parentSignUpPageViewController = self.parent as? SignUpPageViewController
        parentSignUpPageViewController?.presenter?.setupNameTextFieldAndHintLabel(childViewController: self)
        
        adddNotificationObserver()
    }
    
    //MARK: - IBActions
    
    @IBAction func nextButtonPressed(_ sender: AnyObject) {
        
         //parentSignUpPageViewController?.presenter?.nextViewController(childViewController: self)
        parentSignUpPageViewController?.presenter?.pressedNextButton(childViewController: self)
    }
    
    @IBAction func backButtonPressed(_ sender: AnyObject) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func userNameTyped(_ sender: UITextField) {
        
        parentSignUpPageViewController?.userName = sender.text
    
        parentSignUpPageViewController?.presenter?.setupNameTextFieldAndHintLabel(childViewController: self)
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
