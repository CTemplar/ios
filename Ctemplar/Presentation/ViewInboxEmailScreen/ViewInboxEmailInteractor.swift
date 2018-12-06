//
//  ViewInboxEmailInteractor.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 01.11.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import AlertHelperKit
import PKHUD

class ViewInboxEmailInteractor {
    
    var viewController      : ViewInboxEmailViewController?
    var presenter           : ViewInboxEmailPresenter?
    var apiService          : APIService?
    var pgpService          : PGPService?
    var formatterService    : FormatterService?
    

    func setMessageData(message: EmailMessage) {
        
        self.viewController?.message = message
        self.viewController?.messageIsRead = message.read
        self.viewController?.messageIsStarred = message.starred
        
        if let children = message.children {

            if children.count > 0 {
                self.viewController?.messagesTableView.isHidden = false
                self.viewController?.dataSource?.messagesArray = message.children!
                self.viewController?.dataSource?.messagesArray.insert(message, at: 0) //add parent Message
                
                for _ in (self.viewController?.dataSource?.messagesArray)! {
                    self.viewController?.dataSource?.showDetailMessagesArray.append(false)
                    self.viewController?.dataSource?.showContentMessagesArray.append(false)
                }
                
                self.updateMessageContent(emailsArray: (self.viewController?.dataSource?.messagesArray)!)
                
                if let messagesCount = self.viewController?.dataSource?.messagesArray.count {
                    self.viewController?.dataSource?.showContentMessagesArray[messagesCount - 1] = true
                }
                
                self.viewController?.dataSource?.reloadData(scrollToLastMessage: true)
            }
        } else {
            self.viewController?.dataSource?.messagesArray.append(message)
            self.viewController?.dataSource?.showDetailMessagesArray.append(false)
            self.viewController?.dataSource?.showContentMessagesArray.append(true)
            self.updateMessageContent(emailsArray: (self.viewController?.dataSource?.messagesArray)!)
            self.viewController?.dataSource?.reloadData(scrollToLastMessage: false)
        }
        
        self.presenter?.setupMessageHeader(message: message)
        self.presenter?.setupNavigationBar(enabled: true)
        self.presenter?.setupBottomBar(enabled: true)     
    }
    
    func setMessages(messages: EmailMessagesList) {
        
        if let emailsArray = messages.messagesList {
            if emailsArray.count > 0 {
                self.setMessageData(message: emailsArray.first!)
            }
        }
    }
    
    func getMessage(messageID: Int) {
        
        HUD.show(.progress)
        
        apiService?.messagesList(folder: "", messagesIDIn: messageID.description, seconds: 0) {(result) in
            
            switch(result) {
                
            case .success(let value):
                //print("value:", value)
  
                let emailMessages = value as! EmailMessagesList
                self.setMessages(messages: emailMessages)
                                
            case .failure(let error):
                print("error:", error)
                AlertHelperKit().showAlert(self.viewController!, title: "Messages Error", message: error.localizedDescription, button: "closeButton".localized())
            }
            
            HUD.hide()
        }
    }
    
    func updateMessageContent(emailsArray: Array<EmailMessage>) {
        
        self.viewController?.dataSource?.dercyptedMessagesArray.removeAll()
        
        /*
        for (index, message) in emailsArray.enumerated() {
            if let messageContent = message.content {
                //self.viewController?.dataSource?.dercyptedMessagesArray.append("decoding...")
                //self.decryptMessage(content: messageContent, index: index)
            } else {
                self.viewController?.dataSource?.dercyptedMessagesArray.append("Empty content")
            }
        }*/
        
        HUD.show(.progress)
        
        for message in emailsArray {
            //DispatchQueue.main.async {
                let messageContent = self.extractMessageContent(message: message)
                self.viewController?.dataSource?.dercyptedMessagesArray.append(messageContent)
           // }
        }
        
        self.viewController?.dataSource?.reloadData(scrollToLastMessage: false)
        
        HUD.hide()
    }
    
    func decryptMessage(content: String, index: Int) {
        
        let queue = DispatchQueue.global(qos: .userInitiated)
        
        queue.async {
            
            if let message = self.pgpService?.decryptMessage(encryptedContet: content) {
                DispatchQueue.main.async {
                    //print("message:", message)
                    self.setDecryptedContent(content: message, index: index)
                }
            }
        }
    }
    
