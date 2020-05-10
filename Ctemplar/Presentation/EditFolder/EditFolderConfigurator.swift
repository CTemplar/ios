//
//  EditFolderConfigurator.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 20.12.2018.
//  Copyright © 2018 CTemplar. All rights reserved.
//

import Foundation
import UIKit

class EditFolderConfigurator {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    func configure(viewController : EditFolderViewController) {
        
        let interactor = EditFolderInteractor()
        interactor.viewController = viewController
        interactor.apiService = appDelegate.applicationManager.apiService
        interactor.formatterService = appDelegate.applicationManager.formatterService
        
        viewController.interactor = interactor
    }
}
