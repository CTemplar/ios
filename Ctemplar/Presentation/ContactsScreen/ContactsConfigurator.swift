//
//  ContactsConfigurator.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 14.11.2018.
//  Copyright © 2018 CTemplar. All rights reserved.
//

import Foundation
import UIKit
import Networking
import Utility

class ContactsConfigurator {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    func configure(viewController : ContactsViewController) {
        
        let router = ContactsRouter()
        router.viewController = viewController
        
        let presenter = ContactsPresenter()
        presenter.viewController = viewController
        
        let interactor = ContactsInteractor()
        interactor.presenter = presenter
        interactor.viewController = viewController
        interactor.apiService = NetworkManager.shared.apiService
        
        presenter.interactor = interactor
        
        viewController.presenter = presenter
        viewController.router = router
        
        let dataSource = ContactsDataSource()
        viewController.dataSource = dataSource
        
        dataSource.formatterService = UtilityManager.shared.formatterService
    }
}
