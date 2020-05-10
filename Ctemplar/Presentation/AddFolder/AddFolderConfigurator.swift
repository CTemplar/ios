//
//  AddFolderConfigurator.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 19.12.2018.
//  Copyright © 2018 CTemplar. All rights reserved.
//

import Foundation
import UIKit

class AddFolderConfigurator {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    func configure(viewController : AddFolderViewController) {
        
        let interactor = AddFolderInteractor()
        interactor.viewController = viewController
        interactor.apiService = appDelegate.applicationManager.apiService
        interactor.formatterService = appDelegate.applicationManager.formatterService
        
        viewController.interactor = interactor
    }
}
