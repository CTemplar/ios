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
    
    func signUpUser(userName: String, password: String, recoveryEmail: String) {
        
        apiService?.signUpUser(userName: userName, password: password, recoveryEmail: recoveryEmail, viewController: self.viewController!)
    }
}
