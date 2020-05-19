//
//  ForgotPasswordInteractor.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 16.10.2018.
//  Copyright © 2018 CTemplar. All rights reserved.
//

import Foundation
import AlertHelperKit
import PKHUD

class ForgotPasswordInteractor: HashingService {
    
    var viewController  : UIViewController?
    var presenter       : ForgotPasswordPresenter?
    var apiService      : APIService?
    var keychainService : KeychainService?
    
    func recoveryPasswordCode(userName: String, recoveryEmail: String) {
        AppManager.shared.networkService.recoveryPasswordCode(for: userName,
                                                              recoveryEmail: recoveryEmail)
        {
            guard case .failure(let error) = $0 else {
                return
            }
            AlertHelperKit().showAlert(self.viewController!,
                                       title: "Password Code Error",
                                       message: error.localizedDescription,
                                       button: "closeButton".localized())
            
        }
    }
    
    func resetPassword(userName: String, password: String, resetPasswordCode: String, recoveryEmail: String) {
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
            let details = ResetPasswordDetails(resetPasswordCode: resetPasswordCode,
                                               userName: userName,
                                               password: info.hashedPassword,
                                               privateKey: info.userPgpKey.privateKey,
                                               publicKey: info.userPgpKey.publicKey,
                                               fingerprint: info.userPgpKey.fingerprint,
                                               recoveryEmail: recoveryEmail)
            HUD.show(.labeledProgress(title: "updateToken".localized(), subtitle: ""))
            AppManager.shared.networkService.resetPassword(with: details) { result in
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
            //self.sendAPNDeviceToken()
            self.presenter?.router?.showInboxScreen()
        case .failure(let error):
            AlertHelperKit().showAlert(self.viewController!,
                                       title: "Reset Password Error".localized(),
                                       message: error.localizedDescription,
                                       button: "closeButton".localized())
        }
    }
}
