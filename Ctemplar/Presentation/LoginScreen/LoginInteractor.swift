//
//  LoginInteractor.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 02.10.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import AlertHelperKit

class LoginInteractor {
    
    var viewController  : LoginViewController?
    var presenter       : LoginPresenter?
    var apiService      : APIService?
    var keychainService : KeychainService?
    
    func authenticateUser(userName: String, password: String) {

        apiService?.authenticateUser(userName: userName, password: password) {(result) in
            
            switch(result) {
                
            case .success(let value):
                print("login success value:", value)
                self.keychainService?.saveUserCredentials(userName: userName, password: password)
                
                self.viewController?.dismiss(animated: true, completion: nil)
            case .failure(let error):
                print("login error:", error)
                AlertHelperKit().showAlert(self.viewController!, title: "Login Error", message: error.localizedDescription, button: "Close")
            }
        }
    }
}
