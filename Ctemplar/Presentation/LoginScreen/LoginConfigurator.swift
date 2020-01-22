//
//  LoginConfigurator.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 02.10.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import UIKit

class LoginConfigurator {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    func configure(viewController : LoginViewController) {
        
        let router = LoginRouter()
        router.viewController = viewController
        
        let presenter = LoginPresenter()
        presenter.viewController = viewController
        presenter.formatterService = appDelegate.applicationManager.formatterService
        
        let interactor = LoginInteractor()
        interactor.presenter = presenter
        interactor.viewController = viewController
        interactor.apiService = appDelegate.applicationManager.apiService
        interactor.keychainService = appDelegate.applicationManager.keychainService
        
        presenter.interactor = interactor
        
        viewController.presenter = presenter
        viewController.router = router
    }
}
