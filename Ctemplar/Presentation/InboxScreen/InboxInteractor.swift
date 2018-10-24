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
    var pgpService      : PGPService?

    func setInboxData(messages: EmailMessagesList) {
        
        var readEmails = 0
        
        if let emailsArray = messages.messagesList {
            //self.viewController?.messagesList = emailsArray
            let inboxMessages = filterInboxMessages(array: emailsArray)
            self.viewController?.dataSource?.messagesArray = inboxMessages
            self.viewController?.dataSource?.reloadData()
            readEmails = calculateReadEmails(array: inboxMessages)
            
            var unreadEmails = 0
            unreadEmails = inboxMessages.count - readEmails
            self.presenter?.setupUI(emailsCount: inboxMessages.count, unreadEmails: unreadEmails)
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
                
            case .failure(let error):
                print("error:", error)
                AlertHelperKit().showAlert(self.viewController!, title: "Messages Error", message: error.localizedDescription, button: "Close")
            }
        }
    }
    

    func decryptMessage(contet: String) -> String {
        
        if let message = self.pgpService?.decryptMessage(encryptedContet: contet) {
            //print("decrypt message: ", message)
            return message
        }
        
        return ""
    }
    
    
    func headerOfMessage(contet: String) -> String {
        
        var header : String = ""
        var message = self.decryptMessage(contet: contet)

        //message = message.html2String
        //print("format to String message: ", message)
        message = message.removeHTMLTag
        print("withoutHtml message:", message)
        
        if message.count > 0 {
            
            if message.count > k_firstCharsForHeader {
                let index = message.index(message.startIndex, offsetBy: k_firstCharsForHeader)                
                header = String(message.prefix(upTo: index))//.replacingOccurrences(of: "\n", with: "", options: String.CompareOptions.regularExpression)
            } else {
                header = message
            }
        }
                
        print("header:", header)
        
        return header
    }
    
    func filterInboxMessages(array: Array<EmailMessage>) -> Array<EmailMessage> {
        
        var inboxMessagesArray : Array<EmailMessage> = []
        
        for message in array {
            if message.folder == MessagesFoldersName.inbox.rawValue {
                inboxMessagesArray.append(message)
            }
        }
        
        return inboxMessagesArray
    }
}
