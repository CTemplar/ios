//
//  ComposeInteractor.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 27.11.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import AlertHelperKit
import PKHUD
import ObjectivePGP

class ComposeInteractor {
    
    var viewController      : ComposeViewController?
    var presenter           : ComposePresenter?
    var apiService          : APIService?
    var pgpService          : PGPService?
    var formatterService    : FormatterService?
    
    var sendingMessage : EmailMessage = EmailMessage.init()
    
    var setPassword : String = ""

    //MARK: - API
    
    func createDraftMessage(parentID: String, content: String, subject: String, recievers: [[String]], folder: String, mailboxID: Int, send: Bool, encrypted: Bool, encryptionObject: [String : String], attachments: Array<[String : String]>) {
        
        apiService?.createMessage(parentID: parentID, content: content, subject: subject, recieversList: recievers, folder: folder, mailboxID: mailboxID, send: send, encrypted: encrypted, encryptionObject: encryptionObject, attachments: attachments) {(result) in
            
            switch(result) {
                
            case .success(let value):
                print("create Draft Message value:", value)
                self.sendingMessage = value as! EmailMessage
                
                //self.presenter?.setupAttachments(message: self.sendingMessage) //need investigate attachment_forward
                //self.presenter?.setupMessageSectionSize()
                //self.presenter?.setupMessageSection(emailsArray: self.messagesArray)
                //self.presenter?.fillAllEmailsFields(message: self.sendingMessage)
                self.presenter?.setupMessageSection(message: self.sendingMessage)
                self.presenter?.setupEncryptedButton()
                //self.presenter?.setSchedulerTimersForMessage(message: self.sendingMessage)
                
            case .failure(let error):
                print("error:", error)
                AlertHelperKit().showAlert(self.viewController!, title: "Create Draft Error", message: error.localizedDescription, button: "closeButton".localized())
            }
        }
    }
    
    func deleteDraftMessage(messageID: String) {
        
        let folder = MessagesFoldersName.trash.rawValue
        
        apiService?.updateMessages(messageID: "", messagesIDIn: messageID, folder: folder, starred: false, read: false, updateFolder: true, updateStarred: false, updateRead: false)  {(result) in
            
            switch(result) {
                
            case .success( _):
                //print("value:", value)
                print("marked list as trash")
               
                break
            case .failure(let error):
                print("error:", error)
                AlertHelperKit().showAlert(self.viewController!, title: "Delete Draft Error", message: error.localizedDescription, button: "closeButton".localized())
            }
        }
        
        /*
        apiService?.deleteMessages(messagesIDIn: messageID) {(result) in
            
            switch(result) {
                
            case .success(let value):
                print("delete Draft value:", value)
                self.postUpdateInboxNotification()
                
            case .failure(let error):
                print("error:", error)
                AlertHelperKit().showAlert(self.viewController!, title: "Delete Draft Error", message: error.localizedDescription, button: "closeButton".localized())
            }
        }*/
 
        /*
        apiService?.deleteMessage(messagesID: messageID) {(result) in
            
            switch(result) {
                
            case .success(let value):
                print("delete Draft value:", value)
                self.postUpdateInboxNotification()
                
            case .failure(let error):
                print("error:", error)
                AlertHelperKit().showAlert(self.viewController!, title: "Delete Draft Error", message: error.localizedDescription, button: "closeButton".localized())
            }
        }*/
    }
    
    func saveDraftMessage(messageID: Int, messageContent: String, encryptionObject: [String : String], subject: String, send: Bool, recieversList: [[String]], encrypted: Bool, selfDestructionDate: String, delayedDeliveryDate: String, deadManDate: String) {
        
        apiService?.saveDraftMesssage(messageID: messageID.description, messageContent: messageContent, subject: subject, recieversList: recieversList, folder: MessagesFoldersName.draft.rawValue, encryptionObject: encryptionObject, encrypted: encrypted, selfDestructionDate: selfDestructionDate, delayedDeliveryDate: delayedDeliveryDate, deadManDate: deadManDate)  {(result) in
            
            switch(result) {
                
            case .success(let value):
                print("saveDraftMessage value:", value)
                self.postUpdateInboxNotification()
                
            case .failure(let error):
                print("saveDraftMessage error:", error)
                AlertHelperKit().showAlert(self.viewController!, title: "Save Draft Error", message: error.localizedDescription, button: "closeButton".localized())
            }
        }
    }
    
    func updateSendingMessage(messageID: String, encryptedMessage: String, encryptionObject: [String : String], subject: String, send: Bool, recieversList: [[String]], encrypted: Bool, attachments: Array<[String : String]>, selfDestructionDate: String, delayedDeliveryDate: String, deadManDate: String) {
        
        apiService?.updateSendingMessage(messageID: messageID, encryptedMessage: encryptedMessage, subject: subject, recieversList: recieversList, folder: MessagesFoldersName.sent.rawValue, send: send, encryptionObject: encryptionObject, encrypted: encrypted, attachments: attachments, selfDestructionDate: selfDestructionDate, delayedDeliveryDate: delayedDeliveryDate, deadManDate: deadManDate) {(result) in
            
            switch(result) {
                
            case .success(let value):
                print("updateSendingMessage value:", value)
 
                if send {
                    self.mailWasSent()
                    self.postUpdateInboxNotification()
                } else {
                    self.sendingMessage = value as! EmailMessage
                }
                
            case .failure(let error):
                print("updateSendingMessage error:", error)
                AlertHelperKit().showAlert(self.viewController!, title: "Send Mail Error", message: error.localizedDescription, button: "closeButton".localized())
            }
        }
    }
    
