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
}
