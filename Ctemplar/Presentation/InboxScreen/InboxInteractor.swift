//
//  InboxInteractor.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 11.10.2018.
//  Copyright © 2018 CTemplar. All rights reserved.
//

import Foundation
import AlertHelperKit

class InboxInteractor {
    
    var viewController  : InboxViewController?
    var presenter       : InboxPresenter?
    var apiService      : APIService?
    var pgpService      : PGPService?
    
    var totalItems = 0
    var unreadEmails = 0
    var offset = 0
    var loadMoreInProgress = false
    
    private var isFetchInProgress = false
    //MARK: - data

    func updateMessages(withUndo: String, silent: Bool) {
        
        if self.checkStoredPGPKeys() {
            self.messagesList(folder: (self.viewController?.currentFolderFilter)!, withUndo: withUndo, silent: silent)
        }
    }
    
    func setInboxData(messages: Array<EmailMessage>, totalEmails: Int) {
     
        if self.offset == 0 {
            self.viewController?.allMessagesArray.removeAll()
            self.viewController?.dataSource?.selectedMessagesIDArray.removeAll()
        }
        
        //self.viewController?.allMessagesArray.append(contentsOf: messages)
        
        for newmessage in messages {
            if isMessageExist(messageId: newmessage.messsageID!) {
                self.viewController?.allMessagesArray.removeAll(where: {$0.messsageID == newmessage.messsageID})
            }
         
            self.viewController?.allMessagesArray.append(newmessage)
        }
        
        print("fetched messages count:", self.viewController?.allMessagesArray.count as Any)
        
        //sorting by creation date
        self.viewController?.allMessagesArray = self.sortMessagesByCreatedDate(messages: self.viewController!.allMessagesArray)
        
        self.viewController?.dataSource?.messagesArray = self.viewController!.allMessagesArray
        self.viewController?.dataSource?.reloadData()
        
        if self.viewController?.dataSource?.selectionMode == true {
            if self.viewController?.dataSource?.selectedMessagesIDArray.count == 0 {
                self.viewController?.presenter?.disableSelectionMode()
            }
        }
        
        let filterEnabled = self.filterEnabled()
        self.presenter?.setupUI(emailsCount: totalEmails, unreadEmails: unreadEmails, filterEnabled: filterEnabled)
        
        if filterEnabled {
            self.applyFilters()
        }
        
        if self.viewController?.messageID != -1 {
            for message in self.viewController?.allMessagesArray ?? [] {
                if message.messsageID == self.viewController?.messageID {
                    self.viewController?.messageID = -1
                    self.viewController?.router?.showViewInboxEmailViewController(message: message)
                    break
                }
            }
        }
    }
    
    func isMessageExist(messageId: Int) -> Bool {
    
        if let exist = self.viewController?.allMessagesArray.contains(where: {$0.messsageID == messageId}) {
            return exist
        }
        
        return false
    }
    
    func sortMessagesByCreatedDate(messages: Array<EmailMessage>) -> Array<EmailMessage> {
        
        var sortedMessages = Array<EmailMessage>()
        
        sortedMessages = messages.sorted(by: {
            
            guard let date0 = $0.createdAt, let date1 = $1.createdAt else {
                return false
            }
            
            guard let date0Date = self.viewController?.dataSource?.formatterService?.formatStringToDate(date: date0), let date1Date = self.viewController?.dataSource?.formatterService?.formatStringToDate(date: date1) else {
                return false
            }
            
            return date0Date > date1Date
        })
        
        return sortedMessages
    }
    
    /*
    func setInboxData(messages: EmailMessagesList, folderFilter: String) {
        
        var readEmails = 0
        var unreadEmails = 0
        
        if let emailsArray = messages.messagesList {
            
            self.viewController?.allMessagesArray = emailsArray
            
            let currentFolderMessages = self.filterInboxMessages(array: emailsArray, filter: folderFilter)
            
            self.viewController?.currentFolderMessagesArray = currentFolderMessages
            
            self.viewController?.dataSource?.messagesArray = currentFolderMessages
            //self.updateMessagesHeader(emailsArray: currentFolderMessages)
            //self.updateMessagesSubjects(emailsArray: currentFolderMessages)
            self.viewController?.dataSource?.reloadData()
            
            if self.viewController?.dataSource?.selectionMode == true {
                if self.viewController?.dataSource?.selectedMessagesIDArray.count == 0 {
                    self.viewController?.presenter?.disableSelectionMode()
                }
            }
            
            readEmails = calculateReadEmails(array: currentFolderMessages)
            unreadEmails = currentFolderMessages.count - readEmails
            
            //self.viewController?.emailsCount = currentFolderMessages.count
            //self.viewController?.unreadEmails = unreadEmails
            
            let filterEnabled = self.filterEnabled()
            self.presenter?.setupUI(emailsCount: currentFolderMessages.count, unreadEmails: unreadEmails, filterEnabled: filterEnabled)
            
            if filterEnabled {
                self.applyFilters()
            }
        }
    }*/
    
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
        