    func publicKeysFor(userEmailsArray: Array<String>, completion:@escaping (Array<Key>) -> () ) {
        
        var recieversUsersPublicKeys = Array<Key>()
        
        apiService?.publicKeyFor(userEmailsArray: userEmailsArray) {(result) in
            
            switch(result) {
                
            case .success(let value):
                //print("publicKey value:", value)
                
                let publicKeysArray = value as! Array<String>
                
                for publicKey in publicKeysArray {
                    let userPublicKey = self.pgpService?.readPGPKeysFromString(key: publicKey)
                    recieversUsersPublicKeys = recieversUsersPublicKeys + userPublicKey!
                }
                
                if let userKeys = self.pgpService?.getStoredPGPKeys() { //add logged user public key
                    if userKeys.count > 0 {
                        recieversUsersPublicKeys.append(userKeys.first!)
                    }
                }
                //print("public keys: ", recieversUsersPublicKeys.count)
                
                completion(recieversUsersPublicKeys)

                //pgpService.extractAndSavePGPKeyFromString(key: publicKey)
                //pgpService.getStoredPGPKeys()
                
            case .failure(let error):
                completion(recieversUsersPublicKeys)
                print("error:", error)
                AlertHelperKit().showAlert(self.viewController!, title: "Public Key Error", message: error.localizedDescription, button: "closeButton".localized())
            }
        }
    }
    
    func setContactsData(contactsList: ContactsList) {
        
        if let contacts = contactsList.contactsList {
            self.viewController?.contactsList = contacts
            self.viewController?.presenter?.setContactsDataSource(contacts: contacts)
            self.viewController?.dataSource?.reloadData(setMailboxData: false)
        }
    }
    
    func userContactsList() {
        
        //HUD.show(.progress)
        
        apiService?.userContacts(fetchAll: true, offset: 0, silent: false) {(result) in
            
            switch(result) {
                
            case .success(let value):
                //print("userContactsList:", value)
                
                let contactsList = value as! ContactsList
                self.setContactsData(contactsList: contactsList)
                
            case .failure(let error):
                print("error:", error)
                AlertHelperKit().showAlert(self.viewController!, title: "Contacts Error", message: error.localizedDescription, button: "closeButton".localized())
            }
            
            //HUD.hide()
        }
    }
    
    func uploadAttach(fileUrl: URL, messageID : String) {
        
        let encrypt = self.viewController?.user.settings.isAttachmentsEncrypted ?? false
        
        apiService?.createAttachment(fileUrl: fileUrl, messageID: messageID, encrypt: encrypt) {(result) in
            
            self.viewController?.attachmentButton.isEnabled = true
            
            switch(result) {
                
            case .success(let value):
                print("create Attachment value:", value)
                
                let attachment = value as! Attachment
                self.viewController?.mailAttachmentsList.append(attachment.toDictionary())
                
            case .failure(let error):
                print("error:", error)
                AlertHelperKit().showAlert(self.viewController!, title: "Attach File Error", message: error.localizedDescription, button: "closeButton".localized())
            }
        }
    }
    
    func deleteAttach(attachID : String) {
        
        apiService?.deleteAttachment(attachmentID: attachID) {(result) in
            
            switch(result) {
                
            case .success(let value):
                print("deleteAttach value:", value)
         
                
            case .failure(let error):
                print("error:", error)
                AlertHelperKit().showAlert(self.viewController!, title: "Delete Attach File Error", message: error.localizedDescription, button: "closeButton".localized())
            }
        }
    }
    
    func setFilteredList(searchText: String) {
        
        print("searchText:",searchText)
        
        let contacts = (self.viewController?.contactsList)!
        
        let filteredContactNamesList = (contacts.filter({( contact : Contact) -> Bool in
            return (contact.contactName?.lowercased().contains(searchText.lowercased()) ?? false)
        }))
        
        let filteredEmailsList = (contacts.filter({( contact : Contact) -> Bool in
            return (contact.email?.lowercased().contains(searchText.lowercased()) ?? false)
        }))
        
        var filteredList = filteredContactNamesList + filteredEmailsList      
        
        if searchText.count == 0 {
            filteredList = contacts
        }
        
        self.presenter?.setContactsDataSource(contacts: filteredList.removingDuplicates())
        self.viewController?.dataSource?.searchText = searchText
        self.viewController?.dataSource?.reloadData(setMailboxData: false)
    }
    
    func mailWasSent() {
        
        let params = Parameters(
            title: "infoTitle".localized(),
            message: "mailSendMessage".localized(),
            cancelButton: "closeButton".localized()
        )
        
        AlertHelperKit().showAlertWithHandler(self.viewController!, parameters: params) { buttonIndex in
            print("close Coppose")
            self.viewController!.navigationController?.popViewController(animated: true)
        }
    }
    
    func postUpdateInboxNotification() {
        
        let silent = true
        
        NotificationCenter.default.post(name: Notification.Name(k_updateInboxMessagesNotificationID), object: silent, userInfo: nil)
    }
    
    //MARK: - prepared to send
    
    func prepareMessadgeToSend() {
                    
        self.publicKeysFor(userEmailsArray: self.viewController!.emailsToArray) { (keys) in
            print("publicKeys:", keys)
            
             if keys.count < 2 { //just logged user key or non
                self.sendEmailForNonCtemplarUser()
             } else {
                
                if let messageID = self.sendingMessage.messsageID {
                    let attachmentsCount = self.viewController!.mailAttachmentsList.count
                    if attachmentsCount > 0 && (self.viewController?.user.settings.isAttachmentsEncrypted)! {
                        self.updateAttachments(publicKeys: keys, messageID: messageID)
                    } else {
                        self.sendEncryptedEmailForCtemplarUser(publicKeys: keys)
                    }
                }
             }
        }
    }
    
