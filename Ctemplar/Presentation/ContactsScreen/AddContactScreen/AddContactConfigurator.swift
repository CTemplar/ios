//
//  AddContactConfigurator.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 20.11.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import UIKit

class AddContactConfigurator {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    func configure(viewController : AddContactViewController) {
        
        let router = AddContactRouter()
        router.viewController = viewController
        
        let presenter = AddContactPresenter()
        presenter.viewController = viewController
        
        let interactor = AddContactInteractor()
        interactor.presenter = presenter
        interactor.viewController = viewController
        interactor.apiService = appDelegate.applicationManager.apiService
        
        presenter.interactor = interactor
        
        viewController.presenter = presenter
        viewController.router = router
    }
}
