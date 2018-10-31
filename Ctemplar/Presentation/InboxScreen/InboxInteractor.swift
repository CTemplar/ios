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
    
    //MARK: - data

    func updateMessages() {
        
        if self.checkStoredPGPKeys() {
            self.messagesList(folder: (self.viewController?.currentFolderFilter)!)
        }
    }
    
    func setInboxData(messages: EmailMessagesList) {
        
        var readEmails = 0
        var unreadEmails = 0
        
        if let emailsArray = messages.messagesList {

            //self.viewController?.messagesList = emailsArray//
            self.viewController?.dataSource?.messagesArray = emailsArray
            self.updateMessagesHeader(emailsArray: emailsArray)
            self.viewController?.dataSource?.reloadData()
            
            readEmails = calculateReadEmails(array: emailsArray)
            unreadEmails = emailsArray.count - readEmails
            
            self.presenter?.setupUI(emailsCount: emailsArray.count, unreadEmails: unreadEmails)
        }
    }
    
    func setSideMenuData(messages: EmailMessagesList) {
        
        var readEmails = 0
        var unreadEmails = 0
        
        if let emailsArray = messages.messagesList {
            
            self.viewController?.mainFoldersUnreadMessagesCount.removeAll()
            
            for filter in MessagesFoldersName.allCases {
                let messages = filterInboxMessages(array: emailsArray, filter: filter.rawValue)
                readEmails = calculateReadEmails(array: messages)
                
                unreadEmails = messages.count - readEmails
                print("filter:", filter, "unreadEmails:", unreadEmails)
                self.viewController?.mainFoldersUnreadMessagesCount.append(unreadEmails)
            }
            // for all message case
            readEmails = calculateReadEmails(array: emailsArray)
            unreadEmails = emailsArray.count - readEmails
            self.viewController?.mainFoldersUnreadMessagesCount.append(unreadEmails)
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
    
    //MARK: - API
    
    func messagesList(folder: String) {
        
        apiService?.messagesList(folder: folder) {(result) in
            
            switch(result) {
                
            case .success(let value):
                //print("value:", value)
                
                let emailMessages = value as! EmailMessagesList
                self.viewController?.currentMessagesList = emailMessages
                self.setInboxData(messages: emailMessages)
                
                self.allMessagesList()
                
            case .failure(let error):
                print("error:", error)
                AlertHelperKit().showAlert(self.viewController!, title: "Messages Error", message: error.localizedDescription, button: "closeButton".localized())
            }
        }
    }
    
    func allMessagesList() {
        
        apiService?.messagesList(folder: "") {(result) in
            
            switch(result) {
                
            case .success(let value):
                //print("value:", value)
                
                let emailMessages = value as! EmailMessagesList
                self.setSideMenuData(messages: emailMessages)
                
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
    
    //MARK: - message headers

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
    
    //MARK: - filters
    
    func filterInboxMessages(array: Array<EmailMessage>, filter: String) -> Array<EmailMessage> {
        
        var inboxMessagesArray : Array<EmailMessage> = []
        
        for message in array {
            if message.folder == filter {
                inboxMessagesArray.append(message)
            }
        }
        
        return inboxMessagesArray
    }
    
    func updateMessagesHeader(emailsArray: Array<EmailMessage>) {
        
        self.viewController?.dataSource?.messagesHeaderArray.removeAll()
        
        for message in emailsArray {
            if let messageContent = message.content {
                let header = self.headerOfMessage(contet: messageContent)
                self.viewController?.dataSource?.messagesHeaderArray.append(header)
            }
        }
    }
    
    func clearFilters() {
        
        self.viewController?.appliedFilters = [false, false, false]
        self.viewController?.inboxFilterView?.setup(appliedFilters: (self.viewController?.appliedFilters)!)
    }
    
    func applyFilters() {
        
        var filteredMessagesArray : Array<EmailMessage> = (self.viewController?.currentMessagesList?.messagesList)!
        
        for (index, filterApplied) in (self.viewController?.appliedFilters)!.enumerated() {
                 
            switch index + 202 {
            case InboxFilterButtonsTag.starred.rawValue:
                print("starred filtered")
                if filterApplied == true {
                    filteredMessagesArray = self.filterStarredMessages(messagesArray: filteredMessagesArray)
                }
                break
            case InboxFilterButtonsTag.unread.rawValue:
                print("unread filtered")
                if filterApplied == true {
                    filteredMessagesArray = self.filterUnreadMessages(messagesArray: filteredMessagesArray)
                }
                break
            case InboxFilterButtonsTag.withAttachment.rawValue:
                print("with attachment filtered")
                if filterApplied == true {
                    filteredMessagesArray = self.filterWithAttachmentMessages(messagesArray: filteredMessagesArray)
                }
                break
            default:
                print("default")
            }
        }
        
        self.viewController?.dataSource?.messagesArray = filteredMessagesArray
        self.updateMessagesHeader(emailsArray: filteredMessagesArray)
        self.viewController?.dataSource?.reloadData()        
    }
    
    func filterStarredMessages(messagesArray: Array<EmailMessage>) -> Array<EmailMessage> {
    
        var starredMessagesArray : Array<EmailMessage> = []
        
        for message in messagesArray {
            
            if let starred = message.starred {
                if starred {
                    starredMessagesArray.append(message)
                }
            }
        }
        
        return starredMessagesArray
    }
    
    func filterUnreadMessages(messagesArray: Array<EmailMessage>) -> Array<EmailMessage> {
        
        var unredMessagesArray : Array<EmailMessage> = []
        
        for message in messagesArray {
            
            if let read = message.read {
                if !read {
                    unredMessagesArray.append(message)
                }
            }
        }
        
        return unredMessagesArray
    }
    
    func filterWithAttachmentMessages(messagesArray: Array<EmailMessage>) -> Array<EmailMessage> {
        
        var withAttachmentMessagesArray : Array<EmailMessage> = []
        
        for message in messagesArray {
            
            if let attachments = message.attachments {
                if attachments.count > 0 {
                    withAttachmentMessagesArray.append(message)
                }
            }
        }
        
        return withAttachmentMessagesArray
    }
    
    //MARK: - Swipe Actions
    
    func markMessageAsSpam(message: EmailMessage) {
        
        var folder = message.folder
        
        if folder != MessagesFoldersName.spam.rawValue {
            folder = MessagesFoldersName.spam.rawValue
        }
        
        apiService?.updateMessages(messageID: (message.messsageID?.description)!, messagesIDIn: "", folder: folder!, starred: message.starred!, read: message.read!)  {(result) in
            
            switch(result) {
                
            case .success(let value):
                //print("value:", value)
                print("marked as spam")
                self.viewController?.presenter?.showUndoBar(text: "Undo mark as Spam")
                self.updateMessages()
                
            case .failure(let error):
                print("error:", error)
                AlertHelperKit().showAlert(self.viewController!, title: "Messages Error", message: error.localizedDescription, button: "closeButton".localized())
            }
        }
    }
    
    func markMessageAsRead(message: EmailMessage) {
        
        let read = !message.read!
        
        apiService?.updateMessages(messageID: (message.messsageID?.description)!, messagesIDIn: "", folder: message.folder!, starred: message.starred!, read: read)  {(result) in
            
            switch(result) {
                
            case .success(let value):
                //print("value:", value)
                print("marked as read/unread")
                self.viewController?.presenter?.showUndoBar(text: "Undo mark as Read")
                self.updateMessages()
                
            case .failure(let error):
                print("error:", error)
                AlertHelperKit().showAlert(self.viewController!, title: "Messages Error", message: error.localizedDescription, button: "closeButton".localized())
            }
        }
    }
    
    func markMessageAsTrash(message: EmailMessage) {
        
        var folder = message.folder
        
        if folder != MessagesFoldersName.trash.rawValue {
            folder = MessagesFoldersName.trash.rawValue
        }
        
        apiService?.updateMessages(messageID: (message.messsageID?.description)!, messagesIDIn: "", folder: folder!, starred: message.starred!, read: message.read!)  {(result) in
            
            switch(result) {
                
            case .success(let value):
                //print("value:", value)
                print("marked as trash")
                self.viewController?.presenter?.showUndoBar(text: "Undo delete")
                self.updateMessages()
                
            case .failure(let error):
                print("error:", error)
                AlertHelperKit().showAlert(self.viewController!, title: "Messages Error", message: error.localizedDescription, button: "closeButton".localized())
            }
        }
    }
    
    func undoLastAction(message: EmailMessage) {
        
        apiService?.updateMessages(messageID: (message.messsageID?.description)!, messagesIDIn: "", folder: message.folder!, starred: message.starred!, read: message.read!)  {(result) in
            
            switch(result) {
                
            case .success(let value):
                //print("value:", value)
                print("undo last action")
                self.viewController?.undoBar.isHidden = true
                self.updateMessages()
                
            case .failure(let error):
                print("error:", error)
                AlertHelperKit().showAlert(self.viewController!, title: "Messages Error", message: error.localizedDescription, button: "closeButton".localized())
            }
        }
        
    }
    
    //MARK: - Selection Bar Actions
    
    func markMessagesListAsRead(selectedMessagesIdArray: Array<Int>, lastSelectedMessage: EmailMessage) {
        
        let read = !lastSelectedMessage.read!
        
        var messagesIDList : String = ""
        
        for message in selectedMessagesIdArray {
            messagesIDList = messagesIDList + message.description + ","
        }
        
        messagesIDList.remove(at: messagesIDList.index(before: messagesIDList.endIndex)) //remove last ","
        
        apiService?.updateMessages(messageID: "", messagesIDIn: messagesIDList, folder: lastSelectedMessage.folder!, starred: lastSelectedMessage.starred!, read: read)  {(result) in
            
            switch(result) {
                
            case .success(let value):
                //print("value:", value)
                print("marked list as read/unread")
                //self.viewController?.presenter?.showUndoBar(text: "Undo mark as Read")
                self.updateMessages()
                
            case .failure(let error):
                print("error:", error)
                AlertHelperKit().showAlert(self.viewController!, title: "Messages Error", message: error.localizedDescription, button: "closeButton".localized())
            }
        }
    }
    
    func markMessagesListAsTrash(selectedMessagesIdArray: Array<Int>, lastSelectedMessage: EmailMessage) {
        
        var folder = lastSelectedMessage.folder
        
        if folder != MessagesFoldersName.trash.rawValue {
            folder = MessagesFoldersName.trash.rawValue
        }
        
        var messagesIDList : String = ""
        
        for message in selectedMessagesIdArray {
            messagesIDList = messagesIDList + message.description + ","
        }
        
        messagesIDList.remove(at: messagesIDList.index(before: messagesIDList.endIndex)) //remove last ","
        
        apiService?.updateMessages(messageID: "", messagesIDIn: messagesIDList, folder: folder!, starred: lastSelectedMessage.starred!, read: lastSelectedMessage.read!)  {(result) in
            
            switch(result) {
                
            case .success(let value):
                //print("value:", value)
                print("marked list as read/unread")
                //self.viewController?.presenter?.showUndoBar(text: "Undo mark as Read")
                self.updateMessages()
                
            case .failure(let error):
                print("error:", error)
                AlertHelperKit().showAlert(self.viewController!, title: "Messages Error", message: error.localizedDescription, button: "closeButton".localized())
            }
        }
    }
}