    func createDraft() {
        
        var messageContent : String = ""
        
        messageContent = self.encryptMessageWithOwnPublicKey(message: messageContent)
        
        let recieversList = self.setRecieversList()
        
        self.createDraftMessage(parentID: "", content: messageContent, subject: self.viewController!.subject, recievers: recieversList, folder: MessagesFoldersName.draft.rawValue, mailboxID: (self.viewController?.mailboxID)!, send: false, encrypted: false, encryptionObject: [:], attachments: self.viewController!.mailAttachmentsList)
    }
    
    func createDraftWithParent(message: EmailMessage) {
        
        //let recievers = message.receivers as! Array<String>
        let recieversList = self.setRecieversList()
        
        let mailboxID = (self.viewController?.mailboxID)!
        
        var encryptionObjectDictionary =  [String : String]()
        
        if let encryptionObject = message.encryption {
            encryptionObjectDictionary = encryptionObject.toDictionary()
        }
        
        //temp
        //self.presenter?.setupAttachments(message: message)
        self.presenter?.setupMessageSectionSize()
        
        /*
        if let attachments = message.attachments {
            
            self.viewController?.mailAttachmentsList.removeAll()
            
            for attachment in attachments {
                self.viewController?.mailAttachmentsList.append(attachment.toDictionary())
            }
        }*/
        
        self.createDraftMessage(parentID: (message.messsageID?.description)!, content: message.content!, subject: message.subject!, recievers: recieversList, folder: MessagesFoldersName.draft.rawValue, mailboxID: mailboxID, send: false, encrypted: message.isEncrypted!, encryptionObject: encryptionObjectDictionary, attachments: self.viewController!.mailAttachmentsList)
    }
    
    func deleteDraft() {
        
        if let messageID = self.sendingMessage.messsageID {
            self.deleteDraftMessage(messageID: messageID.description)
        }
    }
    
    func saveDraft() {
        
        if let messageID = self.sendingMessage.messsageID {
            
            var encryptionObjectDictionary =  [String : String]()
            
            let encrypted = true//self.viewController!.encryptedMail //self.sendingMessage.isEncrypted
            
            var messageContent = self.getEnteredMessageContent()
            
            if encrypted {
                messageContent = self.encryptMessageWithOwnPublicKey(message: messageContent)
                
                if let encryptionObject = self.sendingMessage.encryption {
                    encryptionObjectDictionary = encryptionObject.toDictionary()
                }
            }
            
            let recieversList = self.setRecieversList()
            
            self.saveDraftMessage(messageID: messageID, messageContent: messageContent, encryptionObject: encryptionObjectDictionary, subject: self.viewController!.subject, send: false, recieversList: recieversList, encrypted: encrypted, selfDestructionDate: self.getScheduledDateFor(mode: SchedulerMode.selfDestructTimer), delayedDeliveryDate: self.getScheduledDateFor(mode: SchedulerMode.delayedDelivery), deadManDate: self.getScheduledDateFor(mode: SchedulerMode.deadManTimer))
        }
    }
    
    func setRecieversList() -> [[String]] {
        
        var recieversList = [[String]]()
        recieversList.append(self.viewController!.emailsToArray)
        recieversList.append(self.viewController!.ccToArray)
        recieversList.append(self.viewController!.bccToArray)
        
        return recieversList
    }
    
    func getEnteredMessageContent() -> String {
        
        var messageContent = self.viewController!.messageTextView.text
        
        if messageContent == "composeEmail".localized() {
            messageContent = ""
        }
        
        return messageContent!
    }
    
    func getScheduledDateFor(mode: SchedulerMode) -> String {
        
        var scheduledDateString: String = ""
        
        switch mode {
        case SchedulerMode.selfDestructTimer:
            if self.viewController?.selfDestructionDate != nil {
                scheduledDateString = (self.presenter?.formatterService?.formatSelfShedulerDateToSringForAPIRequirements(date: (self.viewController?.selfDestructionDate)!))!
            }
            break
        case SchedulerMode.deadManTimer:
            if self.viewController?.deadManDate != nil {
                if let minutesCount = self.viewController?.deadManDate.minutesCountFromNow() {
                    let hoursCount = lroundf(Float(minutesCount)/60.0)                
                    scheduledDateString = hoursCount.description
                }
            }
            break
        case SchedulerMode.delayedDelivery:
            if self.viewController?.delayedDeliveryDate != nil {
                scheduledDateString = (self.presenter?.formatterService?.formatSelfShedulerDateToSringForAPIRequirements(date: (self.viewController?.delayedDeliveryDate)!))!
            }
            break
        }
        
        return scheduledDateString
    }
    
    func sendEncryptedEmailForCtemplarUser(publicKeys: Array<Key>) {
        
        let messageContent = self.getEnteredMessageContent()
        
        let encryptedMessage = self.encryptMessage(publicKeys: publicKeys, message: messageContent)        
        
        let recieversList = self.setRecieversList()
        
        if let messageID = self.sendingMessage.messsageID {
            self.updateSendingMessage(messageID: messageID.description, encryptedMessage: encryptedMessage, encryptionObject: [:], subject: self.viewController!.subject, send: true, recieversList: recieversList, encrypted: true, attachments: self.viewController!.mailAttachmentsList, selfDestructionDate: self.getScheduledDateFor(mode: SchedulerMode.selfDestructTimer), delayedDeliveryDate: self.getScheduledDateFor(mode: SchedulerMode.delayedDelivery), deadManDate: self.getScheduledDateFor(mode: SchedulerMode.deadManTimer))
        }
    }
    
