//
//  LoginViewController.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 02.10.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import UIKit
import Foundation

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    var mainViewController: MainViewController?
    
    var passwordTextFieldSecure   : Bool = true
    
    var presenter   : LoginPresenter?
    var router      : LoginRouter?
    
    var userEmail   : String? = ""
    var password    : String? = ""
    var twoFAcode   : String? = ""
    
    @IBOutlet var userNameTextField     : UITextField!
    @IBOutlet var passwordTextField     : UITextField!
    @IBOutlet var otpTextField          : UITextField!
    
    @IBOutlet var emailHintLabel        : UILabel!
    @IBOutlet var passwordHintLabel     : UILabel!
    
    @IBOutlet var eyeButton             : UIButton!
    
    @IBOutlet var passwordBlockView     : UIView!
    @IBOutlet var otpBlockView          : UIView!
    
    var keyboardOffset = 0.0
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let configurator = LoginConfigurator()
        configurator.configure(viewController: self)
        
        passwordBlockView.isHidden = false
        otpBlockView.isHidden = true
        
        presenter!.setupEmailTextFieldsAndHintLabel(userEmail: userEmail!)
        presenter!.setupPasswordTextFieldsAndHintLabel(password: password!)
        
        presenter!.hintLabel(show: false, sender: userNameTextField)
        presenter!.hintLabel(show: false, sender: passwordTextField)
        
        userNameTextField.delegate = self
        passwordTextField.delegate = self
        //otpTextField.delegate = self
        
        otpTextField.placeholder = "twoFAPlaceholder".localized()
        
        if (Device.IS_IPAD) {

            if UIDevice.current.orientation.isLandscape {
                keyboardOffset = k_signUpPageKeyboardOffsetiPadLarge
            } else {
                keyboardOffset = 0.0
            }
        }
        
        let freeSpaceViewGesture = UITapGestureRecognizer(target: self, action:  #selector(self.tappedViewAction(sender:)))
        self.view.addGestureRecognizer(freeSpaceViewGesture)
        
        adddNotificationObserver()
    }
    
    //MARK: - IBActions
    
    @IBAction func loginButtonPressed(_ sender: AnyObject) {
        
        self.presenter?.buttonLoginPressed(userEmail: userEmail!, password: password!, twoFAcode: twoFAcode!)
    }
    
    @IBAction func forgotPasswordButtonPressed(_ sender: AnyObject) {
        
        self.router?.showForgotPasswordViewController()
    }
    
    @IBAction func createAccountButtonPressed(_ sender: AnyObject) {
        
        self.presenter?.buttonCreateAccountPressed()
    }
    
    @IBAction func userEmailTyped(_ sender: UITextField) {
        
        userEmail = sender.text
        //presenter!.setupEmailTextFieldsAndHintLabel(userEmail: userEmail!)
    }
    
    @IBAction func passwordEyeButtonPressed(_ sender: AnyObject) {
        
        passwordTextFieldSecure = !passwordTextFieldSecure
        passwordTextField.isSecureTextEntry = passwordTextFieldSecure
        
        var buttonImage = UIImage()
        
        if passwordTextFieldSecure {
            buttonImage = UIImage(named: k_eyeOffIconImageName)!
        } else {
            buttonImage = UIImage(named: k_eyeOnIconImageName)!
        }
        
        eyeButton.setImage(buttonImage, for: .normal)
    }
    
    @IBAction func passwordTyped(_ sender: UITextField) {
        
        password = sender.text
        //presenter!.setupPasswordTextFieldsAndHintLabel(password: password!)
    }
    
    @IBAction func otpTyped(_ sender: UITextField) {
        
        twoFAcode = sender.text
    }
    
    @objc func tappedViewAction(sender : UITapGestureRecognizer) {
        
        view.endEditing(true)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        presenter!.hintLabel(show: true, sender: textField)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        presenter!.hintLabel(show: false, sender: textField)
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
            
            self.view.endEditing(true)
            
            if UIDevice.current.orientation.isLandscape {
                keyboardOffset = k_signUpPageKeyboardOffsetiPadLarge
            } else {
                keyboardOffset = 0.0
            }
        }
    }
}
