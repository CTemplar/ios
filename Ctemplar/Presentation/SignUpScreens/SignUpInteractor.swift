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
                
                self.viewController?.router?.showInboxScreen()
                
                NotificationCenter.default.post(name: Notification.Name(k_updateInboxMessagesNotificationID), object: nil, userInfo: nil)
                
            case .failure(let error):
                print("signup error:", error)
                AlertHelperKit().showAlert(self.viewController!, title: "SignUp Error", message: error.localizedDescription, button: "closeButton".localized())
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
                AlertHelperKit().showAlert(self.viewController!, title: "User Name Error", message: error.localizedDescription, button: "closeButton".localized())
            }
        }
    }
    
    func getCaptcha() {
        
        apiService?.getCaptcha() {(result) in
            
            switch(result) {
                
            case .success(let value):
                //print("getCaptcha success value:", value)
                
                if let captcha = value as? Captcha {
                    print("key:", captcha.captchaKey as Any)
                    print("url:", captcha.captchaImageUrl as Any)
                    
                    self.verifyCaptcha(key: captcha.captchaKey!, value: "xxxxx")
                }
                
                break
            case .failure(let error):
                print("getCaptcha error:", error)               
            }
        }
    }
    
    func verifyCaptcha(key: String, value: String) {
        
        apiService?.verifyCaptcha(key: key, value: value) {(result) in
            
            switch(result) {
                
            case .success(let value):
                print("verifyCaptcha success value:", value)
                break
            case .failure(let error):
                print("verifyCaptcha error:", error)
            }
        }
    }
}
