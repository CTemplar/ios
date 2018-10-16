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
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configurator = ForgotPasswordConfigurator()
        self.configurator?.configure(viewController: self)
        
        self.configurator?.presenter?.setupUserNameTextFieldsAndHintLabel(userName: userName!)
        self.configurator?.presenter?.setupRecoveryTextFieldsAndHintLabel(email: recoveryEmail!)
    }
    
    //MARK: - IBActions
    
    @IBAction func backButtonPressed(_ sender: AnyObject) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func resetButtonPressed(_ sender: AnyObject) {
        
        //self.configurator?.router?.showConfirmResetPasswordViewController()
        self.configurator?.presenter?.buttonResetPasswordPressed(userName: userName!, recoveryPassword: recoveryEmail!)
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
}
