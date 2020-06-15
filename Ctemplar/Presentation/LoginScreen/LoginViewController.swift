//
//  LoginViewController.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 02.10.2018.
//  Copyright © 2018 CTemplar. All rights reserved.
//

import UIKit
import Foundation

class LoginViewController: UIViewController, UITextFieldDelegate {
    
//    var mainViewController: MainViewController?
    
    var passwordTextFieldSecure   : Bool = true
    
    var presenter   : LoginPresenter?
    var router      : LoginRouter?
    
    var userEmail   : String? = ""
    var password    : String? = ""
    var twoFAcode   : String? = ""
    
    @IBOutlet weak var userNameTextField     : UITextField!
    @IBOutlet weak var passwordTextField     : UITextField!
    @IBOutlet weak var otpTextField          : UITextField!
    
    @IBOutlet weak var emailHintLabel        : UILabel!
    @IBOutlet weak var passwordHintLabel     : UILabel!
    @IBOutlet weak var rememberMeLabel       : UILabel!
    
    @IBOutlet weak var eyeButton             : UIButton!
    @IBOutlet weak var rememberMeButton      : UIButton!
    @IBOutlet weak var signUpButton          : UIButton!
    @IBOutlet weak var passwordBlockView     : UIView!
    @IBOutlet weak var otpBlockView          : UIView!
    
    var keyboardOffset = 0.0
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let configurator = LoginConfigurator()
        configurator.configure(viewController: self)
        
        passwordBlockView.isHidden = false
        otpBlockView.isHidden = true
        
        presenter?.setupEmailTextFieldsAndHintLabel(userEmail: userEmail!)
        presenter?.setupPasswordTextFieldsAndHintLabel(password: password!)
        presenter?.setupSignUpButton()
        presenter?.hintLabel(show: false, sender: userNameTextField)
        presenter?.hintLabel(show: false, sender: passwordTextField)
        
        userNameTextField.delegate = self
        passwordTextField.delegate = self
        //otpTextField.delegate = self
        
        rememberMeLabel.text = "rememberMe".localized()
        
        otpTextField.placeholder = "twoFAPlaceholder".localized()
        otpTextField.attributedPlaceholder = NSAttributedString(string: "twoFAPlaceholder".localized(), attributes: [.foregroundColor: UIColor.white])
        
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
        
//        self.mainViewController?.stopAutoUpdaterTimer()
    }
    
    //MARK: - IBActions
    
    @IBAction func loginButtonPressed(_ sender: AnyObject) {
        
        self.presenter?.buttonLoginPressed(userEmail: userEmail!, password: password!, twoFAcode: otpTextField.text ?? "")
    }
    
    @IBAction func forgotPasswordButtonPressed(_ sender: AnyObject) {
        
        self.router?.showForgotPasswordViewController()
    }
    
    @IBAction func createAccountButtonPressed(_ sender: AnyObject) {
        
        self.presenter?.buttonCreateAccountPressed()
    }
    
    @IBAction func rememberMeButtonPressed(_ sender: Any) {
        self.rememberMeButton.isSelected = !self.rememberMeButton.isSelected
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
