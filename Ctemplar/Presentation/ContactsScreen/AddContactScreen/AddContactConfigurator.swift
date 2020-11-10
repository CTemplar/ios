//
//  AddContactConfigurator.swift
//  CTemplar
//
//  Created by Tatarinov Dmitry on 20.11.2018.
//  Copyright © 2018 CTemplar. All rights reserved.
//

import Foundation
import UIKit
import Utility
import Networking

class AddContactConfigurator {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    func configure(viewController : AddContactViewController) {
        
        let router = AddContactRouter()
        router.viewController = viewController
        
        let presenter = AddContactPresenter()
        presenter.viewController = viewController
        presenter.formatterService = UtilityManager.shared.formatterService
        
        let interactor = AddContactInteractor()
        interactor.presenter = presenter
        interactor.viewController = viewController
        interactor.apiService = NetworkManager.shared.apiService
        
        presenter.interactor = interactor
        
        viewController.presenter = presenter
        viewController.router = router
    }
}
