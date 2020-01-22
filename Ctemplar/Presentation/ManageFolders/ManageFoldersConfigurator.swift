//
//  ManageFoldersConfigurator.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 17.12.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import UIKit

class ManageFoldersConfigurator {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    func configure(viewController : ManageFoldersViewController) {
        
        let router = ManageFoldersRouter()
        router.viewController = viewController
        
        let presenter = ManageFoldersPresenter()
        presenter.viewController = viewController
        
        let interactor = ManageFoldersInteractor()
        interactor.presenter = presenter
        interactor.viewController = viewController
        interactor.apiService = appDelegate.applicationManager.apiService
        
        presenter.interactor = interactor
        
        viewController.presenter = presenter
        viewController.router = router
        
        let dataSource = ManageFoldersDataSource()
        viewController.dataSource = dataSource
        
        dataSource.formatterService = appDelegate.applicationManager.formatterService
    }
}
