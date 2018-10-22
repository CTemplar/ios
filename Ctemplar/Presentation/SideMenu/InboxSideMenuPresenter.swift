//
//  InboxSideMenuPresenter.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 22.10.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import AlertHelperKit
import PKHUD

class InboxSideMenuPresenter {
    
    var viewController   : InboxSideMenuViewController?
    var interactor       : InboxSideMenuInteractor?

    func logOut() {
        
         //temp: ======================
        let params = Parameters(
            title: "",
            message: "Do you want to Logout?",
            cancelButton: "Cancel",
            otherButtons: ["Logout"]
        )
        
        AlertHelperKit().showAlertWithHandler(self.viewController!, parameters: params) { buttonIndex in
            switch buttonIndex {
            case 0:
                print("Cancel")
            default:
                print("LogOut")
                self.interactor?.logOut()
            }
        }
    }
    
}
