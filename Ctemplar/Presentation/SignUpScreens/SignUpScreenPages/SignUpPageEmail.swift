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
    
    var keyboardOffset = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        parentSignUpPageViewController = self.parent as? SignUpPageViewController
        parentSignUpPageViewController?.presenter?.setupRecoveryEmailNextButtonState(childViewController: self)
        //parentSignUpPageViewController?.presenter?.pressedCheckBoxButton(childViewController: self)
        
        parentSignUpPageViewController?.presenter?.recoveryEmailHintLabel(show: false, childViewController: self)
        
        setupAttributesForTextView()
        
        if Device.IS_IPHONE_5 {
            keyboardOffset = k_signUpPageKeyboardOffsetLarge
        } else if Device.IS_IPHONE_6 {
            keyboardOffset = k_signUpPageKeyboardOffsetMedium
        } else {
            keyboardOffset = k_signUpPageKeyboardOffsetSmall
        }
        
        let freeSpaceViewGesture = UITapGestureRecognizer(target: self, action:  #selector(self.tappedViewAction(sender:)))
        self.view.addGestureRecognizer(freeSpaceViewGesture)
        
        adddNotificationObserver()
    }
    
    func setupAttributesForTextView() {
        
        let attributedString = NSMutableAttributedString(string: "termsAndConditionsFullText".localized(), attributes: [
            .font: UIFont(name: k_latoRegularFontName, size: 14.0)!,
            .foregroundColor: k_lightGrayColor,
            .kern: 0.0
            ])
                
        _ = attributedString.setAsLink(textToFind: "termsAndConditionsPhrase".localized(), linkURL: k_termsURL)
        _ = attributedString.setForgroundColor(textToFind: "termsAndConditionsPhrase".localized(), color: k_urlColor)
        
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
        
        parentSignUpPageViewController?.presenter?.setupRecoveryEmailNextButtonState(childViewController: self)
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
     
        return true
    }
    
    @objc func tappedViewAction(sender : UITapGestureRecognizer) {
        
        view.endEditing(true)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        parentSignUpPageViewController?.presenter?.recoveryEmailHintLabel(show: true, childViewController: self)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        parentSignUpPageViewController?.presenter?.recoveryEmailHintLabel(show: false, childViewController: self)
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
