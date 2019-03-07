//
//  InboxInteractor.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 11.10.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import AlertHelperKit
import PKHUD

class InboxInteractor {
    
    var viewController  : InboxViewController?
    var presenter       : InboxPresenter?
    var apiService      : APIService?
    var pgpService      : PGPService?
    
    //MARK: - data

    func updateMessages(withUndo: String, silent: Bool) {
        
        if self.checkStoredPGPKeys() {
            self.messagesList(folder: (self.viewController?.currentFolderFilter)!, withUndo: withUndo, silent: silent)
        }
    }
    
    func setInboxData(messages: EmailMessagesList, folderFilter: String) {
        
        var readEmails = 0
        var unreadEmails = 0
        
        if let emailsArray = messages.messagesList {
            
            self.viewController?.allMessagesArray = emailsArray
            
            let currentFolderMessages = self.filterInboxMessages(array: emailsArray, filter: folderFilter)
            
            self.viewController?.currentFolderMessagesArray = currentFolderMessages
            
            self.viewController?.dataSource?.messagesArray = currentFolderMessages
            self.updateMessagesHeader(emailsArray: currentFolderMessages)
            self.viewController?.dataSource?.reloadData()
            
            if self.viewController?.dataSource?.selectionMode == true {
                if self.viewController?.dataSource?.selectedMessagesIDArray.count == 0 {
                    self.viewController?.presenter?.disableSelectionMode()
                }
            }
            
            readEmails = calculateReadEmails(array: currentFolderMessages)
            unreadEmails = currentFolderMessages.count - readEmails
            
            self.viewController?.emailsCount = currentFolderMessages.count
            self.viewController?.unreadEmails = unreadEmails
            
            let filterEnabled = self.filterEnabled()
            self.presenter?.setupUI(emailsCount: currentFolderMessages.count, unreadEmails: unreadEmails, filterEnabled: filterEnabled)
        }
    }
    
    func setSideMenuData(array: Array<UnreadMessagesCounter>) {
        
       // self.viewController?.inboxSideMenuViewController?.dataSource?.unreadMessagesArray = array
       // self.viewController?.inboxSideMenuViewController?.dataSource?.reloadData()
    }
    
    func setSideMenuData(messages: EmailMessagesList) {
        /*
        var readEmails = 0
        var unreadEmails = 0
        
        if let emailsArray = messages.messagesList {
            
            //self.viewController?.mainFoldersUnreadMessagesCount.removeAll()
           // self.viewController?.inboxSideMenuViewController?.dataSource?.mainFoldersUnreadMessagesCount.removeAll()
            
            
            for filter in MessagesFoldersName.allCases {
                let messages = filterInboxMessages(array: emailsArray, filter: filter.rawValue)
                readEmails = calculateReadEmails(array: messages)
                
                unreadEmails = messages.count - readEmails
                print("filter:", filter, "unreadEmails:", unreadEmails)
                //self.viewController?.mainFoldersUnreadMessagesCount.append(unreadEmails)
               // self.viewController?.inboxSideMenuViewController?.dataSource?.mainFoldersUnreadMessagesCount.append(unreadEmails)
            }
            
            self.viewController?.inboxSideMenuViewController?.dataSource?.reloadData()
        }*/
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
    
    func messagesList(folder: String, withUndo: String, silent: Bool) {
        
        if !silent {
            //HUD.show(.progress)
            HUD.show(.labeledProgress(title: "updateMessages".localized(), subtitle: ""))
        }
        
        apiService?.messagesList(folder: ""/*folder*/, messagesIDIn: "", seconds: 0) {(result) in
            
            switch(result) {
                
            case .success(let value):
                //print("value:", value)
                
                let emailMessages = value as! EmailMessagesList
                self.viewController?.allMessagesList = emailMessages
                self.setInboxData(messages: emailMessages, folderFilter: folder)
                
                if withUndo.count > 0 {
                    self.presenter?.showUndoBar(text: withUndo)
                }
                
            case .failure(let error):
                print("error:", error)
                AlertHelperKit().showAlert(self.viewController!, title: "Messages Error", message: error.localizedDescription, button: "closeButton".localized())
            }
            
            print("messagesList complete")
            HUD.hide()
        }
    }
    
    func allMessagesList() {
        
        HUD.show(.progress)
        
        apiService?.messagesList(folder: "", messagesIDIn: "", seconds: 0) {(result) in
            
            switch(result) {
                
            case .success(let value):
                //print("value:", value)
                
                let emailMessages = value as! EmailMessagesList
                self.setSideMenuData(messages: emailMessages)
                
            case .failure(let error):
                print("error:", error)
                AlertHelperKit().showAlert(self.viewController!, title: "Messages Error", message: error.localizedDescription, button: "closeButton".localized())
            }
            
            HUD.hide()
        }
    }
    
    func unreadMessagesCounter() {
        
        HUD.show(.progress)
        
        apiService?.unreadMessagesCounter() {(result) in
            
            switch(result) {
                
            case .success(let value):
                //print("unreadMessagesCounter value:", value)
                
                var unreadMessagesCounterArray: Array<UnreadMessagesCounter> = []
                
                for objectDictionary in (value as? Dictionary<String, Any>)! {
                   
                    let unreadMessageCounter = UnreadMessagesCounter(key: objectDictionary.key, value: objectDictionary.value)
                    unreadMessagesCounterArray.append(unreadMessageCounter)
                }
              
                self.setSideMenuData(array: unreadMessagesCounterArray)
                
            case .failure(let error):
                print("error:", error)
                AlertHelperKit().showAlert(self.viewController!, title: "Messages Error", message: error.localizedDescription, button: "closeButton".localized())
            }
            
            HUD.hide()
        }        
    }
    
    func checkStoredPGPKeys() -> Bool {
        
        if pgpService?.getStoredPGPKeys() == nil {
            self.mailboxesList(storeKeys: true)
        } else {
            print("local PGPKeys exist")
            //self.mailboxesList(storeKeys: false)
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
                        
                            if let publicKey = mailbox.publicKey {
                                self.pgpService?.extractAndSavePGPKeyFromString(key: publicKey)
                            }
                            
                            //load messages after keys storred
                            self.messagesList(folder: (self.viewController?.currentFolderFilter)!, withUndo: "", silent: false)
                        }
                    }
                }
                
