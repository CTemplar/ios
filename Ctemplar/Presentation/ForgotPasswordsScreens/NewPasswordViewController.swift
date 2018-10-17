//
//  NewPasswordViewController.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 16.10.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import UIKit

class NewPasswordViewController: UIViewController, UITextFieldDelegate {
    
    var configurator: ForgotPasswordConfigurator?
    
    var resetCode            : String? = ""
    var userName             : String? = ""
    var password             : String? = ""
    var recoveryEmail        : String? = ""
    
    var newPassword          : String? = ""
    var confirmedPassword    : String? = ""
    
    @IBOutlet var newPasswordTextField      : UITextField!
    @IBOutlet var confirmPasswordTextField  : UITextField!
    
    @IBOutlet var newPasswordHintLabel      : UILabel!
    @IBOutlet var confirmPasswordHintLabel  : UILabel!
    
    @IBOutlet var resetPasswordButton       : UIButton!
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configurator = ForgotPasswordConfigurator()
        self.configurator?.configure(viewController: self)
        
        self.configurator?.presenter?.setupPasswordTextFieldsAndHintLabels(childViewController: self, sender: newPasswordTextField)
        self.configurator?.presenter?.setupPasswordTextFieldsAndHintLabels(childViewController: self, sender: confirmPasswordTextField)        
    }
    
    //MARK: - IBActions
    
    @IBAction func backButtonPressed(_ sender: AnyObject) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func resetPasswordButtonPressed(_ sender: AnyObject) {
        
        self.configurator?.presenter?.interactor?.resetPassword(userName: userName!, password: password!, resetPasswordCode: resetCode!, recoveryEmail: recoveryEmail!)
    }
    
    @IBAction func passwordTyped(_ sender: UITextField) {
        
        self.configurator?.presenter?.setupPasswordTextFieldsAndHintLabels(childViewController: self, sender: sender)
    }
}
