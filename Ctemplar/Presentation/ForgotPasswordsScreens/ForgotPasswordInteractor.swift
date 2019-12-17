//
//  ForgotPasswordInteractor.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 16.10.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import AlertHelperKit

class ForgotPasswordInteractor {
    
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
        
        apiService?.resetPassword(resetPasswordCode: resetPasswordCode, userName: userName, password: password, recoveryEmail: recoveryEmail) {(result) in
            
            switch(result) {
                
            case .success(let value):
                print("resetPassword success value:", value)
                
                //self.keychainService?.saveUserCredentials(userName: userName, password: password)
                self.presenter?.router?.backToLoginViewController()                
                
            case .failure(let error):
                print("resetPassword error:", error)
                AlertHelperKit().showAlert(self.viewController!, title: "Reset Password Error", message: error.localizedDescription, button: "closeButton".localized())
            }
        }
    }
}
