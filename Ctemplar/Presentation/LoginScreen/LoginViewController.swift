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
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let configurator = LoginConfigurator()
        configurator.configure(viewController: self)
        
        presenter!.setupEmailTextFieldsAndHintLabel(userEmail: userEmail!)
        presenter!.setupPasswordTextFieldsAndHintLabel(password: password!)
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
        presenter!.setupEmailTextFieldsAndHintLabel(userEmail: userEmail!)
    }
    
    @IBAction func passwordEyeButtonPressed(_ sender: AnyObject) {
        
        passwordTextFieldSecure = !passwordTextFieldSecure
        passwordTextField.isSecureTextEntry = passwordTextFieldSecure
    }
    
    @IBAction func passwordTyped(_ sender: UITextField) {
        
        password = sender.text
        presenter!.setupPasswordTextFieldsAndHintLabel(password: password!)
    }
}
