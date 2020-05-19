//
//  InboxSideMenuConfigurator.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 22.10.2018.
//  Copyright © 2018 CTemplar. All rights reserved.
//

import Foundation
import UIKit

class InboxSideMenuConfigurator {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    func configure(viewController : InboxSideMenuViewController) {
        
        let router = InboxSideMenuRouter()
        router.viewController = viewController
        
        let presenter = InboxSideMenuPresenter()
        presenter.viewController = viewController
        
        let interactor = InboxSideMenuInteractor()
        interactor.presenter = presenter
        interactor.viewController = viewController
        interactor.apiService = appDelegate.applicationManager.apiService
        
        presenter.interactor = interactor
        
        viewController.presenter = presenter
        viewController.router = router
        
        let dataSource = InboxSideMenuDataSource()
        viewController.dataSource = dataSource
        
        dataSource.formatterService = appDelegate.applicationManager.formatterService
    }
}
