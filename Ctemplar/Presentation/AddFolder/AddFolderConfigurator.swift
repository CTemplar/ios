//
//  AddFolderConfigurator.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 19.12.2018.
//  Copyright © 2018 CTemplar. All rights reserved.
//

import Foundation
import UIKit
import Networking
import Utility

class AddFolderConfigurator {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    func configure(viewController : AddFolderViewController) {
        
        let interactor = AddFolderInteractor()
        interactor.viewController = viewController
        interactor.apiService = NetworkManager.shared.apiService
        interactor.formatterService = UtilityManager.shared.formatterService
        
        viewController.interactor = interactor
    }
}
