//
//  WhiteBlackListsConfigurator.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 27.12.2018.
//  Copyright © 2018 CTemplar. All rights reserved.
//

import Foundation
import UIKit
import Networking
import Utility

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
        interactor.apiService = NetworkManager.shared.apiService
        
        presenter.interactor = interactor
        
        viewController.presenter = presenter
        viewController.router = router
        
        let dataSource = WhiteBlackListsDataSource()
        viewController.dataSource = dataSource
        
        dataSource.formatterService = UtilityManager.shared.formatterService
    }
}
