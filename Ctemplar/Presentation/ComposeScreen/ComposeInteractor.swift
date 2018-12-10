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
    
    func createDraftMessage(content: String, subject: String, recievers: Array<String>, folder: String, mailboxID: Int, send: Bool, encrypted: Bool, encryptionObject: [String : String]) {
        
        apiService?.createMessage(content: content, subject: subject, recieversList: recievers, folder: folder, mailboxID: mailboxID, send: send, encrypted: encrypted, encryptionObject: encryptionObject) {(result) in
            
            switch(result) {
                
            case .success(let value):
                print("createMessage value:", value)
                self.sendingMessage = value as! EmailMessage
                
            case .failure(let error):
                print("error:", error)
                AlertHelperKit().showAlert(self.viewController!, title: "Send Mail Error", message: error.localizedDescription, button: "closeButton".localized())
            }
        }
    }
    
    func deleteDraftMessage(messageID: String) {
        
        apiService?.deleteMessages(messagesIDIn: messageID) {(result) in
            
            switch(result) {
                
            case .success(let value):
                print("delete Draft value:", value)
                //self.postUpdateInboxNotification()
                
            case .failure(let error):
                print("error:", error)
                AlertHelperKit().showAlert(self.viewController!, title: "Messages Error", message: error.localizedDescription, button: "closeButton".localized())
            }
        }
    }
    
    func updateSendingMessage(messsageID: String, encryptedMessage: String, encryptionObject: [String : String], subject: String, send: Bool, recieversList: Array<String>, encrypted: Bool, attachments: Array<[String : String]>) {
        
        apiService?.updateSendingMessage(messageID: messsageID, encryptedMessage: encryptedMessage, subject: subject, recieversList: recieversList, folder: MessagesFoldersName.sent.rawValue, send: send, encryptionObject: encryptionObject, encrypted: encrypted, attachments: attachments) {(result) in
            
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
        }
    }
    
    func userContactsList() {
        
        //HUD.show(.progress)
        
        apiService?.userContacts(contactsIDIn: "") {(result) in
            
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
        
        apiService?.createAttachment(fileUrl: fileUrl, messageID: messageID) {(result) in
            
            self.viewController?.attachmentButton.isEnabled = true
            
            switch(result) {
                
            case .success(let value):
                print("create Attachment value:", value)
                
                let attachment = value as! Attachment
                self.viewController?.mailAttachmentsList.append(attachment.toDictionary())                
                self.presenter?.setupMessageSectionSize()
                
            case .failure(let error):
                print("error:", error)
                AlertHelperKit().showAlert(self.viewController!, title: "Attach File Error", message: error.localizedDescription, button: "closeButton".localized())
            }
        }
    }
    
    func setFilteredList(searchText: String) {
        
        print("searchText:",searchText)
        
        let contacts = (self.viewController?.contactsList)!
        
        let filteredContactNamesList = (contacts.filter({( contact : Contact) -> Bool in
            return (contact.contactName?.lowercased().contains(searchText.lowercased()))!
        }))
        
        let filteredEmailsList = (contacts.filter({( contact : Contact) -> Bool in
            return (contact.email?.lowercased().contains(searchText.lowercased()))!
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
                self.sendEncryptedEmailForCtemplarUser(publicKeys: keys)
             }
        }
    }
    
    func createDraft() {
        
        var message : String = ""
        
        if let userKeys = self.pgpService?.getStoredPGPKeys() {
            if userKeys.count > 0 {
                message = self.encryptMessage(publicKeys: userKeys, message: message/*self.viewController!.messageTextView.text*/)
            }
        }
        
        self.createDraftMessage(content: message, subject: self.viewController!.subject, recievers: self.viewController!.emailsToArray, folder: MessagesFoldersName.draft.rawValue, mailboxID: (self.viewController?.mailboxID)!, send: false, encrypted: false, encryptionObject: [:])
    }
    
    func deleteDraft() {
        
        if let messageID = self.sendingMessage.messsageID {
            self.deleteDraftMessage(messageID: messageID.description)
        }
    }
    
    func sendEncryptedEmailForCtemplarUser(publicKeys: Array<Key>) {
        
        let encryptedMessage = self.encryptMessage(publicKeys: publicKeys, message: self.viewController!.messageTextView.text)
        
        if let messageID = self.sendingMessage.messsageID {
            self.updateSendingMessage(messsageID: messageID.description, encryptedMessage: encryptedMessage, encryptionObject: [:], subject: self.viewController!.subject, send: true, recieversList: self.viewController!.emailsToArray, encrypted: true, attachments: self.viewController!.mailAttachmentsList)
        }
    }
    
    func sendEmailForNonCtemplarUser() {
        
        var message : String = ""
        var encryptionObjectDictionary =  [String : String]()
        //let folder : String = MessagesFoldersName.sent.rawValue
        
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
                    
                    message = self.encryptMessage(publicKeys: pgpKeys, message: self.viewController!.messageTextView.text)
                    
                    //self.updateSendingMessage(messsageID: (self.sendingMessage.messsageID?.description)!, encryptedMessage: message, encryptionObject: encryptionObjectDictionary)
                    
                    if let messageID = self.sendingMessage.messsageID {
                        self.updateSendingMessage(messsageID: messageID.description, encryptedMessage: message, encryptionObject: encryptionObjectDictionary, subject: self.viewController!.subject, send: true, recieversList: self.viewController!.emailsToArray, encrypted: true, attachments: self.viewController!.mailAttachmentsList)
                    }
                }
            }
            
        } else {
            
            message = self.viewController!.messageTextView.text
        
            if let messageID = self.sendingMessage.messsageID {
                self.updateSendingMessage(messsageID: messageID.description, encryptedMessage: message, encryptionObject: [:], subject: self.viewController!.subject, send: true, recieversList: self.viewController!.emailsToArray, encrypted: false, attachments: self.viewController!.mailAttachmentsList)
            }
        }
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
    
    func sendPasswordForCreatingMessage(password: String, passwordHint: String) {
        
        self.setPassword = password
        
        var message : String = ""
        
        if let userKeys = self.pgpService?.getStoredPGPKeys() {
            if userKeys.count > 0 {
                message = self.encryptMessage(publicKeys: userKeys, message: self.viewController!.messageTextView.text)
            }
        }
        
        let encryptionObject = EncryptionObject.init(password: password, passwordHint: passwordHint).toShortDictionary()
        
        if let messageID = self.sendingMessage.messsageID {
            self.updateSendingMessage(messsageID: messageID.description, encryptedMessage: message, encryptionObject: encryptionObject, subject: self.viewController!.subject, send: false, recieversList: self.viewController!.emailsToArray, encrypted: true, attachments: self.viewController!.mailAttachmentsList)
        }
    }
    
    func setPGPKeysForEncryptionObject(object: EncryptionObject, pgpKey: Key) -> [String : String] {
        
        var encryptionObjectDictionary =  [String : String]()
        var encryptionObject = object
        
        let publicKey = self.pgpService?.generateArmoredPublicKey(pgpKey: pgpKey)
        let privateKey = self.pgpService?.generateArmoredPrivateKey(pgpKey: pgpKey)
            
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
    
    //MARK: - Attachments
    
    func attachFileToDraftMessage(url: URL) {
        
        if let messageID = self.sendingMessage.messsageID {
            self.uploadAttach(fileUrl: url, messageID: messageID.description)
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
            
            let inputDroppedPrefixText = self.dropPrefix(text: textView.text, prefix: "emailToPrefix".localized())
            //let inputEmail = self.getLastInputEmail(input: inputDroppedPrefixText)
            let inputEmail = self.getLastInputText(input: inputDroppedPrefixText, emailsArray: self.viewController!.emailsToArray)
            
            self.setEmail(textView: textView, inputEmail: inputEmail, addSelected: false)
            
            return false
        }
        
        if self.backspacePressed(input: text, range: range) {
            
            if self.viewController!.tapSelectedEmail.count > 0 {
                
                self.viewController!.emailsToArray.removeAll{ $0 == self.viewController!.tapSelectedEmail }
                print("self.emailsToArray.count after Taped Email deleted:", self.viewController!.emailsToArray.count)
                
                self.viewController!.emailToSting = self.viewController!.emailToSting.replacingOccurrences(of: self.viewController!.tapSelectedEmail, with: "")
                self.viewController!.tapSelectedEmail = ""
                
                self.presenter?.setupEmailToSection(emailToText: self.viewController!.emailToSting, ccToText: self.viewController!.ccToSting, bccToText: self.viewController!.bccToSting)
                self.viewController!.view.endEditing(true)
                
            } else {
                
                if let editingWord = self.getLastWord(textView: textView) {
                   
                    print("removed Word:", editingWord)
                    self.viewController!.emailsToArray.removeAll{ $0 == editingWord }
                    print("emailsToArray count:", self.viewController!.emailsToArray.count)
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
            
            let inputDroppedPrefixText = self.dropPrefix(text: textView.text, prefix: "ccToPrefix".localized())
            //let inputCcEmail = self.getLastInputEmail(input: inputDroppedPrefixText)
            let inputCcEmail = self.getLastInputText(input: inputDroppedPrefixText, emailsArray: self.viewController!.ccToArray)
            
            self.setEmail(textView: textView, inputEmail: inputCcEmail, addSelected: false)

            return false
        }
        
        if self.backspacePressed(input: text, range: range) {
            
            if self.viewController!.tapSelectedCcEmail.count > 0 {
                
                self.viewController!.ccToArray.removeAll{ $0 == self.viewController!.tapSelectedCcEmail }
                print("ccToArray count after Taped Email deleted:", self.viewController!.ccToArray.count)
                
                self.viewController!.ccToSting = self.viewController!.ccToSting.replacingOccurrences(of: self.viewController!.tapSelectedCcEmail, with: "")
                self.viewController!.tapSelectedCcEmail = ""
                
                self.presenter?.setupEmailToSection(emailToText: self.viewController!.emailToSting, ccToText: self.viewController!.ccToSting, bccToText: self.viewController!.bccToSting)
                self.viewController!.view.endEditing(true)
                
            } else {
                
                if let editingWord = self.getLastWord(textView: textView) {
                    
                    print("removed Word:", editingWord)
                    self.viewController!.ccToArray.removeAll{ $0 == editingWord }
                    print("ccToArray count:", self.viewController!.ccToArray.count)                    
                }
                
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
            
            let inputDroppedPrefixText = self.dropPrefix(text: textView.text, prefix: "bccToPrefix".localized())
            //let inputBccEmail = self.getLastInputEmail(input: inputDroppedPrefixText)
            let inputBccEmail = self.getLastInputText(input: inputDroppedPrefixText, emailsArray: self.viewController!.bccToArray)
            
            self.setEmail(textView: textView, inputEmail: inputBccEmail, addSelected: false)

            return false
        }
        
        if self.backspacePressed(input: text, range: range) {
            
            if self.viewController!.tapSelectedBccEmail.count > 0 {
                
                self.viewController!.bccToArray.removeAll{ $0 == self.viewController!.tapSelectedBccEmail }
                print("bccToArray count after Taped Email deleted:", self.viewController!.bccToArray.count)
                
                self.viewController!.bccToSting = self.viewController!.bccToSting.replacingOccurrences(of: self.viewController!.tapSelectedBccEmail, with: "")
                self.viewController!.tapSelectedBccEmail = ""
                
                self.presenter?.setupEmailToSection(emailToText: self.viewController!.emailToSting, ccToText: self.viewController!.ccToSting, bccToText: self.viewController!.bccToSting)
                self.viewController!.view.endEditing(true)
                
            } else {
                
                if let editingWord = self.getLastWord(textView: textView) {
                    
                    print("removed Word:", editingWord)
                    self.viewController!.bccToArray.removeAll{ $0 == editingWord }
                    print("bccToArray count:", self.viewController!.bccToArray.count)
                }
                
                self.viewController!.tableView.isHidden = false
            }
        } else {
            if self.viewController!.tapSelectedBccEmail.count > 0 {
                return false //disable edit if Email selected, only delete by Backspace
            }
        }
        
        return true
    }
    
    func setEmail(textView: UITextView, inputEmail: String, addSelected: Bool) {
        
        var inputText : String = ""
        
        if addSelected {
            self.setFilteredList(searchText: "")
            inputText = textView.text + inputEmail + " "
            //inputText = textView.text + " <" + inputEmail + "> "
        } else {
            if inputEmail.count > 0 {
                inputText = textView.text + " "
                //let textBefore = String(textView.text.dropLast(inputEmail.count))
                //print("textBefore", textBefore)
                //inputText = textBefore + " <" + inputEmail + "> "
                
            } else {
                inputText = textView.text
                //hide keyboard?
            }
        }
        
        switch textView {
        case self.viewController!.emailToTextView:
            print("inputEmail:", inputEmail as Any)
            if inputEmail.count > 0 {
                self.viewController!.emailsToArray.append(inputEmail)
            }
            self.viewController!.emailToSting = inputText
            break
        case self.viewController!.ccToTextView:
            print("inputCcEmail:", inputEmail as Any)
            if inputEmail.count > 0 {
                self.viewController!.ccToArray.append(inputEmail)
            }
            self.viewController!.ccToSting = inputText
            break
        case self.viewController!.bccToTextView:
            print("inputBccEmail:", inputEmail as Any)
            if inputEmail.count > 0 {
                self.viewController!.bccToArray.append(inputEmail)
            }
            self.viewController!.bccToSting = inputText
            break
        default:
            break
        }
        
        self.setCursorPositionToEnd(textView: textView)
        
        self.presenter!.enabledSendButton()
        
        self.viewController!.tableView.isHidden = true
        
        self.presenter?.setupEmailToSection(emailToText: self.viewController!.emailToSting, ccToText: self.viewController!.ccToSting, bccToText: self.viewController!.bccToSting)
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
    
    func spacePressed(input: String) {
        
        if input == " " {
            print("space pressed")
        }
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
                return selectedWord
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
