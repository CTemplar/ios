//
//  SignUpConfigurator.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 03.10.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import UIKit

class SignUpConfigurator {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    func configure(viewController : SignUpPageViewController) {
        
        let router = SignUpRouter()
        router.viewController = viewController
        
        let presenter = SignUpPresenter()
        presenter.viewController = viewController
        presenter.formatterService = appDelegate.applicationManager.formatterService
        
        let interactor = SignUpInteractor()
        interactor.presenter = presenter
        interactor.viewController = viewController
        interactor.apiService = appDelegate.applicationManager.apiService
        interactor.keychainService = appDelegate.applicationManager.keychainService
        
        presenter.interactor = interactor
        
        viewController.presenter = presenter
        viewController.router = router
    }
}
