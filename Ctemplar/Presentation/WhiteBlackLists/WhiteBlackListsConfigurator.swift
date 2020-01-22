//
//  WhiteBlackListsConfigurator.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 27.12.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import UIKit

class WhiteBlackListsConfigurator {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    func configure(viewController : WhiteBlackListsViewController) {
        
        let router = WhiteBlackListsRouter()
        router.viewController = viewController
        
        let presenter = WhiteBlackListsPresenter()
        presenter.viewController = viewController
        
        let interactor = WhiteBlackListsInteractor()
        interactor.presenter = presenter
        interactor.viewController = viewController
        interactor.apiService = appDelegate.applicationManager.apiService
        
        presenter.interactor = interactor
        
        viewController.presenter = presenter
        viewController.router = router
        
        let dataSource = WhiteBlackListsDataSource()
        viewController.dataSource = dataSource
        
        dataSource.formatterService = appDelegate.applicationManager.formatterService
    }
}