        if self.offset >= self.totalItems, self.offset > 0 {
            return
        }
        if isFetchInProgress {
            return
        }
        isFetchInProgress = true
        DispatchQueue.main.async {
            if !silent {
                Loader.start()
            }
        }
        
        let pageSize: Int
        
        if self.viewController?.allMessagesArray.isEmpty == true {
            if Device.IS_IPAD {
                pageSize = k_firstLoadPageLimit_iPad
            } else {
                pageSize = k_firstLoadPageLimit
            }
        } else {
            pageSize = k_pageLimit
        }
        
        apiService?.messagesList(folder: folder, messagesIDIn: "", seconds: 0, offset: offset, pageLimit: pageSize) { [weak self] (result) in
            guard let self = self else {
                return
            }
            self.isFetchInProgress = false
            
            if self.loadMoreInProgress {
                self.loadMoreInProgress = false
                self.viewController?.dataSource?.resetFooterView()
            }
            
            switch(result) {
            case .success(let value):
                let emailMessages = value as! EmailMessagesList
                self.totalItems = emailMessages.totalCount ?? 0
                self.setInboxData(messages: emailMessages.messagesList!, totalEmails: self.totalItems)
                if !withUndo.isEmpty {
                    self.presenter?.showUndoBar(text: withUndo)
                }
                self.offset += pageSize
            case .failure(let error):
                print("error:", error)
                if !silent, let vc = self.viewController {
                    AlertHelperKit().showAlert(vc, title: "Messages Error", message: error.localizedDescription, button: "closeButton".localized())
                }
            }
            print("messagesList complete")
            Loader.stop()
        }
    }
    
    func allMessagesList() {
        Loader.start()
        apiService?.messagesList(folder: "", messagesIDIn: "", seconds: 0, offset: -1) {(result) in
            switch(result) {
            case .success(let value):
                print("allMessagesList value:", value)
               // let emailMessages = value as! EmailMessagesList
            case .failure(let error):
                print("error:", error)
                AlertHelperKit().showAlert(self.viewController!, title: "Messages Error", message: error.localizedDescription, button: "closeButton".localized())
            }
            Loader.stop()
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
                        if (mailbox.isDefault ?? false) || mailboxesList.count == 1 {
                            if storeKeys == true {
                                if let privateKey = mailbox.privateKey {
                                    self.pgpService?.extractAndSavePGPKeyFromString(key: privateKey)
                                }
                            
                                if let publicKey = mailbox.publicKey {
                                    self.pgpService?.extractAndSavePGPKeyFromString(key: publicKey)
                                }
                            }
                        }
                    }
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: k_updateInboxMessagesNotificationID), object: nil)
                }
                
            case .failure(let error):
                print("error:", error)
                AlertHelperKit().showAlert(self.viewController!, title: "Mailboxes Error", message: error.localizedDescription, button: "closeButton".localized())
            }
        }
    }
    
    func userMyself() {
        DispatchQueue.global(qos: .background).async {
            self.apiService?.userMyself() {(result) in
                
                switch(result) {
                    
                case .success(let value):
                    //print("userMyself value:", value)
                    
                    var userMyself = value as! UserMyself
                    if userMyself.username == self.viewController?.user.username {
                        userMyself.contactsList = self.viewController?.user.contactsList
                    }
                    self.viewController?.user = userMyself
                    
                    if let mailboxes = userMyself.mailboxesList {
                        self.viewController?.mailboxesList = mailboxes
                    }
                    
                    if self.viewController?.navigationItem.leftBarButtonItem != nil {
                        self.viewController?.leftBarButtonItem.isEnabled = true
                    }
                    
                    self.viewController?.bottomComposeButton.isEnabled = true
                    self.viewController?.rightComposeButton.isEnabled = true
                    
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: k_updateUserDataNotificationID), object: value)
                    self.userContactsList()
                case .failure(let error):
                    print("error:", error)
                    AlertHelperKit().showAlert(self.viewController!, title: "User Myself Error", message: error.localizedDescription, button: "closeButton".localized())
                }
            }
        }
        
    }
    
    func userContactsList() {
        if (self.viewController?.user.contactsList?.count ?? 0) > 0 {
            return
        }
        DispatchQueue.global(qos: .background).async {
            self.apiService?.userContacts(fetchAll: true, offset: 0, silent: true, completionHandler: { (result) in
//                DispatchQueue.main.async {
                    switch result {
                    case .success(let value):
                        if let contactsList = value as? ContactsList {
                            self.viewController?.user.contactsList = contactsList.contactsList ?? []
                        }
                        break
                    case .failure(let error):
                        print("Error in fetching user contacts: \(error.localizedDescription)")
                        break
                    }
//                }
            })
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
    
    func decryptSubject(content: String, messageID: Int) {
        
        let queue = DispatchQueue.global(qos: .utility)
        
        queue.async {
            
            if let subject = self.pgpService?.decryptMessage(encryptedContet: content) {
                DispatchQueue.main.async {
                    self.setDecryptedSubject(content: subject, messageID: messageID)
                }
            }
        }
    }
    
    func setDecryptedHeader(content: String, messageID: Int) {
        
        let header = self.headerOfMessage(content: content)
     
        self.viewController?.dataSource?.messagesHeaderDictionary[messageID] = header
        self.viewController?.dataSource?.reloadData()
    }
    
    func setDecryptedSubject(content: String, messageID: Int) {
        
        self.viewController?.dataSource?.messagesSubjectDictionary[messageID] = content
        self.viewController?.dataSource?.reloadData()
    }
    
    func checkIsMessageHeaderDecrypted(messageID: Int) -> Bool {
        
        if (self.viewController?.dataSource?.messagesHeaderDictionary[messageID]) != nil {
            return true
        }
        
        return false
    }
    
    func checkIsMessageSubjectDecrypted(messageID: Int) -> Bool {
        
        if (self.viewController?.dataSource?.messagesSubjectDictionary[messageID]) != nil {
            return true
        }
        
        return false
    }
    
    func isSubjectEncrypted(message: EmailMessage) -> Bool {
        
        if (apiService?.isSubjectEncrypted(message: message))! {
            return true
        }
        
        return false
    }
    
    func updateMessagesSubjects(emailsArray: Array<EmailMessage>) {
        
        for message in emailsArray {
            if let messageSubject = message.subject {
                if (apiService?.isSubjectEncrypted(message: message))! {
                    if !self.checkIsMessageSubjectDecrypted(messageID: message.messsageID!) {
                        self.decryptSubject(content: messageSubject, messageID: message.messsageID!)
                    }
                } else {
                    self.setDecryptedSubject(content: messageSubject, messageID: message.messsageID!)
                }
            }
        }
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
        
        var filteredMessagesArray : Array<EmailMessage> = self.viewController!.allMessagesArray //(self.viewController?.currentFolderMessagesArray)!
        
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
        //self.updateMessagesHeader(emailsArray: filteredMessagesArray)
        //self.updateMessagesSubjects(emailsArray: filteredMessagesArray)
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
        
        if self.viewController?.currentFolder == InboxSideMenuOptionsName.trash.rawValue {
            self.deleteMessagesList(selectedMessagesIdArray: messagesIDArray, withUndo: "")
        } else {
            self.markMessagesListAsTrash(selectedMessagesIdArray: messagesIDArray, lastSelectedMessage: message, withUndo: "undoMoveToTrash".localized())
        }
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
                self.offset = 0
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
                self.offset = 0
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
                self.offset = 0
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
                self.offset = 0
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
                self.offset = 0
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
                self.viewController?.lastAction = ActionsIndex.delete
                self.offset = 0
                self.updateMessages(withUndo: withUndo, silent: false)
                
            case .failure(let error):
                print("error:", error)
                AlertHelperKit().showAlert(self.viewController!, title: "Messages Error", message: error.localizedDescription, button: "closeButton".localized())
            }
        }
    }
}
