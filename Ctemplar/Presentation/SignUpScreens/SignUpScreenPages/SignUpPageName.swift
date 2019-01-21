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
    
    var keyboardOffset = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        parentSignUpPageViewController = self.parent as? SignUpPageViewController        
        parentSignUpPageViewController?.presenter?.setupUsernamePageNextButtonState(childViewController: self)
        parentSignUpPageViewController?.presenter?.userNameHintLabel(show: false, childViewController: self)
        
        if (Device.IS_IPHONE_5) {
            keyboardOffset = k_signUpPageKeyboardOffsetBig
        } else {
            if Device.IS_IPAD {
                if UIDevice.current.orientation.isLandscape {
                    keyboardOffset = k_signUpPageKeyboardOffsetiPadBig
                } else {
                    keyboardOffset = 0.0
                }
            } else {
                keyboardOffset = 0.0
            }
        }
        
        let freeSpaceViewGesture = UITapGestureRecognizer(target: self, action:  #selector(self.tappedViewAction(sender:)))
        self.view.addGestureRecognizer(freeSpaceViewGesture)
        
        adddNotificationObserver()
    }
    
    //MARK: - IBActions
    
    @IBAction func nextButtonPressed(_ sender: AnyObject) {
        
        parentSignUpPageViewController?.presenter?.pressedNextButton(childViewController: self)
    }
    
    @IBAction func backButtonPressed(_ sender: AnyObject) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func userNameTyped(_ sender: UITextField) {
        
        parentSignUpPageViewController?.userName = sender.text
        parentSignUpPageViewController?.presenter?.setupUsernamePageNextButtonState(childViewController: self)
    }
    
    @objc func tappedViewAction(sender : UITapGestureRecognizer) {
        
        view.endEditing(true)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        parentSignUpPageViewController?.presenter?.userNameHintLabel(show: true, childViewController: self)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        parentSignUpPageViewController?.presenter?.userNameHintLabel(show: false, childViewController: self)
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
        
        if (Device.IS_IPAD) {
            
            userNameTextField.resignFirstResponder()
            parentSignUpPageViewController?.presenter?.setPageControlFrame()
            
            if UIDevice.current.orientation.isLandscape {
                keyboardOffset = k_signUpPageKeyboardOffsetiPadBig                
            } else {
                keyboardOffset = 0.0
            }
        }
    }
}
