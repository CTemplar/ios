//
//  SettingsPresenter.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 20.12.2018.
//  Copyright © 2018 CTemplar. All rights reserved.
//

import Foundation
import Utility
import UIKit

class SettingsPresenter {
    
    var viewController   : SettingsViewController?
    var interactor       : SettingsInteractor?

    func logOut() {
        let params = AlertKitParams(
            title: "logoutTitle".localized(),
            message: "logotuMessage".localized(),
            cancelButton: "cancelButton".localized(),
            otherButtons: ["logotButton".localized()]
        )
        
        self.viewController?.showAlert(with: params, onCompletion: { [weak self] (index) in
            switch index {
            case 0:
                DPrint("Cancel Logout")
            default:
                DPrint("Logout")
                self?.interactor?.logOut()
            }
        })
    }
    
    func setupNavigationLeftItem() {
        
        let emptyButton = UIBarButtonItem(image: UIImage(), style: .done, target: self, action: nil)
        
        if UIDevice.current.orientation.isLandscape {
            print("Landscape")
            self.viewController?.navigationItem.leftBarButtonItem = emptyButton
        } else {
            print("Portrait")
            self.viewController?.navigationItem.leftBarButtonItem = self.viewController?.leftBarButtonItem
        }
    }
}
