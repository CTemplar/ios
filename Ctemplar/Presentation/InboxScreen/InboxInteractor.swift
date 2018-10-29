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
           
            //let inboxMessages = filterInboxMessages(array: emailsArray)
            self.viewController?.dataSource?.messagesArray = emailsArray
            
            self.viewController?.dataSource?.messagesHeaderArray.removeAll()
            
            for message in emailsArray {
                if let messageContent = message.content {
                    let header = self.headerOfMessage(contet: messageContent)
                    self.viewController?.dataSource?.messagesHeaderArray.append(header)
                }
            }            
            
            self.viewController?.dataSource?.reloadData()
            readEmails = calculateReadEmails(array: emailsArray)
            
            var unreadEmails = 0
            unreadEmails = emailsArray.count - readEmails
            self.presenter?.setupUI(emailsCount: emailsArray.count, unreadEmails: unreadEmails)
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
    
    func messagesList(folder: String) {
        
        apiService?.messagesList(folder: folder) {(result) in
            
            switch(result) {
                
            case .success(let value):
                //print("value:", value)
                
                let emailMessages = value as! EmailMessagesList
                self.setInboxData(messages: emailMessages)
                
            case .failure(let error):
                print("error:", error)
                AlertHelperKit().showAlert(self.viewController!, title: "Messages Error", message: error.localizedDescription, button: "closeButton".localized())
            }
        }
    }
    
    func checkStoredPGPKeys() -> Bool {
        
        if pgpService?.getStoredPGPKeys() == nil {
            self.mailboxesList(storeKeys: true)
        } else {
            print("local PGPKeys exist")
            self.mailboxesList(storeKeys: false)            
            return true
        }
        
        return false
    }
    
    func mailboxesList(storeKeys: Bool) {
        
        apiService?.mailboxesList() {(result) in
            
            switch(result) {
                
            case .success(let value):
                //print("Mailboxes value:", value)
                
                let mailboxes = value as! Mailboxes
                
                if let mailboxesList = mailboxes.mailboxesResultsList {

                    self.viewController?.mailboxesList = mailboxesList
                    
                    for mailbox in mailboxesList{
                        //print("mailbox", mailbox)
                        //print("privateKey:", mailbox.privateKey as Any)
                        //print("publicKey:", mailbox.publicKey as Any)
                        
                        if storeKeys == true {
                            if let privateKey = mailbox.privateKey {
                                self.pgpService?.extractAndSavePGPKeyFromString(key: privateKey)
                            }
                        
                            if let publicKey = mailbox.privateKey {
                                self.pgpService?.extractAndSavePGPKeyFromString(key: publicKey)
                            }
                            
                            //load messages after keys storred
                            self.messagesList(folder: (self.viewController?.currentFolderFilter)!)
                        }
                    }
                }
                
            case .failure(let error):
                print("error:", error)
                AlertHelperKit().showAlert(self.viewController!, title: "Mailboxes Error", message: error.localizedDescription, button: "closeButton".localized())
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
        var message : String = ""
        
        message = self.decryptMessage(contet: contet)

        //message = message.html2String
        //print("format to String message: ", message)
        message = message.removeHTMLTag
        //print("withoutHtml message:", message)
        
        if message.count > 0 {
            
            if message.count > k_firstCharsForHeader {
                let index = message.index(message.startIndex, offsetBy: k_firstCharsForHeader)                
                header = String(message.prefix(upTo: index))
            } else {
                header = message
            }
        }
        
        header = header.replacingOccurrences(of: "\\s", with: " ", options: String.CompareOptions.regularExpression)
                
        //print("header:", header)
        
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
