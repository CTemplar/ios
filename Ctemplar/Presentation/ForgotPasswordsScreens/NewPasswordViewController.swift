//
//  NewPasswordViewController.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 16.10.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import UIKit

class NewPasswordViewController: UIViewController {
    
    var configurator: ForgotPasswordConfigurator?
    
    var resetCode       : String? = ""
    var userName        : String? = ""
    var pasword         : String? = ""
    
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
    
    @IBAction func resetPasswordButtonPressed(_ sender: AnyObject) {
        
        self.configurator?.presenter?.interactor?.resetPassword(userName: userName!, password: pasword!, resetPasswordCode: resetCode!)
    }
}
