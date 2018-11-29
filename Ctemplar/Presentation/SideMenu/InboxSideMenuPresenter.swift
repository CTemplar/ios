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
        
    func setupUserProfileBar(mailboxes: Array<Mailbox>, userName: String) {
 
        for mailbox in mailboxes {
            if let defaultMailbox = mailbox.isDefault {
                if defaultMailbox {
                    if let defaultEmail = mailbox.email {
                        self.viewController!.emailLabel.text = defaultEmail
                        //self.viewController!.nameLabel.text = mailbox.displayName
                        self.viewController!.nameLabel.text = userName                        
                    }
                }
            }
        }
         
         let emailTextWidth = self.viewController!.emailLabel.text?.widthOfString(usingFont: viewController!.emailLabel.font)
         
         let triangleTrailingConstraintWidth = self.viewController!.view.frame.width - emailTextWidth! - CGFloat(k_triangleOffset)
         self.updateTriangleTrailingConstraint(value: triangleTrailingConstraintWidth )
         
         if mailboxes.count < 2 {
            self.viewController?.triangle.isHidden = true
         }
    }
    
    func updateTriangleTrailingConstraint(value: CGFloat) {
        
        DispatchQueue.main.async {
            self.viewController!.triangleTrailingConstraint.constant = value
            self.viewController!.view.layoutIfNeeded()
        }
    }

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
