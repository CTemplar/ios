//
//  MoveToConfigurator.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 06.11.2018.
//  Copyright © 2018 CTemplar. All rights reserved.
//

import Foundation

import UIKit

class MoveToConfigurator {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    func configure(viewController : MoveToViewController) {
        
        let router = MoveToRouter()
        router.viewController = viewController
        
        let presenter = MoveToPresenter()
        presenter.viewController = viewController
        
        let interactor = MoveToInteractor()
        interactor.presenter = presenter
        interactor.viewController = viewController
        interactor.apiService = appDelegate.applicationManager.apiService
                
        presenter.interactor = interactor
        
        viewController.presenter = presenter
        viewController.router = router
        
        let dataSource = MoveToDataSource()
        viewController.dataSource = dataSource
        
    }
}
