//
//  LoginInteractor.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 02.10.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import AlertHelperKit
import PKHUD

class LoginInteractor: HashingService {
    
    var viewController  : LoginViewController?
    var presenter       : LoginPresenter?
    var apiService      : APIService?
    var keychainService : KeychainService?
    
    func authenticateUser(userName: String, password: String, twoFAcode: String) {
        
        let trimmedUsername = trimUserName(userName)
        HUD.show(.labeledProgress(title: "hashing".localized(), subtitle: ""))
        generateHashedPassword(for: userName, password: password) { result in
            guard let value = try? result.get() else {
                HUD.hide()
                AlertHelperKit().showAlert(self.viewController!,
                                           title: "Login Error".localized(),
                                           message: "Something went wrong".localized(),
                                           button: "closeButton".localized())
                return
            }
            HUD.show(.labeledProgress(title: "updateToken".localized(), subtitle: ""))
            AppManager.shared.networkService.loginUser(with: LoginDetails(userName: trimmedUsername,
                                                                          password: value,
                                                                          twoFAcode: twoFAcode)) { result in
                                                                            print("result \(result)")
                                                                            HUD.hide()
            }
        }

        
//        apiService?.authenticateUser(userName: trimmedUsername, password: password, twoFAcode: twoFAcode) {(result) in
//            
//            switch(result) {
//                
//            case .success(let value):
//                print("login success value:", value)
//                self.keychainService?.saveUserCredentials(userName: userName, password: password)
//                
//                NotificationCenter.default.post(name: Notification.Name(k_updateInboxMessagesNotificationID), object: nil, userInfo: nil)
//                self.sendAPNDeviceToken()
//                self.viewController?.router?.showInboxScreen()
//                
//            case .failure(let error):
//                print("login error:", error)
//                
//                if error.localizedDescription == APIResponse.twoFAEnabled.rawValue {
//                    //show 2FA screen
//                    self.viewController?.passwordBlockView.isHidden = true
//                    self.viewController?.otpBlockView.isHidden = false
//                } else {
//                    AlertHelperKit().showAlert(self.viewController!, title: "Login Error".localized(), message: error.localizedDescription, button: "closeButton".localized())
//                }
//            }
//        }
    }
    
    func trimUserName(_ userName: String) -> String {
        
        var trimmedName = userName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let substrings = trimmedName.split(separator: "@")
            
        if let domain = substrings.last {
            if domain == k_mainDomain || domain == k_devMainDomain {
                if let name = substrings.first {
                    trimmedName = String(name)
                }
            }
        }
        
        return trimmedName
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
