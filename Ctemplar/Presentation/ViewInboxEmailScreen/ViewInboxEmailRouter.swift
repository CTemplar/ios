//
//  ViewInboxEmailRouter.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 01.11.2018.
//  Copyright © 2018 CTemplar. All rights reserved.
//

import Foundation
import UIKit
import Inbox

class ViewInboxEmailRouter {
    
    var viewController: ViewInboxEmailViewController?
    
    func showMoveToViewController() {
        guard let id = viewController?.message?.messsageID,
            let user = viewController?.user else {
            return
        }
        
        let inboxCoordinator = InboxCoordinator()
        inboxCoordinator.showMoveToController(withMoveToDelegate: nil, selectedMessageIds: [id],
                                              user: user,
                                              presenter: viewController
        )
    }
    
    func showComposeViewController(answerMode: AnswerMessageMode, subject: String) {
        
        let storyboard: UIStoryboard = UIStoryboard(name: k_ComposeStoryboardName, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: k_ComposeViewControllerID) as! ComposeViewController
        
        vc.answerMode = answerMode
        //vc.mailboxesList = (self.viewController?.mailboxesList)!
        vc.user = (self.viewController?.user)!
        vc.message = self.viewController?.message
        vc.messagesArray = (self.viewController?.dataSource?.messagesArray)!
        vc.dercyptedMessagesArray = (self.viewController?.dataSource?.dercyptedMessagesArray)!
        vc.subject = subject
        self.viewController?.show(vc, sender: self)        
    }
    
    func backToParentViewController() {
        
        self.viewController?.navigationController?.popViewController(animated: true)
    }
}
