//
//  ComposeConfigurator.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 27.11.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import UIKit

class ComposeConfigurator {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    func configure(viewController :ComposeViewController) {
        
        let router = ComposeRouter()
        router.viewController = viewController
        
        let presenter = ComposePresenter()
        presenter.viewController = viewController
        
        let interactor = ComposeInteractor()
        interactor.presenter = presenter
        interactor.viewController = viewController
        interactor.apiService = appDelegate.applicationManager.apiService
        interactor.pgpService = appDelegate.applicationManager.pgpService
        
        presenter.interactor = interactor
        
        viewController.presenter = presenter
        viewController.router = router
        
        let dataSource = ComposeDataSource()
        viewController.dataSource = dataSource
        
        dataSource.formatterService = appDelegate.applicationManager.formatterService
    }
}