    func setDecryptedContent(content: String, index: Int) {
        
        if (self.viewController?.dataSource?.dercyptedMessagesArray.count)! > index {
            self.viewController?.dataSource?.dercyptedMessagesArray[index] = content
            self.viewController?.dataSource?.reloadData(scrollToLastMessage: false)
        }
    }
    
    func extractMessageContent(message: EmailMessage) -> String {
        
        if let content = message.content {            
            if let message = self.pgpService?.decryptMessage(encryptedContet: content) {
                //print("decrypt viewed message: ", message)
                return message
            }
        }
        
        return "Error"
    }
    
    func extractMessageContentAsync(message: EmailMessage) {
        
        let queue = DispatchQueue.global(qos: .userInitiated)
        
        queue.async {
            if let content = message.content {
                if let decryptedMessage = self.pgpService?.decryptMessage(encryptedContet: content) {
                    DispatchQueue.main.async {
                        //print("message:", message)
                       self.viewController?.contentTextView.attributedText = decryptedMessage.html2AttributedString
                    }
                }
            }
        }
    }
    
    func headerOfMessage(content: String) -> String {
        
        var header : String = ""
        var message : String = ""
        
        message = content
        message = message.removeHTMLTag
        
        if message.count > 0 {
            
            if message.count > k_firstCharsForHeader {
                let index = message.index(message.startIndex, offsetBy: k_firstCharsForHeader)
                header = String(message.prefix(upTo: index))
            } else {
                header = message
            }
        }
        
        header = header.replacingOccurrences(of: "\\s", with: " ", options: String.CompareOptions.regularExpression)
        
        return header
    }
    
    func moveMessageToTrash(message: EmailMessage, withUndo: String) {
        
        self.viewController?.lastAction = ActionsIndex.moveToTrach
        
        var folder = message.folder
        
        if withUndo.count > 0 {
            folder = MessagesFoldersName.trash.rawValue
        }
        
        self.moveMessageTo(message: message, folder: folder!, withUndo: withUndo)
    }
    
    func moveMessageToSpam(message: EmailMessage, withUndo: String) {
        
        self.viewController?.lastAction = ActionsIndex.markAsSpam
        
        var folder = message.folder
        
        if withUndo.count > 0 {
            folder = MessagesFoldersName.spam.rawValue
        }
        
        self.moveMessageTo(message: message, folder: folder!, withUndo: withUndo)
    }
    
    func moveMessageToInbox(message: EmailMessage, withUndo: String) {
        
        self.viewController?.lastAction = ActionsIndex.moveToInbox
        
        var folder = message.folder
        
        if withUndo.count > 0 {
            folder = MessagesFoldersName.inbox.rawValue
        }
        
        self.moveMessageTo(message: message, folder: folder!, withUndo: withUndo)
    }
    
    func moveMessageToArchive(message: EmailMessage, withUndo: String) {
        
        self.viewController?.lastAction = ActionsIndex.moveToArchive
        
        var folder = message.folder
        
        if withUndo.count > 0 {
            folder = MessagesFoldersName.archive.rawValue
        }
        
        self.moveMessageTo(message: message, folder: folder!, withUndo: withUndo)
    }
/*
    func markMessageAsStarred(message: EmailMessage, starred: Bool, withUndo: String) {
     
        self.viewController?.lastAction = ActionsIndex.markAsStarred
        
    }*/
    
    //MARK: - API requests
    
    func moveMessageTo(message: EmailMessage, folder: String, withUndo: String) {
        
        apiService?.updateMessages(messageID: (message.messsageID?.description)!, messagesIDIn: "", folder: folder, starred: false, read: false, updateFolder: true, updateStarred: false, updateRead: false)  {(result) in
            
            switch(result) {
                
            case .success( _):
                //print("value:", value)
                print("move message to:", folder)
                
                self.postUpdateInboxNotification()
                
                if withUndo.count > 0 {
                    self.presenter?.showUndoBar(text: withUndo)
                }
                
            case .failure(let error):
                print("error:", error)
                AlertHelperKit().showAlert(self.viewController!, title: "Messages Error", message: error.localizedDescription, button: "closeButton".localized())
            }
        }
    }
    
