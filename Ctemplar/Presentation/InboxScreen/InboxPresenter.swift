//
//  InboxPresenter.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 11.10.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import AlertHelperKit
import PKHUD

class InboxPresenter {
    
    var viewController   : InboxViewController?
    var interactor       : InboxInteractor?
    
    func loadMessages() {
        
        self.interactor?.messagesList()
    }
    
    func setupUI(emailsCount: Int, unreadEmails: Int) {
        
        viewController?.messagesLabel.text = formatEmailsCountText(emailsCount: emailsCount)
        viewController?.unreadMessagesLabel.text = formatUreadEmailsCountText(emailsCount: unreadEmails)
        
        if emailsCount > 0 {
            viewController?.emptyInbox.isHidden = true
            viewController?.advancedToolBar.isHidden = false
        } else {
            viewController?.emptyInbox.isHidden = false
            viewController?.advancedToolBar.isHidden = true
        }
        
        var composeImage: UIImage?
        
        if Device.IS_IPHONE_X_OR_ABOVE {
            viewController?.grayBorder.isHidden = true
            composeImage = UIImage.init(named: k_composeRedImageName)
            viewController?.rightComposeButton.backgroundColor = UIColor.white
        } else {
            viewController?.grayBorder.isHidden = false
            composeImage = UIImage.init(named: k_composeImageName)
            viewController?.rightComposeButton.backgroundColor = k_redColor
        }
        
        viewController?.rightComposeButton.setImage(composeImage, for: .normal)
    }
    
    func formatEmailsCountText(emailsCount: Int) -> String {
        
        var emailsCountString : String = "emails"
        
        emailsCountString = emailsCount.description + " " + emailsCountString
        
        return emailsCountString
    }
    func formatUreadEmailsCountText(emailsCount: Int) -> String {
        
        var emailsCountString : String = "unread"
        
        emailsCountString = emailsCount.description + " " + emailsCountString
        
        return emailsCountString
    }
}
