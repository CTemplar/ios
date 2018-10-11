//
//  InboxInteractor.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 11.10.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import AlertHelperKit

class InboxInteractor {
    
    var viewController  : InboxViewController?
    var presenter       : InboxPresenter?
    var apiService      : APIService?

    func setInboxData(messages: EmailMessagesList) {
        
        var readEmails = 0
        
        if let emailsArray = messages.messagesList {
            //self.viewController?.messagesList = emailsArray
            self.viewController?.dataSource?.messagesArray = emailsArray
            self.viewController?.dataSource?.reloadData()
            readEmails = calculateReadEmails(array: emailsArray)
        }
        
        if let totalEmailsCount = messages.totalCount {
            var unreadEmails = 0
            unreadEmails = totalEmailsCount - readEmails
            self.presenter?.setupUI(emailsCount: totalEmailsCount, unreadEmails: unreadEmails)
        }
    }
    
    func calculateReadEmails(array: Array<EmailMessage>) -> Int {
        
        var readEmails = 0
        
        for email in array {
            if let read = email.read {
                if read == true {
                    readEmails = readEmails + 1
                }
            }
        }
        
        return readEmails
    }
    
    func messagesList() {
        
        apiService?.messagesList() {(result) in
            
            switch(result) {
                
            case .success(let value):
                //print("value:", value)
                
                let emailMessages = value as! EmailMessagesList
                self.setInboxData(messages: emailMessages)
                /*
                var messagesArray : Array<EmailMessage> = []
                
                let emailMessages = value as! EmailMessagesList
                
                for result in emailMessages.messagesList! {
                    //print("result", result)
                    messagesArray.append(result)
                }
                
                self.setInboxData(array: messagesArray)
                */
            case .failure(let error):
                print("error:", error)
                AlertHelperKit().showAlert(self.viewController!, title: "Messages Error", message: error.localizedDescription, button: "Close")
            }
        }
    }
}
