//
//  ForgotPasswordConfigurator.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 16.10.2018.
//  Copyright © 2018 CTemplar. All rights reserved.
//

import UIKit
import Utility
import Networking

class ForgotPasswordConfigurator {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var presenter : ForgotPasswordPresenter?
    var router : ForgotPasswordRouter?
    
    func configure(viewController : UIViewController) {
        
        let router = ForgotPasswordRouter()
        router.viewController = viewController
        
        let presenter = ForgotPasswordPresenter()
        presenter.viewController = viewController
        presenter.formatterService = UtilityManager.shared.formatterService
        
        let interactor = ForgotPasswordInteractor()
        interactor.presenter = presenter
        interactor.viewController = viewController
        interactor.apiService = NetworkManager.shared.apiService
        interactor.keychainService = UtilityManager.shared.keychainService
        
        presenter.interactor = interactor
        presenter.router = router
        
        self.presenter = presenter
        self.router = router
        
        //viewController.presenter = presenter
        //viewController.router = router
    }
}