            case .failure(let error):
                print("error:", error)
                AlertHelperKit().showAlert(self.viewController!, title: "Mailboxes Error", message: error.localizedDescription, button: "closeButton".localized())
            }
        }
    }
    
    func userMyself() {
        
        apiService?.userMyself() {(result) in
            
            switch(result) {
                
            case .success(let value):
                //print("userMyself value:", value)
                
                let userMyself = value as! UserMyself
                
                self.viewController?.user = userMyself
                
               // if let contacts = userMyself.contactsList {
                    //self.viewController?.contactsList = contacts
                //}
                
                if let mailboxes = userMyself.mailboxesList {
                    self.viewController?.mailboxesList = mailboxes
                }
                
                if self.viewController?.navigationItem.leftBarButtonItem != nil {
                    self.viewController?.leftBarButtonItem.isEnabled = true
                }
                
                self.viewController?.bottomComposeButton.isEnabled = true
                self.viewController?.rightComposeButton.isEnabled = true
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: k_updateUserDataNotificationID), object: value)
                
            case .failure(let error):
                print("error:", error)
                AlertHelperKit().showAlert(self.viewController!, title: "User Myself Error", message: error.localizedDescription, button: "closeButton".localized())
            }
        }
    }
    
    func publicKeyList() {
        
        apiService?.publicKeyList() {(result) in
            
            switch(result) {
                
            case .success(let value):
                print("publicKeyList value:", value)
                
            case .failure(let error):
                print("error:", error)
                AlertHelperKit().showAlert(self.viewController!, title: "Public Key Error", message: error.localizedDescription, button: "closeButton".localized())
            }
        }
    }
    
    //MARK: - message headers
    
    func headerOfMessage(content: String) -> String {
        
        var header : String = ""
        var message : String = ""
        
        //message = self.decryptMessage(content: content)
        message = content //!!!!!!

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
    
    func decryptHeader(content: String, index: Int) {
     
        let queue = DispatchQueue.global(qos: .userInitiated)

        queue.async {
            
            if let message = self.pgpService?.decryptMessage(encryptedContet: content) {
                DispatchQueue.main.async {
                    //print("message:", message)
                    self.setDecryptedHeader(content: message, index: index)
                }
            }
        }
    }
    
    func setDecryptedHeader(content: String, index: Int) {
        
        let header = self.headerOfMessage(content: content)
        
        if (self.viewController?.dataSource?.messagesHeaderArray.count)! > index {
            self.viewController?.dataSource?.messagesHeaderArray[index] = header
            self.viewController?.dataSource?.reloadData()
        }
    }
    
    func decryptHeader(content: String, messageID: Int) {
        
        let queue = DispatchQueue.global(qos: .utility)
        
        queue.async {
            
            if let message = self.pgpService?.decryptMessage(encryptedContet: content) {
                DispatchQueue.main.async {
                    //print("message:", message)
                    self.setDecryptedHeader(content: message, messageID: messageID)
                }
            }
        }
    }
    
    func setDecryptedHeader(content: String, messageID: Int) {
        
        let header = self.headerOfMessage(content: content)
     
        self.viewController?.dataSource?.messagesHeaderDictionary[messageID] = header
        self.viewController?.dataSource?.reloadData()
    }
    
    func checkIsMessageHeaderDecrypted(messageID: Int) -> Bool {
        
        if (self.viewController?.dataSource?.messagesHeaderDictionary[messageID]) != nil {
            return true
        }
        
        return false
    }
    
    func updateMessagesHeader(emailsArray: Array<EmailMessage>) {
        
        self.viewController?.dataSource?.messagesHeaderArray.removeAll()
        /*
        for (index, message) in emailsArray.enumerated() {
            if let messageContent = message.content {
                //let header = self.headerOfMessage(content: messageContent)
                //self.viewController?.dataSource?.messagesHeaderArray.append(header)
                self.viewController?.dataSource?.messagesHeaderArray.append("decoding...")
                self.decryptHeader(content: messageContent, index: index)
                //self.viewController?.dataSource?.messagesHeaderDictionary[message.messsageID!] = "decoding..."
            } else {
                self.viewController?.dataSource?.messagesHeaderArray.append("Empty content")
            }
        }*/
        
        for message in emailsArray {
            if let messageContent = message.content {
               // if message.isEncrypted! {
                if (apiService?.isMessageEncrypted(message: message))! {
                    if !self.checkIsMessageHeaderDecrypted(messageID: message.messsageID!) {
                        self.decryptHeader(content: messageContent, messageID: message.messsageID!)
                    }
                } else {
                    self.setDecryptedHeader(content: messageContent, messageID: message.messsageID!)
                }
            }
        }
    }
    
    //MARK: - filters
    
    func filterInboxMessages(array: Array<EmailMessage>, filter: String) -> Array<EmailMessage> {
        
        var inboxMessagesArray : Array<EmailMessage> = []
        
        if filter == MessagesFoldersName.starred.rawValue {
            
            for message in array {
                if message.starred == true {
                    inboxMessagesArray.append(message)
                }
            }
            
        } else {
        
            for message in array {
                if message.folder == filter {
                    inboxMessagesArray.append(message)
                }
            }
        }
        
        return inboxMessagesArray
    }
    
    func filterEnabled() -> Bool {
        
        for filterApplied in (self.viewController?.appliedFilters)! {
            if filterApplied == true {
                return true
            }
        }
        
        return false
    }
    
    func clearFilters() {
        
        self.viewController?.appliedFilters = [false, false, false]
        self.viewController?.inboxFilterView?.setup(appliedFilters: (self.viewController?.appliedFilters)!)
    }
    
    func applyFilters() {
        
        var filteredMessagesArray : Array<EmailMessage> = (self.viewController?.currentFolderMessagesArray)!
        
        for (index, filterApplied) in (self.viewController?.appliedFilters)!.enumerated() {
                 
            switch index + InboxFilterButtonsTag.starred.rawValue {
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
    
    func showMoveTo(message: EmailMessage) {
        
        self.viewController!.router?.showMoveToViewController()
    }
    
    func markMessageAsSpam(message: EmailMessage) {
        
        var messagesIDArray: Array<Int> = []
        
        if let messageID = message.messsageID {
            messagesIDArray.append(messageID)
        }
        
        self.markMessagesListAsSpam(selectedMessagesIdArray: messagesIDArray, lastSelectedMessage: message, withUndo: "undoMarkAsSpam".localized())
        
    }
    
    func markMessageAsRead(message: EmailMessage) {
        
        var messagesIDArray: Array<Int> = []
        
        if let messageID = message.messsageID {
            messagesIDArray.append(messageID)
        }
        
        var undoMessage = ""
        if message.read! {
            undoMessage = "undoMarkAsUnread".localized()
        } else {
            undoMessage = "undoMarkAsRead".localized()
        }

        self.markMessagesListAsRead(selectedMessagesIdArray: messagesIDArray, asRead: !message.read!, withUndo: undoMessage)
    }
    
    func markMessageAsTrash(message: EmailMessage) {
        
        var messagesIDArray: Array<Int> = []
        
        if let messageID = message.messsageID {
            messagesIDArray.append(messageID)
        }
        
        self.markMessagesListAsTrash(selectedMessagesIdArray: messagesIDArray, lastSelectedMessage: message, withUndo: "undoMoveToTrash".localized())
    }
    
    func undoLastAction(message: EmailMessage) {
   
        self.presenter?.hideUndoBar()
        
        if (self.viewController?.dataSource?.selectedMessagesIDArray.count)! < 1 {
            return
        }
        
        switch self.viewController?.lastAction.rawValue {
        case ActionsIndex.markAsSpam.rawValue:
            self.markMessagesListAsSpam(selectedMessagesIdArray: (self.viewController?.dataSource?.selectedMessagesIDArray)!, lastSelectedMessage: message, withUndo: "")
            break
        case ActionsIndex.markAsRead.rawValue:
            self.markMessagesListAsRead(selectedMessagesIdArray: (self.viewController?.dataSource?.selectedMessagesIDArray)!, asRead:message.read!, withUndo: "")
            break
        case ActionsIndex.markAsStarred.rawValue:
            
            break
        case ActionsIndex.moveToArchive.rawValue:
            self.moveMessagesListToArchive(selectedMessagesIdArray: (self.viewController?.dataSource?.selectedMessagesIDArray)!, lastSelectedMessage: message, withUndo: "")
            break
        case ActionsIndex.moveToTrach.rawValue:
            self.markMessagesListAsTrash(selectedMessagesIdArray: (self.viewController?.dataSource?.selectedMessagesIDArray)!, lastSelectedMessage: message, withUndo: "")
            break
        default:
            print("unknown undo action")
        }
        
        //self.viewController?.lastAction = ActionsIndex.noAction
        self.viewController?.appliedActionMessage = nil
        self.viewController?.dataSource?.selectedMessagesIDArray.removeAll()
    }
    
    //MARK: - Selection Bar Actions
    
    func markMessagesListAsSpam(selectedMessagesIdArray: Array<Int>, lastSelectedMessage: EmailMessage, withUndo: String) {
        
        var folder = lastSelectedMessage.folder
        
        if withUndo.count > 0 {
            folder = MessagesFoldersName.spam.rawValue
        }
        
        var messagesIDList : String = ""
        
        for message in selectedMessagesIdArray {
            messagesIDList = messagesIDList + message.description + ","
        }
        
        messagesIDList.remove(at: messagesIDList.index(before: messagesIDList.endIndex)) //remove last ","
        
        apiService?.updateMessages(messageID: "", messagesIDIn: messagesIDList, folder: folder!, starred: false, read: false, updateFolder: true, updateStarred: false, updateRead: false)  {(result) in
            
            switch(result) {
                
            case .success( _):
                //print("value:", value)
                print("marked list as spam")
                self.viewController?.lastAction = ActionsIndex.markAsSpam
                self.updateMessages(withUndo: withUndo, silent: false)
                
            case .failure(let error):
                print("error:", error)
                AlertHelperKit().showAlert(self.viewController!, title: "Messages Error", message: error.localizedDescription, button: "closeButton".localized())
            }
        }
    }
    
    func markMessagesListAsRead(selectedMessagesIdArray: Array<Int>, asRead: Bool, withUndo: String) {
        
        //let read = !lastSelectedMessage.read!
        
        var messagesIDList : String = ""
        
        for message in selectedMessagesIdArray {
            messagesIDList = messagesIDList + message.description + ","
        }
        
        messagesIDList.remove(at: messagesIDList.index(before: messagesIDList.endIndex)) //remove last ","
        
        apiService?.updateMessages(messageID: "", messagesIDIn: messagesIDList, folder: "", starred: false, read: asRead, updateFolder: false, updateStarred: false, updateRead: true)  {(result) in
            
            switch(result) {
                
            case .success( _):
                //print("value:", value)
                print("marked list as read/unread")
                self.viewController?.lastAction = ActionsIndex.markAsRead
                self.updateMessages(withUndo: withUndo, silent: false)
                
            case .failure(let error):
                print("error:", error)
                AlertHelperKit().showAlert(self.viewController!, title: "Messages Error", message: error.localizedDescription, button: "closeButton".localized())
            }
        }
    }
    
    func markMessagesListAsTrash(selectedMessagesIdArray: Array<Int>, lastSelectedMessage: EmailMessage, withUndo: String) {
        
        var folder = lastSelectedMessage.folder
        
        if withUndo.count > 0 {
            folder = MessagesFoldersName.trash.rawValue
        }
        
        var messagesIDList : String = ""
        
        for message in selectedMessagesIdArray {
            messagesIDList = messagesIDList + message.description + ","
        }
        
        messagesIDList.remove(at: messagesIDList.index(before: messagesIDList.endIndex)) //remove last ","
        
        apiService?.updateMessages(messageID: "", messagesIDIn: messagesIDList, folder: folder!, starred: false, read: false, updateFolder: true, updateStarred: false, updateRead: false)  {(result) in
            
            switch(result) {
                
            case .success( _):
                //print("value:", value)
                print("marked list as trash")
                self.viewController?.lastAction = ActionsIndex.moveToTrach
                self.updateMessages(withUndo: withUndo, silent: false)
                
            case .failure(let error):
                print("error:", error)
                AlertHelperKit().showAlert(self.viewController!, title: "Messages Error", message: error.localizedDescription, button: "closeButton".localized())
            }
        }
    }
    
    func moveMessagesListToArchive(selectedMessagesIdArray: Array<Int>, lastSelectedMessage: EmailMessage, withUndo: String) {
        
        var folder = lastSelectedMessage.folder
        
        if withUndo.count > 0 {
            folder = MessagesFoldersName.archive.rawValue
        }
        
        var messagesIDList : String = ""
        
        for message in selectedMessagesIdArray {
            messagesIDList = messagesIDList + message.description + ","
        }
        
        messagesIDList.remove(at: messagesIDList.index(before: messagesIDList.endIndex)) //remove last ","
        
        apiService?.updateMessages(messageID: "", messagesIDIn: messagesIDList, folder: folder!, starred: lastSelectedMessage.starred!, read: lastSelectedMessage.read!, updateFolder: true, updateStarred: false, updateRead: false)  {(result) in
            
            switch(result) {
                
            case .success( _):
                //print("value:", value)
                print("move list to archive")
                self.viewController?.lastAction = ActionsIndex.moveToArchive
                self.updateMessages(withUndo: withUndo, silent: false)
                
            case .failure(let error):
                print("error:", error)
                AlertHelperKit().showAlert(self.viewController!, title: "Messages Error", message: error.localizedDescription, button: "closeButton".localized())
            }
        }
    }
    
    func moveMessagesListToInbox(selectedMessagesIdArray: Array<Int>, lastSelectedMessage: EmailMessage, withUndo: String) {
        
        var folder = lastSelectedMessage.folder
        
        if withUndo.count > 0 {
            folder = MessagesFoldersName.inbox.rawValue
        }
        
        var messagesIDList : String = ""
        
        for message in selectedMessagesIdArray {
            messagesIDList = messagesIDList + message.description + ","
        }
        
        messagesIDList.remove(at: messagesIDList.index(before: messagesIDList.endIndex)) //remove last ","
        
        apiService?.updateMessages(messageID: "", messagesIDIn: messagesIDList, folder: folder!, starred: lastSelectedMessage.starred!, read: lastSelectedMessage.read!, updateFolder: true, updateStarred: false, updateRead: false)  {(result) in
            
            switch(result) {
                
            case .success( _):
                //print("value:", value)
                print("move list to inbox")
                self.viewController?.lastAction = ActionsIndex.moveToArchive
                self.updateMessages(withUndo: withUndo, silent: false)
                
            case .failure(let error):
                print("error:", error)
                AlertHelperKit().showAlert(self.viewController!, title: "Messages Error", message: error.localizedDescription, button: "closeButton".localized())
            }
        }
    }
    
    //MARK: - Empty Folder Action
    
    func deleteMessagesList(selectedMessagesIdArray: Array<Int>, withUndo: String) {
        
        var messagesIDList : String = ""
        
        for message in selectedMessagesIdArray {
            messagesIDList = messagesIDList + message.description + ","
        }
        
        messagesIDList.remove(at: messagesIDList.index(before: messagesIDList.endIndex)) //remove last ","
        
        apiService?.deleteMessages(messagesIDIn: messagesIDList) {(result) in
            
            switch(result) {
                
            case .success( _):
                //print("value:", value)
                print("deleteMessagesList")
                self.viewController?.lastAction = ActionsIndex.moveToArchive
                self.updateMessages(withUndo: withUndo, silent: false)
                
            case .failure(let error):
                print("error:", error)
                AlertHelperKit().showAlert(self.viewController!, title: "Messages Error", message: error.localizedDescription, button: "closeButton".localized())
            }
        }
    }
}