    func sendEmailForNonCtemplarUser() {
        
        var messageContent = self.getEnteredMessageContent()
        var encryptionObjectDictionary =  [String : String]()
        
        if self.viewController?.encryptedMail == true {
            
            if let encryptionObject = self.sendingMessage.encryption {
                
                let userName = self.sendingMessage.messsageID?.description
            
                if let nonCtemplarPGPKey = pgpService?.generatePGPKey(userName: userName!, password: self.setPassword) {
                
                    encryptionObjectDictionary = self.setPGPKeysForEncryptionObject(object: encryptionObject, pgpKey: nonCtemplarPGPKey)
                    
                    var pgpKeys = Array<Key>()
                    
                    if let userKeys = self.pgpService?.getStoredPGPKeys() {
                        if userKeys.count > 0 {
                            pgpKeys = userKeys
                        }
                    }
                    
                    pgpKeys.append(nonCtemplarPGPKey)
                    
                    messageContent = self.encryptMessage(publicKeys: pgpKeys, message: messageContent)
                    
                    let recieversList = self.setRecieversList()
                    
                    if let messageID = self.sendingMessage.messsageID {
                        self.updateSendingMessage(messageID: messageID.description, encryptedMessage: messageContent, encryptionObject: encryptionObjectDictionary, subject: self.viewController!.subject, send: true, recieversList: recieversList, encrypted: true, attachments: self.viewController!.mailAttachmentsList, selfDestructionDate: self.getScheduledDateFor(mode: SchedulerMode.selfDestructTimer), delayedDeliveryDate: self.getScheduledDateFor(mode: SchedulerMode.delayedDelivery), deadManDate: self.getScheduledDateFor(mode: SchedulerMode.deadManTimer))
                    }
                }
            }
            
        } else {
            
            if let messageID = self.sendingMessage.messsageID {
                
                let recieversList = self.setRecieversList()
                
                self.updateSendingMessage(messageID: messageID.description, encryptedMessage: messageContent, encryptionObject: [:], subject: self.viewController!.subject, send: true, recieversList: recieversList, encrypted: false, attachments: self.viewController!.mailAttachmentsList, selfDestructionDate: self.getScheduledDateFor(mode: SchedulerMode.selfDestructTimer), delayedDeliveryDate: self.getScheduledDateFor(mode: SchedulerMode.delayedDelivery), deadManDate: self.getScheduledDateFor(mode: SchedulerMode.deadManTimer))
            }
        }
    }
    
    func encryptMessageWithOwnPublicKey(message: String) -> String {
        
        var encryptedMessage: String = message
        
        if let userKeys = self.pgpService?.getStoredPGPKeys() {
            if userKeys.count > 0 {
                encryptedMessage = self.encryptMessage(publicKeys: userKeys, message: message)
            }
        }
        
        return encryptedMessage
    }
    
    func encryptMessage(publicKeys: Array<Key>, message: String) -> String {
        
        if let messageData = pgpService?.encodeString(message: message) {
            
            if let encryptedMessage = self.pgpService?.encrypt(data: messageData, keys: publicKeys) {
                print("encryptedMessage:", encryptedMessage)
                return encryptedMessage
            }
        }
        
        return ""
    }
    
    func sendPasswordForCreatingMessage(password: String, passwordHint: String, expiredTime: Int) {
        
        self.setPassword = password
  
        var messageContent : String = self.getEnteredMessageContent()
        
        messageContent = self.encryptMessageWithOwnPublicKey(message: messageContent)
        
        let encryptionObject = EncryptionObject.init(password: password, passwordHint: passwordHint, expiryHours: expiredTime).toShortDictionary()
        
        let recieversList = self.setRecieversList()
        
        if let messageID = self.sendingMessage.messsageID {
            self.updateSendingMessage(messageID: messageID.description, encryptedMessage: messageContent, encryptionObject: encryptionObject, subject: self.viewController!.subject, send: false, recieversList: recieversList, encrypted: true, attachments: self.viewController!.mailAttachmentsList, selfDestructionDate: self.getScheduledDateFor(mode: SchedulerMode.selfDestructTimer), delayedDeliveryDate: self.getScheduledDateFor(mode: SchedulerMode.delayedDelivery), deadManDate: self.getScheduledDateFor(mode: SchedulerMode.deadManTimer))
        }
    }
    
