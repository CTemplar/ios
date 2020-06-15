//
//  SignUpConfigurator.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 03.10.2018.
//  Copyright © 2018 CTemplar. All rights reserved.
//

import UIKit
import Utility
import Networking

class SignUpConfigurator {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    func configure(viewController : SignUpPageViewController) {
        
        let router = SignUpRouter()
        router.viewController = viewController
        
        let presenter = SignUpPresenter()
        presenter.viewController = viewController
        presenter.formatterService = UtilityManager.shared.formatterService
        
        let interactor = SignUpInteractor()
        interactor.presenter = presenter
        interactor.viewController = viewController
        interactor.apiService = NetworkManager.shared.apiService
        interactor.keychainService = UtilityManager.shared.keychainService
        
        presenter.interactor = interactor
        
        viewController.presenter = presenter
        viewController.router = router
    }
}
