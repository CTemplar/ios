//
//  PgpKeysConfigurator.swift
//  Ctemplar
//
//  Created by Majid Hussain on 07/03/2020.
//  Copyright © 2020 CTemplar. All rights reserved.
//

import UIKit

class PgpKeysConfigurator {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    func configure(with viewController: PgpKeysViewController) {
        
        let presenter = PgpKeysPresenter()
        presenter.viewController = viewController
        
        let interactor = PgpKeysInteractor()
        interactor.apiService = appDelegate.applicationManager.apiService
        interactor.viewController = viewController
        interactor.presenter = presenter
        
        presenter.interactor = interactor
        
        viewController.presenter = presenter
        
        let dataSource = PgpKeysDatasource()
        dataSource.viewController = viewController
        
        viewController.dataSource = dataSource
        
    }
}