    func setPGPKeysForEncryptionObject(object: EncryptionObject, pgpKey: Key) -> [String : String] {
        
        var encryptionObjectDictionary =  [String : String]()
        var encryptionObject = object
        
        let publicKey = self.pgpService?.exportArmoredPublicKey(pgpKey: pgpKey)
        let privateKey = self.pgpService?.exportArmoredPrivateKey(pgpKey: pgpKey)
            
        encryptionObject.setPGPKeys(publicKey: publicKey!, privateKey: privateKey!)
        encryptionObjectDictionary = encryptionObject.toDictionary()
        
        return encryptionObjectDictionary
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
    
    func setupSubject(subject: String, message: EmailMessage, answerMode: AnswerMessageMode) {
        
        if (apiService?.isSubjectEncrypted(message: message))! {
            self.extractSubjectContentAsync(message: message, answerMode: answerMode)
        } else {
            self.presenter?.setupSubject(subjectText: subject, answerMode: answerMode)
        }
    }
    
    func extractSubjectContentAsync(message: EmailMessage, answerMode: AnswerMessageMode) {
        
        let queue = DispatchQueue.global(qos: .userInitiated)
        
        queue.async {
            if let content = message.subject {
                if let decryptedSubject = self.pgpService?.decryptMessage(encryptedContet: content) {
                    DispatchQueue.main.async {
                        self.presenter?.setupSubject(subjectText: decryptedSubject, answerMode: answerMode)
                    }
                }
            }
        }
    }
    
    //MARK: - Attachments
    
    func attachFileToDraftMessage(url: URL) {
        
        if let messageID = self.sendingMessage.messsageID {
            self.uploadAttach(fileUrl: url, messageID: messageID.description)
        }
    }
    
    func removeAttachFromMailAttachmentList(file: URL) {
        
        for (index, attach) in self.viewController!.mailAttachmentsList.enumerated() {
            
            let fileName = file.lastPathComponent
            print("fileName:", fileName)
            
            let attachFileName = (attach["document"]! as NSString).lastPathComponent
            print("attachFileName:", attachFileName)
            
            let attachID = attach["id"]
            print("attachID:", attachID as Any)
            
            if attachFileName == fileName {
                self.viewController!.mailAttachmentsList.remove(at: index)
                self.deleteAttach(attachID: attachID!)
            }
        }
    }
    
    func updateAttachments(publicKeys: Array<Key>, messageID: Int) {
        
        var attachmentsCount = self.viewController!.mailAttachmentsList.count
        
        for attach in self.viewController!.mailAttachmentsList {
            
            if let attachFileUrl = attach["localUrl"] {
                
                let attachID = attach["id"]
                
                let fileUrl = URL(fileURLWithPath: attachFileUrl)
                
                if let fileData = try? Data(contentsOf: fileUrl) {
                
                    if (self.viewController?.user.settings.isAttachmentsEncrypted)! {
                        if publicKeys.count > 0 {
                            let encryptedfileData = pgpService?.encryptAsData(data: fileData, keys: publicKeys)
                            
                            apiService?.updateAttachment(attachmentID: attachID!, fileUrl: fileUrl, fileData: encryptedfileData!, messageID: messageID, encrypt: true) { updated in
                                
                                attachmentsCount = attachmentsCount - 1
                                if attachmentsCount == 0 {
                                    self.sendEncryptedEmailForCtemplarUser(publicKeys: publicKeys)
                                }
                            }
                        } else {// if send to non-CT user
                            apiService?.updateAttachment(attachmentID: attachID!, fileUrl: fileUrl, fileData: fileData, messageID: messageID, encrypt: false) { updated in
                                
                                attachmentsCount = attachmentsCount - 1
                                if attachmentsCount == 0 {
                                    //self.sendEmailForNonCtemplarUser()
                                }
                            }
                        }
                    } else { //if attachment encryption is disabled
                        apiService?.updateAttachment(attachmentID: attachID!, fileUrl: fileUrl, fileData: fileData, messageID: messageID, encrypt: false) { updated in
                            
                            attachmentsCount = attachmentsCount - 1
                            if attachmentsCount == 0 {
                                self.sendEncryptedEmailForCtemplarUser(publicKeys: publicKeys)
                            }
                        }
                    }
                    
                } else {
                    print("attach fileData is nil")
                }
            }
        }
    }
    
    //MARK: - textView delegate
    
    func holdEmailToTextViewInput(textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
                
        //forbid to delete Prefix "
        if self.forbidDeletion(range: range, prefix: "emailToPrefix".localized()) {
            self.presenter!.enabledSendButton()
            return false
        }
        
        if self.getCursorPosition(textView: textView) < "emailToPrefix".localized().count {
            self.setCursorPositionToEnd(textView: textView)
            self.presenter!.enabledSendButton()
            return false
        }
                
        if self.returnPressed(input: text) {
            /*
            let inputDroppedPrefixText = self.dropPrefix(text: textView.text, prefix: "emailToPrefix".localized())
            //let inputEmail = self.getLastInputEmail(input: inputDroppedPrefixText)
            let inputEmail = self.getLastInputText(input: inputDroppedPrefixText, emailsArray: self.viewController!.emailsToArray)
            
            self.setEmail(textView: textView, inputEmail: inputEmail, clearInputtedChars: false)
            */
            self.viewController?.view.endEditing(true)
            
            return false
        }
        
        if self.spacePressed(input: text) {
            /*
            let inputDroppedPrefixText = self.dropPrefix(text: textView.text, prefix: "emailToPrefix".localized())
            let inputEmail = self.getLastInputText(input: inputDroppedPrefixText, emailsArray: self.viewController!.emailsToArray)
            
            self.setEmail(textView: textView, inputEmail: inputEmail, clearInputtedChars: false)
            */
            self.viewController?.view.endEditing(true)
            
            return false
        }
        
        if self.backspacePressed(input: text, range: range) {
            
            if self.viewController!.tapSelectedEmail.count > 0 {
                
                self.viewController!.emailsToArray.removeAll{ $0 == self.viewController!.tapSelectedEmail }
                print("self.emailsToArray.count after Taped Email deleted:", self.viewController!.emailsToArray.count)
                
                let formattedEmail = "<" + self.viewController!.tapSelectedEmail + ">"
                
                self.viewController!.emailToSting = self.viewController!.emailToSting.replacingOccurrences(of: formattedEmail, with: "")
                self.viewController!.tapSelectedEmail = ""
                
                self.viewController!.emailToSting = self.viewController!.emailToSting.replacingOccurrences(of: "  ", with: " ")//remove double spaces
                
                self.presenter?.setupEmailToSection(emailToText: self.viewController!.emailToSting, ccToText: self.viewController!.ccToSting, bccToText: self.viewController!.bccToSting)
                self.viewController!.view.endEditing(true)
                
            } else {
                
                if let editingWord = self.getLastWord(textView: textView) {
                   
                    if editingWord == "" {
                        print("delete space")
                        if let lastEmail =  self.viewController!.emailsToArray.last {
                            print("removed lastEmail:", lastEmail)
                            self.viewController!.tapSelectedEmail = lastEmail
                            self.presenter?.setupEmailToSection(emailToText: self.viewController!.emailToSting, ccToText: self.viewController!.ccToSting, bccToText: self.viewController!.bccToSting)
                        } else {
                            //return false //just delete space
                        }
                    } else {
                        print("removed Word:", editingWord)
                        //self.viewController!.emailsToArray.removeAll{ $0 == editingWord }
                        //print("emailsToArray count:", self.viewController!.emailsToArray.count)
                    }
                }
                
                self.presenter?.setupTableView(topOffset: k_composeTableViewTopOffset + self.viewController!.emailToSectionView.frame.height - 5.0)
                
                self.viewController!.tableView.isHidden = false
            }
        } else {
            if self.viewController!.tapSelectedEmail.count > 0 {
                self.presenter!.enabledSendButton()
                return false //disable edit if Email selected, only delete by Backspace
            }
        }
        
        self.presenter!.enabledSendButton()
        
        return true
    }
    
    func holdCcToTextViewInput(textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if self.forbidDeletion(range: range, prefix: "ccToPrefix".localized()) {
            return false
        }
        
        if self.getCursorPosition(textView: textView) < "ccToPrefix".localized().count {
            self.setCursorPositionToEnd(textView: textView)
            return false
        }
        
        if self.returnPressed(input: text) {
            /*
            let inputDroppedPrefixText = self.dropPrefix(text: textView.text, prefix: "ccToPrefix".localized())
            //let inputCcEmail = self.getLastInputEmail(input: inputDroppedPrefixText)
            let inputCcEmail = self.getLastInputText(input: inputDroppedPrefixText, emailsArray: self.viewController!.ccToArray)
            
            self.setEmail(textView: textView, inputEmail: inputCcEmail, clearInputtedChars: false)
             */
            self.viewController?.view.endEditing(true)
            return false
        }
        
        if self.spacePressed(input: text) {
            /*
            let inputDroppedPrefixText = self.dropPrefix(text: textView.text, prefix: "ccToPrefix".localized())
            let inputCcEmail = self.getLastInputText(input: inputDroppedPrefixText, emailsArray: self.viewController!.ccToArray)
            
            self.setEmail(textView: textView, inputEmail: inputCcEmail, clearInputtedChars: false)
            */
            
            self.viewController?.view.endEditing(true)
            return false
        }
        
        if self.backspacePressed(input: text, range: range) {
            
            if self.viewController!.tapSelectedCcEmail.count > 0 {
                
                self.viewController!.ccToArray.removeAll{ $0 == self.viewController!.tapSelectedCcEmail }
                print("ccToArray count after Taped Email deleted:", self.viewController!.ccToArray.count)
                
                let formattedEmail = "<" + self.viewController!.tapSelectedCcEmail + ">"
                self.viewController!.ccToSting = self.viewController!.ccToSting.replacingOccurrences(of: formattedEmail, with: "")
                self.viewController!.tapSelectedCcEmail = ""
                
                self.viewController!.emailToSting = self.viewController!.emailToSting.replacingOccurrences(of: "  ", with: " ")//remove double spaces
                
                self.presenter?.setupEmailToSection(emailToText: self.viewController!.emailToSting, ccToText: self.viewController!.ccToSting, bccToText: self.viewController!.bccToSting)
                self.viewController!.view.endEditing(true)
                
            } else {
                
                if let editingWord = self.getLastWord(textView: textView) {
                    
                    if editingWord == "" {
                        print("delete space")
                        if let lastEmail =  self.viewController!.ccToArray.last {
                            self.viewController!.tapSelectedCcEmail = lastEmail
                            self.presenter?.setupEmailToSection(emailToText: self.viewController!.emailToSting, ccToText: self.viewController!.ccToSting, bccToText: self.viewController!.bccToSting)
                        } else {
                            //return false
                        }
                    } else {
                        print("removed Word:", editingWord)
                        self.viewController!.ccToArray.removeAll{ $0 == editingWord }
                        print("ccToArray count:", self.viewController!.ccToArray.count)
                    }
                }
                
                self.presenter?.setupTableView(topOffset: k_composeTableViewTopOffset + self.viewController!.emailToSectionView.frame.height - 5.0)
                
                self.viewController!.tableView.isHidden = false
            }
        } else {
            if self.viewController!.tapSelectedCcEmail.count > 0 {
                return false //disable edit if Email selected, only delete by Backspace
            }
        }
        
        return true
    }
    
    func holdBccToTextViewInput(textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if self.forbidDeletion(range: range, prefix: "bccToPrefix".localized()) {
            return false
        }
        
        if self.getCursorPosition(textView: textView) < "bccToPrefix".localized().count {
            self.setCursorPositionToEnd(textView: textView)
            return false
        }
        
        if self.returnPressed(input: text) {
            /*
            let inputDroppedPrefixText = self.dropPrefix(text: textView.text, prefix: "bccToPrefix".localized())
            //let inputBccEmail = self.getLastInputEmail(input: inputDroppedPrefixText)
            let inputBccEmail = self.getLastInputText(input: inputDroppedPrefixText, emailsArray: self.viewController!.bccToArray)
            
            self.setEmail(textView: textView, inputEmail: inputBccEmail, clearInputtedChars: false)
            */
            self.viewController?.view.endEditing(true)
            return false
        }
        
        if self.spacePressed(input: text) {
            /*
            let inputDroppedPrefixText = self.dropPrefix(text: textView.text, prefix: "bccToPrefix".localized())
            let inputBccEmail = self.getLastInputText(input: inputDroppedPrefixText, emailsArray: self.viewController!.bccToArray)
            
            self.setEmail(textView: textView, inputEmail: inputBccEmail, clearInputtedChars: false)
            */
            self.viewController?.view.endEditing(true)
            return false
        }
        
        if self.backspacePressed(input: text, range: range) {
            
            if self.viewController!.tapSelectedBccEmail.count > 0 {
                
                self.viewController!.bccToArray.removeAll{ $0 == self.viewController!.tapSelectedBccEmail }
                print("bccToArray count after Taped Email deleted:", self.viewController!.bccToArray.count)
                
                let formattedEmail = "<" + self.viewController!.tapSelectedBccEmail + ">"
                self.viewController!.bccToSting = self.viewController!.bccToSting.replacingOccurrences(of: formattedEmail, with: "")
                self.viewController!.tapSelectedBccEmail = ""
                
                self.viewController!.emailToSting = self.viewController!.emailToSting.replacingOccurrences(of: "  ", with: " ")//remove double spaces
                
                self.presenter?.setupEmailToSection(emailToText: self.viewController!.emailToSting, ccToText: self.viewController!.ccToSting, bccToText: self.viewController!.bccToSting)
                self.viewController!.view.endEditing(true)
                
            } else {
                
                if let editingWord = self.getLastWord(textView: textView) {
                    
                    if editingWord == "" {
                        print("delete space")
                        if let lastEmail =  self.viewController!.bccToArray.last {
                            self.viewController!.tapSelectedBccEmail = lastEmail
                            self.presenter?.setupEmailToSection(emailToText: self.viewController!.emailToSting, ccToText: self.viewController!.ccToSting, bccToText: self.viewController!.bccToSting)
                        } else {
                            //return false
                        }
                    } else {
                        print("removed Word:", editingWord)
                        self.viewController!.bccToArray.removeAll{ $0 == editingWord }
                        print("bccToArray count:", self.viewController!.bccToArray.count)
                    }
                }
                
                self.presenter?.setupTableView(topOffset: k_composeTableViewTopOffset + self.viewController!.emailToSectionView.frame.height - 5.0)
                self.viewController!.tableView.isHidden = false
            }
        } else {
            if self.viewController!.tapSelectedBccEmail.count > 0 {
                return false //disable edit if Email selected, only delete by Backspace
            }
        }
        
        return true
    }
    
    func addEmailTo(textView: UITextView, inputEmail: String) {
        
        self.setFilteredList(searchText: "")
        let lastInput = self.getLastWord(textView: textView)
        let text = textView.text.dropLast((lastInput?.count)!) //remove inputted chars
        textView.text = text + inputEmail
        
        self.viewController!.view.endEditing(true)
    }
    
    func setEmail(textView: UITextView, inputEmail: String, clearInputtedChars: Bool) {
        
        var inputText : String = ""
        
        if clearInputtedChars {
            self.setFilteredList(searchText: "")
            let lastInput = self.getLastWord(textView: textView)
            let text = textView.text.dropLast((lastInput?.count)!)
            //inputText = text + inputEmail + " "
            inputText = text + " <" + inputEmail + "> "
        } else {
            if inputEmail.count > 0 {
                //inputText = textView.text + " "
                let textBefore = String(textView.text.dropLast(inputEmail.count))
                print("textBefore", textBefore)
                inputText = textBefore + " <" + inputEmail + "> "
                
            } else {
                inputText = textView.text + " " //if user want to delete email, delete backspace after input, but change self mind
                //hide keyboard?
            }
        }
        
        switch textView {
        case self.viewController!.emailToTextView:
            print("inputEmail:", inputEmail as Any)
            
            if (self.presenter?.findDuplicatedEmails(emailArray: self.viewController!.emailsToArray, currentEmail: inputEmail))! {
                let textBefore = String(textView.text.dropLast(inputEmail.count))
                self.viewController!.emailToSting = textBefore
            } else {
                if inputEmail.count > 0 {
                    self.viewController!.emailsToArray.append(inputEmail)
                }
                self.viewController!.emailToSting = inputText
            }
            
            self.viewController!.emailToSting = self.viewController!.emailToSting.replacingOccurrences(of: "  ", with: " ")//remove double spaces
            
            break
        case self.viewController!.ccToTextView:
            print("inputCcEmail:", inputEmail as Any)
            
            if (self.presenter?.findDuplicatedEmails(emailArray: self.viewController!.ccToArray, currentEmail: inputEmail))! {
                let textBefore = String(textView.text.dropLast(inputEmail.count))
                self.viewController!.ccToSting = textBefore
            } else {
                if inputEmail.count > 0 {
                    self.viewController!.ccToArray.append(inputEmail)
                }
                self.viewController!.ccToSting = inputText
            }
     
            self.viewController!.ccToSting = self.viewController!.ccToSting.replacingOccurrences(of: "  ", with: " ")//remove double spaces
            break
        case self.viewController!.bccToTextView:
            print("inputBccEmail:", inputEmail as Any)
            
            if (self.presenter?.findDuplicatedEmails(emailArray: self.viewController!.bccToArray, currentEmail: inputEmail))! {
                let textBefore = String(textView.text.dropLast(inputEmail.count))
                self.viewController!.bccToSting = textBefore
            } else {
                if inputEmail.count > 0 {
                    self.viewController!.bccToArray.append(inputEmail)
                }
                self.viewController!.bccToSting = inputText
            }

            self.viewController!.bccToSting = self.viewController!.bccToSting.replacingOccurrences(of: "  ", with: " ")//remove double spaces
            break
        default:
            break
        }
        
        self.presenter?.setupEmailToSection(emailToText: self.viewController!.emailToSting, ccToText: self.viewController!.ccToSting, bccToText: self.viewController!.bccToSting)
        
        self.setCursorPositionToEnd(textView: textView)
        self.presenter!.enabledSendButton()
        
        if clearInputtedChars {
            //self.viewController!.view.endEditing(true)
            //textView.becomeFirstResponder()
        }
    }
    
    //MARK: - textView private methods
    
    func getCursorPosition(textView: UITextView) -> Int {
        
        if let selectedRange = textView.selectedTextRange {
            
            let cursorPosition = textView.offset(from: textView.beginningOfDocument, to: selectedRange.start)
            print("cusor Pos:" + "\(cursorPosition)")
            return cursorPosition
        }
        
        return 0
    }
    
    func setCursorPositionToEnd(textView: UITextView) {
        
        print("set cursor:", textView.text.count)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(10), execute: {
            textView.selectedRange = NSRange(location: textView.text.count, length: 0)
            
            let newPosition = textView.endOfDocument
            textView.selectedTextRange = textView.textRange(from: newPosition, to: newPosition)
        })
    }
    
