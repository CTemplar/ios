//
//  SettingsPresenter.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 20.12.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import AlertHelperKit
import PKHUD

class SettingsPresenter {
    
    var viewController   : SettingsViewController?
    var interactor       : SettingsInteractor?

    func logOut() {
        
        let params = Parameters(
            title: "logoutTitle".localized(),
            message: "logotuMessage".localized(),
            cancelButton: "cancelButton".localized(),
            otherButtons: ["logotButton".localized()]
        )
        
        AlertHelperKit().showAlertWithHandler(self.viewController!, parameters: params) { buttonIndex in
            switch buttonIndex {
            case 0:
                print("Cancel Logout")
            default:
                print("LogOut")
                self.interactor?.logOut()
            }
        }
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
