//
//  ViewInboxEmailConfigurator.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 01.11.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import UIKit

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
        interactor.apiService = appDelegate.applicationManager.apiService
        interactor.pgpService = appDelegate.applicationManager.pgpService
        interactor.formatterService = appDelegate.applicationManager.formatterService
        
        presenter.interactor = interactor
        
        viewController.presenter = presenter
        viewController.router = router
        
    }
}