    func forbidDeletion(range: NSRange, prefix: String) -> Bool {
        
        if range.location == prefix.count - 1 && range.length == 1 {
            return true
        }
        
        return false
    }
    
    func returnPressed(input: String) -> Bool {
        
        if input == "\n" {
            print("return pressed")
            return true
        }
        
        return false
    }
    
    func backspacePressed(input: String, range: NSRange)  -> Bool {
        
        if input == "" && range.length > 0 {
            print("backspace pressed")
            return true
        }
        
        return false
    }
    
    func spacePressed(input: String) -> Bool {
        
        if input == " " {
            print("space pressed")
            return true
        }
        
        return false
    }
    
    func getLastInputEmail(input: String) -> String {
        
        let substrings = input.split(separator: " ")
        
        if let sub = substrings.last {
            return String(sub)
        }
        
        return ""
    }
    
    func getLastInputText(input: String, emailsArray: Array<String>) -> String {
        
        let substrings = input.split(separator: " ")
        
        if emailsArray.count == substrings.count {
            return ""
        }
        
        if let sub = substrings.last {
            return String(sub)
        }
        
        return ""
    }
    
    func getLastInputEmail(input: String, prevText: String) -> String {
        
        guard input.hasPrefix(prevText) else { return input }
        
        return String(input.dropFirst(prevText.count))
    }
    
