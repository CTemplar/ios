//
//  SignUpInteractor.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 03.10.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import AlertHelperKit
import PKHUD

class SignUpInteractor {
    
    var viewController  : SignUpPageViewController?
    var presenter       : SignUpPresenter?
    var apiService      : APIService?
    var keychainService : KeychainService?
    
    func signUpUser(userName: String, password: String, recoveryEmail: String, captchaKey: String, captchaValue: String) {
    
        apiService?.signUpUser(userName: userName, password: password, recoveryEmail: recoveryEmail, captchaKey: captchaKey, captchaValue: captchaValue) {(result) in
            
            switch(result) {
                
            case .success(let value):
                print("signup success value:", value)
                
                self.keychainService?.saveUserCredentials(userName: userName, password: password)
                
                self.viewController?.router?.showInboxScreen()
                self.sendAPNDeviceToken()
                NotificationCenter.default.post(name: Notification.Name(k_updateInboxMessagesNotificationID), object: nil, userInfo: nil)
                
            case .failure(let error):
                print("signup error:", error)
                AlertHelperKit().showAlert(self.viewController!, title: "SignUp Error", message: error.localizedDescription, button: "closeButton".localized())
            }
        }
    }
    
    func checkUser(userName: String, childViewController: UIViewController) {
        AppManager.shared.networkService.checkUser(name: userName) { result in
            switch result {
            case .success(let value):
                print("checkUser success value:", value)
                if value.exists == 1 {
                    self.presenter?.showNextViewController(childViewController: childViewController)
                } else {
                    AlertHelperKit().showAlert(self.viewController!,
                                               title: "User Name Error".localized(),
                                               message: "This name already exists!".localized(),
                                               button: "closeButton".localized())
                }
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
                    
                    //self.verifyCaptcha(key: captcha.captchaKey!, value: "xxxxx")
                    
                    if let url = captcha.captchaImageUrl {
                        self.downloadCaptchaImage(with: url)
                    }
                    
                     self.presenter?.viewController?.captchaKey = captcha.captchaKey
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
                let emailVC = self.viewController?.orderedViewControllers[2] as! SignUpPageEmailViewController
                
                emailVC.captchaView.isHidden = true
                
                break
            case .failure(let error):
                print("verifyCaptcha error:", error)
            }
        }
    }
    
    func downloadCaptchaImage(with url: String) {
        
        HUD.show(.progress)
        
        apiService?.loadAttachFile(url: url) {(result) in
            
            HUD.hide()
            
            switch(result) {
                
            case .success(let value):
                //print("url value:", value)
                let savedFileUrl = value as! URL
                
                let emailVC = self.viewController?.orderedViewControllers[2] as! SignUpPageEmailViewController
                
                if let data = try? Data(contentsOf: savedFileUrl) {
                    emailVC.captchaImageView.image = UIImage(data: data)
                }
                
            case .failure(let error):
                print("error:", error)
                AlertHelperKit().showAlert(self.viewController!, title: "Download File Error", message: error.localizedDescription, button: "closeButton".localized())
            }
        }
    }
    
    func sendAPNDeviceToken() {
        
        if let deviceToken = keychainService?.getAPNDeviceToken() {
            if deviceToken.count > 0 {
                apiService?.createAppToken(deviceToken: deviceToken) {(result) in
                
                    switch(result) {
                    
                    case .success(let value):
                        print("sendAPNDeviceToken success value:", value)
                    
                    case .failure(let error):
                        print("sendAPNDeviceToken error:", error)
                    }
                }
            }
        }
    }
}
