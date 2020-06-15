//
//  ViewInboxEmailConfigurator.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 01.11.2018.
//  Copyright © 2018 CTemplar. All rights reserved.
//

import Foundation
import UIKit
import Utility
import Networking

class ViewInboxEmailConfigurator {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    func configure(viewController : ViewInboxEmailViewController) {
        
        let router = ViewInboxEmailRouter()
        router.viewController = viewController
        
        let presenter = ViewInboxEmailPresenter()
        presenter.viewController = viewController
        
        let interactor = ViewInboxEmailInteractor()
        interactor.presenter = presenter
        interactor.viewController = viewController
        interactor.apiService = NetworkManager.shared.apiService
        interactor.pgpService = UtilityManager.shared.pgpService
        interactor.formatterService = UtilityManager.shared.formatterService
        
        presenter.interactor = interactor
        
        viewController.presenter = presenter
        viewController.router = router
        
        let dataSource = ViewInboxEmailDataSource()
        viewController.dataSource = dataSource
        
        dataSource.formatterService = UtilityManager.shared.formatterService
    }
}
