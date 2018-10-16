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
        
        apiService?.recoveryPasswordCode(userName: userName, recoveryEmail: recoveryEmail) {(result) in
            
            switch(result) {
                
            case .success(let value):
                print("recoveryPasswordCode success value:", value)
                
            case .failure(let error):
                print("recoveryPasswordCode error:", error)
                AlertHelperKit().showAlert(self.viewController!, title: "Password Code Error", message: error.localizedDescription, button: "Close")
            }
        }
    }
}
