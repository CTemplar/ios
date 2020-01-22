//
//  InboxConfigurator.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 11.10.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import UIKit

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
        interactor.apiService = appDelegate.applicationManager.apiService
        interactor.pgpService = appDelegate.applicationManager.pgpService
        
        presenter.interactor = interactor
        
        viewController.presenter = presenter
        viewController.router = router
        
        let dataSource = InboxDataSource()
        viewController.dataSource = dataSource
        
        dataSource.formatterService = appDelegate.applicationManager.formatterService
    }
}
