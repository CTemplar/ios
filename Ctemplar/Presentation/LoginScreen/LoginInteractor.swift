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
                
                NotificationCenter.default.post(name: Notification.Name(k_updateInboxMessagesNotificationID), object: nil, userInfo: nil)
                
                self.viewController?.router?.showInboxScreen()
                
            case .failure(let error):
                print("login error:", error)
                
                if error.localizedDescription == APIResponse.twoFAEnabled.rawValue {
                    //show 2FA screen
                } else {
                    AlertHelperKit().showAlert(self.viewController!, title: "Login Error".localized(), message: error.localizedDescription, button: "closeButton".localized())
                }
            }
        }
    }
}
