//
//  ForgotPasswordInteractor.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 16.10.2018.
//  Copyright © 2018 CTemplar. All rights reserved.
//

import Foundation
import Utility
import Networking
import UIKit

class ForgotPasswordInteractor: HashingService {
    
    var viewController  : UIViewController?
    var presenter       : ForgotPasswordPresenter?
    var apiService      : APIService?
    var keychainService : KeychainService?
    
    func recoveryPasswordCode(userName: String, recoveryEmail: String) {
        NetworkManager.shared.networkService.recoveryPasswordCode(for: userName,
                                                              recoveryEmail: recoveryEmail)
        {
            guard case .failure(let error) = $0 else {
                return
            }
            self.viewController?.showAlert(with: "Password Code Error",
                                           message: error.localizedDescription,
                                           buttonTitle: Strings.Button.closeButton.localized)
            
        }
    }
    
    func resetPassword(userName: String, password: String, resetPasswordCode: String, recoveryEmail: String) {
        Loader.start()
        generateCryptoInfo(for: userName, password: password) {
            guard let info = try? $0.get() else {
                Loader.stop()
                self.viewController?.showAlert(with: "SignUp Error".localized(),
                                               message: "Something went wrong".localized(),
                                               buttonTitle: Strings.Button.closeButton.localized)
                return
            }
            let details = ResetPasswordDetails(resetPasswordCode: resetPasswordCode,
                                               userName: userName,
                                               password: info.hashedPassword,
                                               privateKey: info.userPgpKey.privateKey,
                                               publicKey: info.userPgpKey.publicKey,
                                               fingerprint: info.userPgpKey.fingerprint,
                                               recoveryEmail: recoveryEmail)
            Loader.start()
            NetworkManager.shared.networkService.resetPassword(with: details) { result in
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
            //self.sendAPNDeviceToken()
            self.presenter?.router?.showInboxScreen()
        case .failure(let error):
            self.viewController?.showAlert(with: "Reset Password Error".localized(),
                                           message: error.localizedDescription,
                                           buttonTitle: Strings.Button.closeButton.localized)
        }
    }
}