    func dropPrefix(text: String, prefix: String) -> String {
        
        guard text.hasPrefix(prefix) else { return text }
        
        return String(text.dropFirst(prefix.count))
    }
    
    func checkEnteredEmailsValidation() {
        
    }
        
    func getWordAtPosition(_ point: CGPoint, textView: UITextView) -> String? {
        
        let position: CGPoint = CGPoint(x: point.x, y: point.y)
        let tapPosition: UITextPosition? = textView.closestPosition(to: position)
        
        let cursorPosition = textView.offset(from: textView.beginningOfDocument, to: tapPosition!)
        
        //print("tapPosition:", tapPosition)
        print("cursorPosition:", cursorPosition)
        
        if cursorPosition < "emailToPrefix".localized().count {
            return nil
        }
        
        let text = textView.text
        let substrings = text?.split(separator: " ")
        
        print("substrings:", substrings as Any)
        
        var index = 0
        
        var selectedWord = ""
        
        for sub in substrings! {
            index = index + sub.count
            print("sub:", sub, "index: ", index)
            if cursorPosition < index {
                selectedWord = String(sub)
                print("selectedWord0:", selectedWord)
                let formattedWord = selectedWord.dropLast().dropFirst()
                return String(formattedWord)
            }
        }
        
        print("selectedWord:", selectedWord)
        
        /*
         if let textPosition = textView.closestPosition(to: point) {
         if let range = textView.tokenizer.rangeEnclosingPosition(textPosition, with: .word, inDirection: UITextDirection(rawValue: 1)) {
         
         return textView.text(in: range)
         }
         }*/
        
        return nil
    }
    
