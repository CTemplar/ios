//
//  SignUpInteractor.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 03.10.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import AlertHelperKit

class SignUpInteractor {
    
    var viewController  : SignUpPageViewController?
    var presenter       : SignUpPresenter?
    var apiService      : APIService?
    var keychainService : KeychainService?
    
    func signUpUser(userName: String, password: String, recoveryEmail: String) {
    
        apiService?.signUpUser(userName: userName, password: password, recoveryEmail: recoveryEmail) {(result) in
            
            switch(result) {
                
            case .success(let value):
                print("signup success value:", value)
                
                self.keychainService?.saveUserCredentials(userName: userName, password: password)
                
                let currentPresentingViewController = self.viewController?.presentingViewController as? LoginViewController
                
                self.viewController?.dismiss(animated: true) {
                    currentPresentingViewController?.dismiss(animated: false, completion: nil) //hide Login View Controller
                }
                
            case .failure(let error):
                print("signup error:", error)
                AlertHelperKit().showAlert(self.viewController!, title: "SignUp Error", message: error.localizedDescription, button: "Close")
            }
        }
    }
    
    func checkUser(userName: String, childViewController: UIViewController) {
        
        apiService?.checkUser(userName: userName) {(result) in
            
            switch(result) {
                
            case .success(let value):
                print("checkUser success value:", value)
                self.presenter?.showNextViewController(childViewController: childViewController)
                
            case .failure(let error):
                print("checkUser error:", error)
                AlertHelperKit().showAlert(self.viewController!, title: "User Name Error", message: error.localizedDescription, button: "Close")
            }
        }
    }
}
