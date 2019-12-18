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

class SignUpInteractor: HashingService {
    
    var viewController  : SignUpPageViewController?
    var presenter       : SignUpPresenter?
    var apiService      : APIService?
    var keychainService : KeychainService?
    
    func signUpUser(userName: String, password: String, recoveryEmail: String, captchaKey: String, captchaValue: String) {
        HUD.show(.labeledProgress(title: "hashing".localized(), subtitle: ""))
        generateCryptoInfo(for: userName, password: password) {
            guard let info = try? $0.get() else {
                HUD.hide()
                AlertHelperKit().showAlert(self.viewController!,
                                           title: "SignUp Error".localized(),
                                           message: "Something went wrong".localized(),
                                           button: "closeButton".localized())
                return
            }
            let details = SignupDetails(userName: userName,
                                        password: info.hashedPassword,
                                        privateKey: info.userPgpKey.privateKey,
                                        publicKey: info.userPgpKey.publicKey,
                                        fingerprint: info.userPgpKey.fingerprint,
                                        captchaKey: captchaKey,
                                        captchaValue: captchaValue,
                                        recoveryEmail: recoveryEmail,
                                        fromAddress: "",
                                        redeemCode: "",
                                        stripeToken: "",
                                        memory: "",
                                        emailCount: "",
                                        paymentType: "")
            HUD.show(.labeledProgress(title: "updateToken".localized(), subtitle: ""))
            AppManager.shared.networkService.signUp(with: details) { result in
                if (try? result.get()) != nil {
                    self.keychainService?.saveUserCredentials(userName: userName, password: password)
                }
                self.handleNetwork(responce: result)
                HUD.hide()
            }
        }
    }
    
    func handleNetwork(responce: AppResult<TokenResult>) {
        switch responce {
        case .success(let value):
            keychainService?.saveToken(token: value.token)
            NotificationCenter.default.post(name: Notification.Name(k_updateInboxMessagesNotificationID), object: nil, userInfo: nil)
            self.sendAPNDeviceToken()
            self.viewController?.router?.showInboxScreen()
        case .failure(let error):
            AlertHelperKit().showAlert(self.viewController!,
                                       title: "SignUp Error".localized(),
                                       message: error.localizedDescription,
                                       button: "closeButton".localized())
        }
    }
    
    func checkUser(userName: String, childViewController: UIViewController) {
        AppManager.shared.networkService.checkUser(name: userName) { result in
            switch result {
            case .success(let value):
                print("checkUser success value:", value)
                if !value.exists {
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
