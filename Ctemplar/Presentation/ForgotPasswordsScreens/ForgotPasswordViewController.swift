//
//  ForgotPasswordViewController.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 15.10.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import UIKit

class ForgotPasswordViewController: UIViewController {
    
    var configurator: ForgotPasswordConfigurator?
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configurator = ForgotPasswordConfigurator()
        self.configurator?.configure(viewController: self)
    }
    
    //MARK: - IBActions
    
    @IBAction func backButtonPressed(_ sender: AnyObject) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func resetButtonPressed(_ sender: AnyObject) {
        
        self.configurator?.router?.showConfirmResetPasswordViewController()        
    }
    
    @IBAction func forgotUsernameButtonPressed(_ sender: AnyObject) {
        
        self.configurator?.router?.showForgotUsernameViewController()
    }
}
