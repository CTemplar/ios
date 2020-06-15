//
//  SignUpPageEmail.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 03.10.2018.
//  Copyright © 2018 CTemplar. All rights reserved.
//

import UIKit
import Utility

class SignUpPageEmailViewController: UIViewController, UITextFieldDelegate {
    
    var parentSignUpPageViewController : SignUpPageViewController?
    
    var termsBoxChecked : Bool = false
    
    @IBOutlet var recoveryEmailTextField : UITextField!
    @IBOutlet var recoveryEmailHintLabel : UILabel!
    @IBOutlet var termsAttributedLabel   : UILabel!
    @IBOutlet var termsTextView          : UITextView!
    @IBOutlet var createAccountButton    : UIButton!
    @IBOutlet var checkBoxButton         : UIButton!
    
    @IBOutlet var captchaView: UIView!
    @IBOutlet var captchaImageView: UIImageView!
    
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
            if Device.IS_IPAD {
                if UIDevice.current.orientation.isLandscape {
                    keyboardOffset = k_signUpPageKeyboardOffsetiPadExtraLarge
                } else {
                    keyboardOffset = 0.0
                }
            } else {
                keyboardOffset = k_signUpPageKeyboardOffsetSmall
            }
        }
        
        let freeSpaceViewGesture = UITapGestureRecognizer(target: self, action:  #selector(self.tappedViewAction(sender:)))
        self.view.addGestureRecognizer(freeSpaceViewGesture)
        
        adddNotificationObserver()
        
        parentSignUpPageViewController?.presenter?.interactor?.getCaptcha()
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
    
    //MARK: - Orientation
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        super.viewWillTransition(to: size, with: coordinator)
        
        if Device.IS_IPAD {
            
            self.view.endEditing(true)
            parentSignUpPageViewController?.presenter?.setPageControlFrame()
            
            if UIDevice.current.orientation.isLandscape {
                keyboardOffset = k_signUpPageKeyboardOffsetiPadExtraLarge
            } else {
                keyboardOffset = 0.0
            }
        }
    }
    
    // temp captcha
    
    func setupCaptchaView() {
        
        //captchaView = UIView(frame: self.view.frame)
        
    }
    
    @IBAction func renewCaptchPressed(_ sender: AnyObject) {
        
        parentSignUpPageViewController?.presenter?.interactor?.getCaptcha()
    }
    
    @IBAction func verifyCaptchaPressed(_ sender: AnyObject) {
        
        if let key = parentSignUpPageViewController?.captchaKey,
            let value = parentSignUpPageViewController?.captchaValue {
                parentSignUpPageViewController?.presenter?.interactor?.verifyCaptcha(key: key, value: value)
        } else {
            //show alert wrong captcha
        }
    }
    
    @IBAction func captchaTyped(_ sender: UITextField) {
        
        parentSignUpPageViewController?.captchaValue = sender.text
        print("entered captcha:", sender.text as Any)
    }
}
