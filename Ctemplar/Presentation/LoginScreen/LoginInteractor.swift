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
                                                                            if let value = try? result.get(), !value.isTwoFAEnabled {
                                                                                self.keychainService?.saveUserCredentials(userName: userName, password: password)
                                                                            }
                                                                            self.handleNetwork(responce: result)
                                                                            HUD.hide()
            }
        }
    }
    
    func handleNetwork(responce: AppResult<LoginResult>) {
        switch responce {
        case .success(let value):
            if value.isTwoFAEnabled {
                if value.token == nil {
                    viewController?.passwordBlockView.isHidden = true
                    viewController?.otpBlockView.isHidden = false
                    return
                }
            }
            if let token = value.token {
                keychainService?.saveToken(token: token)
            }
            NotificationCenter.default.post(name: Notification.Name(k_updateInboxMessagesNotificationID), object: nil, userInfo: nil)
            self.sendAPNDeviceToken()
            self.viewController?.router?.showInboxScreen()
        case .failure(let error):
            AlertHelperKit().showAlert(self.viewController!,
                                       title: "Login Error".localized(),
                                       message: error.localizedDescription,
                                       button: "closeButton".localized())
            viewController?.passwordBlockView.isHidden = false
            viewController?.otpBlockView.isHidden = true
            viewController?.otpTextField.text = ""
        }
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
        guard let deviceToken = keychainService?.getAPNDeviceToken(), !deviceToken.isEmpty  else { return }
        AppManager.shared.networkService.send(deviceToken: deviceToken) { _ in }
    }
}
