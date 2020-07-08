//
//  InboxConfigurator.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 11.10.2018.
//  Copyright © 2018 CTemplar. All rights reserved.
//

import Foundation
import UIKit
import Networking
import Utility

class InboxConfigurator {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    func configure(viewController : InboxViewController) {
        
        let router = InboxRouter()
        router.viewController = viewController
        
        let presenter = InboxPresenter()
        presenter.viewController = viewController
        
        let interactor = InboxInteractor()
        interactor.presenter = presenter
        interactor.viewController = viewController
        interactor.apiService = NetworkManager.shared.apiService
        interactor.pgpService = UtilityManager.shared.pgpService
        
        presenter.interactor = interactor
        
        viewController.presenter = presenter
        viewController.router = router
        
        let dataSource = InboxDataSource()
        viewController.dataSource = dataSource
        
        dataSource.formatterService = UtilityManager.shared.formatterService
    }
}
