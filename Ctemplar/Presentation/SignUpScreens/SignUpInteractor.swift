//
//  SignUpInteractor.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 03.10.2018.
//  Copyright © 2018 CTemplar. All rights reserved.
//

import Foundation
import Utility
import Networking
import UIKit

class SignUpInteractor: HashingService {
    
    var viewController  : SignUpPageViewController?
    var presenter       : SignUpPresenter?
    var apiService      : APIService?
    var keychainService : KeychainService?
    
    func signUpUser(userName: String, password: String, recoveryEmail: String, captchaKey: String, captchaValue: String) {
        Loader.start()
        generateCryptoInfo(for: userName, password: password) {
            guard let info = try? $0.get() else {
                Loader.stop()
                self.viewController?.showAlert(with: "SignUp Error".localized(),
                                               message: "Something went wrong".localized(),
                                               buttonTitle: Strings.Button.closeButton.localized)
                return
            }
            let details = SignupDetails(userName: userName,
                                        password: info.hashedPassword,
                                        privateKey: info.userPgpKey.privateKey,
                                        publicKey: info.userPgpKey.publicKey,
                                        fingerprint: info.userPgpKey.fingerprint,
                                        language: "English",
                                        captchaKey: captchaKey,
                                        captchaValue: captchaValue,
                                        recoveryEmail: recoveryEmail,
                                        fromAddress: "",
                                        redeemCode: "",
                                        stripeToken: "",
                                        memory: "",
                                        emailCount: "",
                                        paymentType: "")
            Loader.start()
            NetworkManager.shared.networkService.signUp(with: details) { result in
                if (try? result.get()) != nil {
                    self.keychainService?.saveUserCredentials(userName: userName, password: password)
                }
                self.handleNetwork(responce: result)
                Loader.stop()
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
            self.viewController?.showAlert(with: "SignUp Error".localized(),
                                           message: error.localizedDescription,
                                           buttonTitle: Strings.Button.closeButton.localized)
        }
    }
    
    func checkUser(userName: String, childViewController: UIViewController) {
        NetworkManager.shared.networkService.checkUser(name: userName) { result in
            switch result {
            case .success(let value):
                print("checkUser success value:", value)
                if !value.exists {
                    self.presenter?.showNextViewController(childViewController: childViewController)
                } else {
                    self.viewController?.showAlert(with: "User Name Error".localized(),
                                                   message: "This name already exists!".localized(),
                                                   buttonTitle: Strings.Button.closeButton.localized)
                }
            case .failure(let error):
                print("checkUser error:", error)
                self.viewController?.showAlert(with: "User Name Error".localized(),
                                               message: error.localizedDescription,
                                               buttonTitle: Strings.Button.closeButton.localized)
            }
        }
    }
    
    func getCaptcha() {
        NetworkManager.shared.networkService.getCaptcha {
            guard let captcha = try? $0.get() else {
                return
            }
            self.downloadCaptchaImage(with: captcha.image)
            self.presenter?.viewController?.captchaKey = captcha.key
        }
    }
    
    func verifyCaptcha(key: String, value: String) {
        NetworkManager.shared.networkService.verifyCaptcha(with: value, key: key) {
            guard let result = try? $0.get(), result.status else {
                return
            }
            let emailVC = self.viewController?.orderedViewControllers[2] as! SignUpPageEmailViewController
            emailVC.captchaView.isHidden = true
        }
    }
    
    func downloadCaptchaImage(with url: String) {
        
        Loader.start()
        
        apiService?.loadAttachFile(url: url) {(result) in
            
            Loader.stop()
            
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
                self.viewController?.showAlert(with: "Download File Error",
                                               message: error.localizedDescription,
                                               buttonTitle: Strings.Button.closeButton.localized)
            }
        }
    }
    
    func sendAPNDeviceToken() {
        guard let deviceToken = keychainService?.getAPNDeviceToken(), !deviceToken.isEmpty  else { return }
        NetworkManager.shared.networkService.send(deviceToken: deviceToken) { _ in }
    }
}