    func getCurrentEditingWord(textView: UITextView) -> String? {
        
        let cursorOffset = self.getCursorPosition(textView: textView)
        
        print("cursorOffset:", cursorOffset)
        
        let text = textView.text
        //let substring = text?.prefix(cursorOffset)
        
        //let rightPartText = text?.suffix(cursorOffset)
        //print("rightPartText:", rightPartText)
        
        
        //let str = wordRangeAtIndex(index: cursorOffset, inString: text!)
        // print("str:", str)
        
        let substrings = text?.split(separator: " ")
        
        print("substrings:", substrings as Any)
        
        var index = 0
        
        var selectedWord = ""
        
        for sub in substrings! {
            index = index + sub.count
            print("sub:", sub, "index: ", index)
            if cursorOffset < index {
                selectedWord = String(sub)
            }
        }
        
        
        //let nextSubstring = text?.suffix(cursorOffset)
        //let rightPart = nextSubstring?.components(separatedBy: " ").first
        
        //let editedWord = substring?.components(separatedBy: " ").last
        
        //print("sub:", substrings)
        print("selectedWord:", selectedWord)
        //print("leftPart:", editedWord)
        //print("rightPart:", rightPart)
        
        return selectedWord
    }
    
    func getLastWord(textView: UITextView) -> String? {
        
        let cursorOffset = self.getCursorPosition(textView: textView)
        
        let text = textView.text
        let substring = (text as NSString?)?.substring(to: cursorOffset)
        
        let editedWord = substring?.components(separatedBy: " ").last
        
        return editedWord
    }
}
