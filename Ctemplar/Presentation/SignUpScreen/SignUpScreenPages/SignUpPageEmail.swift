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
    @IBOutlet var termsAttributedLabel   : UILabel!
    @IBOutlet var termsTextView          : UITextView!
    @IBOutlet var createAccountButton    : UIButton!
    @IBOutlet var checkBoxButton         : UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        parentSignUpPageViewController = self.parent as? SignUpPageViewController
        parentSignUpPageViewController?.presenter?.setupRecoveryEmailTextFieldAndHintLabel(childViewController: self)
        //parentSignUpPageViewController?.presenter?.pressedCheckBoxButton(childViewController: self)
        
        setupAttributesToString() 
        
        adddNotificationObserver()
        
    }
    
    func setupAttributesToString() {
        
        let attributedString = NSMutableAttributedString(string: "Please check this box if you agree to abide by our Terms and Conditions", attributes: [
            .font: UIFont(name: k_latoRegularFontName, size: 14.0)!,
            .foregroundColor: k_lightGrayColor,
            .kern: 0.0
            ])
                
        _ = attributedString.setAsLink(textToFind: "Terms and Conditions", linkURL: k_termsURL)
        _ = attributedString.setForgroundColor(textToFind: "Terms and Conditions", color: k_urlColor)
        
        termsTextView.attributedText = attributedString
        
        termsTextView.disableTextPadding()
        termsTextView.autosizeTextFont()       
    }
    
    //MARK: - IBActions
    
    @IBAction func createAccountPressed(_ sender: AnyObject) {
        
        parentSignUpPageViewController?.presenter?.createUserAccount()
    }
    
    @IBAction func backButtonPressed(_ sender: AnyObject) {
        
        parentSignUpPageViewController?.presenter?.showPreviousViewController(childViewController: self)
    }
    
    @IBAction func checkBoxButtonPressed(_ sender: AnyObject) {
        
        parentSignUpPageViewController?.presenter?.pressedCheckBoxButton(childViewController: self)
    }
    
    @IBAction func recoveryEmailTyped(_ sender: UITextField) {
        
        parentSignUpPageViewController?.recoveryEmail = sender.text
        
        parentSignUpPageViewController?.presenter?.setupRecoveryEmailTextFieldAndHintLabel(childViewController: self)
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
     
        return true
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
