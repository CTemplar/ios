//
//  EditFolderConfigurator.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 20.12.2018.
//  Copyright © 2018 CTemplar. All rights reserved.
//

import Foundation
import UIKit
import Utility
import Networking

class EditFolderConfigurator {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    func configure(viewController : EditFolderViewController) {
        
        let interactor = EditFolderInteractor()
        interactor.viewController = viewController
        interactor.apiService = NetworkManager.shared.apiService
        interactor.formatterService = UtilityManager.shared.formatterService
        
        viewController.interactor = interactor
    }
}