    func markMessageAsRead(message: EmailMessage, asRead: Bool, withUndo: String) {
        
        self.viewController?.lastAction = ActionsIndex.markAsRead
        
        apiService?.updateMessages(messageID: message.messsageID!.description, messagesIDIn: "", folder: message.folder!, starred: false, read: asRead, updateFolder: false, updateStarred: false, updateRead: true)  {(result) in
            
            switch(result) {
                
            case .success( _):
                //print("value:", value)
                print("mark message as read:", asRead)
                
                self.viewController?.messageIsRead = asRead
                
                self.postUpdateInboxNotification()
                
                if withUndo.count > 0 {
                    self.presenter?.showUndoBar(text: withUndo)
                }
                
            case .failure(let error):
                print("error:", error)
                AlertHelperKit().showAlert(self.viewController!, title: "Messages Error", message: error.localizedDescription, button: "closeButton".localized())
            }
        }
    }
    
    func markMessageAsStarred(message: EmailMessage, starred: Bool, withUndo: String) {
        
        //self.viewController?.lastAction = ActionsIndex.markAsStarred
        
        apiService?.updateMessages(messageID: message.messsageID!.description, messagesIDIn: "", folder: message.folder!, starred: starred, read: false, updateFolder: false, updateStarred: true, updateRead: false)  {(result) in
            
            switch(result) {
                
            case .success( _):
                //print("value:", value)
                print("mark message as starred:", starred)
                
                self.viewController?.messageIsStarred = starred
                
                self.presenter?.setupStarredButton(starred: starred)
                
                self.postUpdateInboxNotification()
                /*
                if withUndo.count > 0 {
                    self.presenter?.showUndoBar(text: withUndo)
                }*/
                
            case .failure(let error):
                print("error:", error)
                AlertHelperKit().showAlert(self.viewController!, title: "Messages Error", message: error.localizedDescription, button: "closeButton".localized())
            }
        }
    }
    
    func undoLastAction(message: EmailMessage) {
        
        self.presenter?.hideUndoBar()
        
        print("undo pressed")
        
        switch self.viewController?.lastAction.rawValue {
        case ActionsIndex.markAsSpam.rawValue:
            self.moveMessageToSpam(message: message, withUndo: "")
            break
        case ActionsIndex.markAsRead.rawValue:
            self.markMessageAsRead(message: message, asRead: message.read!, withUndo: "")
            break
        case ActionsIndex.markAsStarred.rawValue:
            self.markMessageAsStarred(message: message, starred: message.starred!, withUndo: "")
            break
        case ActionsIndex.moveToArchive.rawValue:
            self.moveMessageToArchive(message: message, withUndo: "")
            break
        case ActionsIndex.moveToTrach.rawValue:
            self.moveMessageToTrash(message: message, withUndo: "")
            break
        case ActionsIndex.moveToInbox.rawValue:
            self.moveMessageToInbox(message: message, withUndo: "")
            break
        default:
            print("unknown undo action")
        }
    }
    
    func postUpdateInboxNotification() {
        
        let silent = true
        
        NotificationCenter.default.post(name: Notification.Name(k_updateInboxMessagesNotificationID), object: silent, userInfo: nil)
    }
    
    //MARK: - Share Attachment
    
    func showShareScreen(url: URL) {
        
        self.viewController?.documentInteractionController.url = url
        self.viewController?.documentInteractionController.uti = url.typeIdentifier ?? "public.data, public.content"
        self.viewController?.documentInteractionController.name = url.localizedName ?? url.lastPathComponent
        self.viewController?.documentInteractionController.presentPreview(animated: true)
    }
    
    func downloadAndStoreAttachment(withURLString: String) {
        
        guard let url = URL(string: withURLString) else { return }
        
        HUD.show(.progress)
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            
            guard let data = data, error == nil else { return }
            
            let tempLocalURL = FileManager.default.temporaryDirectory
                .appendingPathComponent(response?.suggestedFilename ?? "default")
            do {
                try data.write(to: tempLocalURL)
            } catch {
                print(error)
            }
            
            DispatchQueue.main.async {
                HUD.hide()
                self.showShareScreen(url: tempLocalURL)
            }
            
        }.resume()
    }
}
