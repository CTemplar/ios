//
//  ComposeConfigurator.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 27.11.2018.
//  Copyright © 2018 CTemplar. All rights reserved.
//

import Foundation
import UIKit
import Networking
import Utility

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
        interactor.apiService = NetworkManager.shared.apiService
        interactor.pgpService = UtilityManager.shared.pgpService
        
        presenter.interactor = interactor
        presenter.formatterService = UtilityManager.shared.formatterService
        
        viewController.presenter = presenter
        viewController.router = router
        viewController.interactor = interactor
        
        let dataSource = ComposeDataSource()
        viewController.dataSource = dataSource
        
        dataSource.formatterService = UtilityManager.shared.formatterService
    }
}
