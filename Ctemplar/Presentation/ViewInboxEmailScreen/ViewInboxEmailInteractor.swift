//
//  ViewInboxEmailInteractor.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 01.11.2018.
//  Copyright © 2018 CTemplar. All rights reserved.
//

import Foundation
import Utility
import Networking

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
            } else {
                self.viewController?.dataSource?.messagesArray.append(message)
                self.viewController?.dataSource?.showDetailMessagesArray.append(false)
                self.viewController?.dataSource?.showContentMessagesArray.append(true)
                self.updateMessageContent(emailsArray: (self.viewController?.dataSource?.messagesArray)!)
                self.viewController?.dataSource?.reloadData(scrollToLastMessage: false)
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
        Loader.start()
        apiService?.messagesList(folder: "", messagesIDIn: messageID.description, seconds: 0, offset: -1) {(result) in
            
            switch(result) {
                
            case .success(let value):
                //print("getMessage:", value)
  
                let emailMessages = value as! EmailMessagesList
                self.setMessages(messages: emailMessages)
                                
            case .failure(let error):
                print("error:", error)
                self.viewController?.showAlert(with: "Messages Error",
                           message: error.localizedDescription,
                           buttonTitle: Strings.Button.closeButton.localized)
            }
            
            Loader.stop()
        }
    }
    
    func updateMessageContent(emailsArray: Array<EmailMessage>) {
        self.viewController?.dataSource?.dercyptedMessagesArray.removeAll()
        Loader.start()
        self.updateMessageContent1(emailsArray: emailsArray)
    }
    
    private func updateMessageContent1(emailsArray: Array<EmailMessage>) {
        if emailsArray.count == 0 {
            Loader.stop()
            self.viewController?.dataSource?.reloadData(scrollToLastMessage: false)
            return
        }
        var messages = emailsArray
        let message = messages.removeFirst()
        let messageContent = self.extractMessageContent(message: message)
        if messageContent == "#D_FAILED_ERROR#" {
            apiService?.mailboxesList(completionHandler: { (result) in
                switch result {
                case .success(let value):
                    let mailboxes = value as! Mailboxes
                    if let mailboxesList = mailboxes.mailboxesResultsList {
                        for mailbox in mailboxesList{
                            if (mailbox.isDefault ?? false) || mailboxesList.count == 1 {
                                if let privateKey = mailbox.privateKey {
                                    self.pgpService?.extractAndSavePGPKeyFromString(key: privateKey)
                                }
                                if let publicKey = mailbox.publicKey {
                                    self.pgpService?.extractAndSavePGPKeyFromString(key: publicKey)
                                }
                                break
                            }
                        }
                        self.updateMessageContent1(emailsArray: emailsArray)
                    }
                    break
                case .failure(_):
                    self.updateMessageContent1(emailsArray: [])
                    break
                }
            })
        }else {
            self.viewController?.dataSource?.dercyptedMessagesArray.append(messageContent)
            self.updateMessageContent1(emailsArray: messages)
        }
        
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
            //if message.isEncrypted == true {
              if (apiService?.isMessageEncrypted(message: message))! {
                if let decryptedContent = self.pgpService?.decryptMessage(encryptedContet: content) {
                    //print("decrypt viewed message: ", message)
                    return decryptedContent
                }
            } else {
                return content
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
    
    func updateSubject(message: EmailMessage) {
        
        if (apiService?.isSubjectEncrypted(message: message))! {
            if (viewController?.headerLabel.text ?? "") == "" {
                self.presenter?.setSubjectLabel(subject: "Decrypting...".localized())
            }
            self.extractSubjectContentAsync(message: message)
        } else {
            if let subjectText = message.subject {
                self.presenter?.setSubjectLabel(subject: subjectText)
            } else {
                self.presenter?.setSubjectLabel(subject: "Empty subject".localized())
            }
        }
    }
    
    func extractSubjectContentAsync(message: EmailMessage) {
        
        let queue = DispatchQueue.global(qos: .userInitiated)
        
        queue.async {
            if let content = message.subject {
                if let decryptedSubject = self.pgpService?.decryptMessage(encryptedContet: content) {
                    DispatchQueue.main.async {
                        self.presenter?.setSubjectLabel(subject: decryptedSubject)
                    }
                }
            }
        }
    }
    
    //MARK: - Move methods
    
    func moveMessageToTrash(message: EmailMessage,
                            withUndo: String,
                            onCompletion: @escaping ((Bool) -> Void)) {
        if self.viewController?.currentFolderFilter == MessagesFoldersName.trash.rawValue {
            self.viewController?.lastAction = ActionsIndex.delete
            self.deleteMessage(message: message, withUndo: "", onCompletion: onCompletion)
        } else {
            self.viewController?.lastAction = ActionsIndex.moveToTrach
            var folder = message.folder
            if !withUndo.isEmpty {
                folder = MessagesFoldersName.trash.rawValue
            }
            self.moveMessageTo(message: message,
                               folder: folder!,
                               withUndo: withUndo,
                               onCompletion: onCompletion)
        }
    }
    
    func moveMessageToSpam(message: EmailMessage,
                           withUndo: String,
                           onCompletion: ((Bool) -> Void)? = nil) {
        self.viewController?.lastAction = ActionsIndex.markAsSpam
        let folder = withUndo.isEmpty == false ? MessagesFoldersName.spam.rawValue : message.folder
        self.moveMessageTo(message: message, folder: folder!, withUndo: withUndo, onCompletion: onCompletion)
    }
    
    func moveMessageToInbox(message: EmailMessage, withUndo: String) {
        
        self.viewController?.lastAction = ActionsIndex.moveToInbox
        
        var folder = message.folder
        
        if withUndo.count > 0 {
            folder = MessagesFoldersName.inbox.rawValue
        }
        
        self.moveMessageTo(message: message, folder: folder!, withUndo: withUndo)
    }
    
    func moveMessageToArchive(message: EmailMessage,
                              withUndo: String,
                              onCompletion: @escaping ((Bool) -> Void)) {
        self.viewController?.lastAction = ActionsIndex.moveToArchive
        
        var folder = message.folder
        
        if !withUndo.isEmpty {
            folder = MessagesFoldersName.archive.rawValue
        }
        
        self.moveMessageTo(message: message,
                           folder: folder!,
                           withUndo: withUndo,
                           onCompletion: onCompletion)
    }
/*
    func markMessageAsStarred(message: EmailMessage, starred: Bool, withUndo: String) {
     
        self.viewController?.lastAction = ActionsIndex.markAsStarred
        
    }*/
    
    //MARK: - API requests
    
    func moveMessageTo(message: EmailMessage,
                       folder: String,
                       withUndo: String,
                       onCompletion: ((Bool) -> Void)? = nil) {
        apiService?.updateMessages(messageID: (message.messsageID?.description)!, messagesIDIn: "", folder: folder, starred: false, read: false, updateFolder: true, updateStarred: false, updateRead: false)  {(result) in
            switch(result) {
            case .success( _):
                print("move message to:", folder)
                self.postUpdateInboxNotification()
                if !withUndo.isEmpty {
                    self.presenter?.showUndoBar(text: withUndo)
                }
                onCompletion?(true)
            case .failure(let error):
                print("error:", error)
                self.viewController?.showAlert(with: "Messages Error",
                           message: error.localizedDescription,
                           buttonTitle: Strings.Button.closeButton.localized)
                onCompletion?(false)
            }
        }
    }
    
    func markMessageAsRead(message: EmailMessage,
                           asRead: Bool,
                           withUndo: String,
                           onCompletion: ((Bool) -> Void)? = nil) {
        viewController?.lastAction = ActionsIndex.markAsRead
        apiService?.updateMessages(messageID: message.messsageID!.description, messagesIDIn: "", folder: message.folder!, starred: false, read: asRead, updateFolder: false, updateStarred: false, updateRead: true)  { [weak self] (result) in
            guard let self = self else {
                return
            }
            var isSucceeded = false
            switch(result) {
            case .success( _):
                print("mark message as read:", asRead)
                isSucceeded = true
                self.viewController?.messageIsRead = asRead
                self.viewController?.viewInboxEmailDelegate?.didUpdateReadStatus(for: message, status: asRead)
                if !withUndo.isEmpty {
                    self.presenter?.showUndoBar(text: withUndo)
                }
            case .failure(let error):
                print("error:", error)
                self.viewController?.showAlert(with: "Messages Error",
                           message: error.localizedDescription,
                           buttonTitle: Strings.Button.closeButton.localized)
            }
            onCompletion?(isSucceeded)
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
                self.viewController?.showAlert(with: "Messages Error",
                           message: error.localizedDescription,
                           buttonTitle: Strings.Button.closeButton.localized)
            }
        }
    }
    
    func deleteMessage(message: EmailMessage,
                       withUndo: String,
                       onCompletion: ((Bool) -> Void)? = nil) {
        apiService?.deleteMessages(messagesIDIn: message.messsageID!.description) {(result) in
            switch(result) {
            case .success( _):
                print("deleteMessage ")
                self.viewController?.lastAction = ActionsIndex.delete
                self.postUpdateInboxNotification()
                self.viewController?.router?.backToParentViewController()
                onCompletion?(true)
            case .failure(let error):
                print("error:", error)
                self.viewController?.showAlert(with: "Delete Message Error",
                           message: error.localizedDescription,
                           buttonTitle: Strings.Button.closeButton.localized)
                onCompletion?(false)
            }
        }
    }
    
    func undoLastAction(message: EmailMessage) {
        self.presenter?.hideUndoBar()
        
        print("undo pressed")
        
        switch self.viewController?.lastAction.rawValue {
        case ActionsIndex.markAsSpam.rawValue:
            self.moveMessageToSpam(message: message, withUndo: "")
        case ActionsIndex.markAsRead.rawValue:
            self.markMessageAsRead(message: message, asRead: message.read!, withUndo: "")
        case ActionsIndex.markAsStarred.rawValue:
            self.markMessageAsStarred(message: message, starred: message.starred!, withUndo: "")
        case ActionsIndex.moveToArchive.rawValue:
            self.moveMessageToArchive(message: message, withUndo: "", onCompletion: { [weak self] (isSucceeded) in
                if isSucceeded {
                    DispatchQueue.main.async {
                        self?.viewController?.router?.backToParentViewController()
                    }
                }
            })
        case ActionsIndex.moveToTrach.rawValue:
            self.moveMessageToTrash(message: message, withUndo: "", onCompletion: { [weak self] (isSucceeded) in
                if isSucceeded {
                    DispatchQueue.main.async {
                        self?.viewController?.router?.backToParentViewController()
                    }
                }
            })
        case ActionsIndex.moveToInbox.rawValue:
            self.moveMessageToInbox(message: message, withUndo: "")
        default:
            print("unknown undo action")
        }
    }
    
    func postUpdateInboxNotification() {
        
        let silent = true
        
        NotificationCenter.default.post(name: .updateInboxMessagesNotificationID, object: silent, userInfo: nil)
    }
    
    //MARK: - Share Attachment
    
    func showPreviewScreen(url: URL, encrypted: Bool) {
        
        if encrypted {
            guard let data = try? Data(contentsOf: url) else {
                print("Attachment content data error!")
                self.presenter?.showAttachmentError()
                return
            }
            
            if let tempUrl = self.decryptAttachment(data: data) {
                self.viewController?.documentInteractionController.url = tempUrl
            } else {
                print("Attachment decrypted content data error!")
                //self.presenter?.showAttachmentError()
               // return
                //probably data is not encrypted
                self.viewController?.documentInteractionController.url = url
            }
        } else {
            self.viewController?.documentInteractionController.url = url
        }
        
        self.viewController?.documentInteractionController.uti = url.typeIdentifier ?? "public.data, public.content"
        self.viewController?.documentInteractionController.name = url.localizedName ?? url.lastPathComponent
        
        DispatchQueue.main.async {
            self.viewController?.documentInteractionController.presentPreview(animated: true)
        }
        
        Loader.start()
    }
    
    func checkIsFileExist(url: URL) -> Bool {
        
        let filePath = url.path
        let fileManager = FileManager.default
        
        if fileManager.fileExists(atPath: filePath) {
            return true
        } else {
            return false
        }
    }
    
    func getFileUrlDocuments(withURLString: String) -> URL {
        
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! + "/" + (withURLString as NSString).lastPathComponent
        
        let url = URL(fileURLWithPath: path)
        
        return url
    }
    
    func decryptAttachment(data: Data) -> URL? {
    
        let decryptedAttachment = pgpService?.decrypt(encryptedData: data)
        print("decryptedAttachment:", decryptedAttachment as Any)
        
        if decryptedAttachment == nil {
            return nil
        }
        
        let tempFileUrl = GeneralConstant.getApplicationSupportDirectoryDirectory().appendingPathComponent(k_tempFileName)
        
        do {
            try decryptedAttachment?.write(to: tempFileUrl)
        }  catch {
            print("save decryptedAttachment Error")
        }
        
        return tempFileUrl
    }
        
    func loadAttachFile(url: String, encrypted: Bool) {
        Loader.start()
        apiService?.loadAttachFile(url: url) {(result) in
            Loader.stop()
            switch(result) {
            case .success(let value):
                //print("load value:", value)
                let savedFileUrl = value as! URL
                self.showPreviewScreen(url: savedFileUrl, encrypted: encrypted)
                
            case .failure(let error):
                print("error:", error)
                self.viewController?.showAlert(with: "Download File Error",
                           message: error.localizedDescription,
                           buttonTitle: Strings.Button.closeButton.localized)
            }
        }
    }
    
    func hideProgressIndicator() {
        Loader.stop()
    }
}
