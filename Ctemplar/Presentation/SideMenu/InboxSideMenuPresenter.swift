//
//  InboxSideMenuPresenter.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 22.10.2018.
//  Copyright © 2018 CTemplar. All rights reserved.
//

import Foundation
import Networking
import Utility

class InboxSideMenuPresenter {
    
    var viewController   : InboxSideMenuViewController?
    var interactor       : InboxSideMenuInteractor?
        
    func setupUserProfileBar(mailboxes: Array<Mailbox>, userName: String) {
        
        let mailbox = self.viewController?.presenter!.interactor!.apiService!.defaultMailbox(mailboxes: mailboxes)
        
        self.viewController!.emailLabel.text = mailbox?.email
        self.viewController!.nameLabel.text = userName
         
        if mailboxes.count < 2 {
           self.viewController?.triangle.isHidden = true
        }
    }

    func logOut() {
        let params = AlertKitParams(
            title: "logoutTitle".localized(),
            message: "logotuMessage".localized(),
            cancelButton: "cancelButton".localized(),
            otherButtons: ["logotButton".localized()]
        )
        viewController?.showAlert(with: params, onCompletion: { [weak self] (index) in
            switch index {
            case 0:
                DPrint("Cancel Logout")
            default:
                DPrint("Logout")
                self?.interactor?.logOut()
            }
        })
    }    
}
