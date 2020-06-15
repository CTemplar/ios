//
//  LoginConfigurator.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 02.10.2018.
//  Copyright © 2018 CTemplar. All rights reserved.
//

import UIKit
import Utility
import Networking

class LoginConfigurator {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    func configure(viewController : LoginViewController) {
        
        let router = LoginRouter()
        router.viewController = viewController
        
        let presenter = LoginPresenter()
        presenter.viewController = viewController
        presenter.formatterService = UtilityManager.shared.formatterService
        
        let interactor = LoginInteractor()
        interactor.presenter = presenter
        interactor.viewController = viewController
        interactor.apiService = NetworkManager.shared.apiService
        interactor.keychainService = UtilityManager.shared.keychainService
        
        presenter.interactor = interactor
        
        viewController.presenter = presenter
        viewController.router = router
    }
}
