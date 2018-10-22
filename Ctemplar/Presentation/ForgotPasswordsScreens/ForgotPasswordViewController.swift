//
//  ForgotPasswordViewController.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 15.10.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import UIKit

class ForgotPasswordViewController: UIViewController, UITextFieldDelegate {
    
    var configurator: ForgotPasswordConfigurator?
    
    var userName        : String? = ""
    var recoveryEmail   : String? = ""
    
    @IBOutlet var userNameTextField          : UITextField!
    @IBOutlet var recoveryEmailTextField     : UITextField!
    
    @IBOutlet var userNameHintLabel          : UILabel!
    @IBOutlet var recoveryEmailHintLabel     : UILabel!
    
    var keyboardOffset = 0.0
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configurator = ForgotPasswordConfigurator()
        self.configurator?.configure(viewController: self)
        
        self.configurator?.presenter?.setupUserNameTextFieldsAndHintLabel(userName: userName!)
        self.configurator?.presenter?.setupRecoveryTextFieldsAndHintLabel(email: recoveryEmail!)
        
        if (Device.IS_IPHONE_5) {
            keyboardOffset = k_signUpPageKeyboardOffsetMedium
        } else {
            keyboardOffset = 0.0
        }
        
        adddNotificationObserver()
    }
    
    //MARK: - IBActions
    
    @IBAction func backButtonPressed(_ sender: AnyObject) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func resetButtonPressed(_ sender: AnyObject) {
        
        //self.configurator?.router?.showConfirmResetPasswordViewController(userName: userName!, recoveryEmail: recoveryEmail!)
        self.configurator?.presenter?.buttonResetPasswordPressed(userName: userName!, recoveryEmail: recoveryEmail!)
    }
    
    @IBAction func forgotUsernameButtonPressed(_ sender: AnyObject) {
        
        self.configurator?.router?.showForgotUsernameViewController()
    }
    
    @IBAction func userNameTyped(_ sender: UITextField) {
        
        userName = sender.text
        self.configurator?.presenter?.setupUserNameTextFieldsAndHintLabel(userName: userName!)
    }
    
    @IBAction func recoveryEmailTyped(_ sender: UITextField) {
        
        recoveryEmail = sender.text
        self.configurator?.presenter?.setupRecoveryTextFieldsAndHintLabel(email: recoveryEmail!)
    }
    
    //MARK: - notification
    
    func adddNotificationObserver() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(SignUpPageNameViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SignUpPageNameViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
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
