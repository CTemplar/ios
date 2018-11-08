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
    
    var passwordTextFieldSecure   : Bool = true
    
    var presenter   : LoginPresenter?
    var router      : LoginRouter?
    
    var userEmail   : String? = ""
    var password    : String? = ""
    
    @IBOutlet var userNameTextField     : UITextField!
    @IBOutlet var passwordTextField     : UITextField!
    
    @IBOutlet var emailHintLabel        : UILabel!
    @IBOutlet var passwordHintLabel     : UILabel!
    
    @IBOutlet var eyeButton             : UIButton!
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let configurator = LoginConfigurator()
        configurator.configure(viewController: self)
        
        presenter!.setupEmailTextFieldsAndHintLabel(userEmail: userEmail!)
        presenter!.setupPasswordTextFieldsAndHintLabel(password: password!)
        
        userNameTextField.delegate = self
        passwordTextField.delegate = self
        
        let freeSpaceViewGesture = UITapGestureRecognizer(target: self, action:  #selector(self.tappedViewAction(sender:)))
        self.view.addGestureRecognizer(freeSpaceViewGesture)
    }
    
    //MARK: - IBActions
    
    @IBAction func loginButtonPressed(_ sender: AnyObject) {
        
        self.presenter?.buttonLoginPressed(userEmail: userEmail!, password: password!)
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
    
    @objc func tappedViewAction(sender : UITapGestureRecognizer) {
        
        view.endEditing(true)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        presenter!.hintLabel(show: true, sender: textField)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        presenter!.hintLabel(show: false, sender: textField)
    }
}
