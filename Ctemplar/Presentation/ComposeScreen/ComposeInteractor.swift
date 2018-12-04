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

    //MARK: - API
    
    func sendMail(content: String, subject: String, recievers: Array<String>, folder: String, mailboxID: Int, send: Bool, encrypted: Bool, encryptionObject: [String : String]) {
        
        apiService?.createMessage(content: content, subject: subject, recieversList: recievers, folder: folder, mailboxID: mailboxID, send: send, encrypted: encrypted, encryptionObject: encryptionObject) {(result) in
            
            switch(result) {
                
            case .success(let value):
                print("createMessage value:", value)
                
                if send {
                    self.mailWasSent()
                } else {
                    self.sendingMessage = value as! EmailMessage
                }
                
            case .failure(let error):
                print("error:", error)
                AlertHelperKit().showAlert(self.viewController!, title: "Send Mail Error", message: error.localizedDescription, button: "closeButton".localized())
            }
        }
    }
    
    func updateSendingMessage(messsageID: String, encryptedMessage: String, encryptionObject: [String : String]) {
        
        apiService?.updateSendingMessage(messageID: messsageID, encryptedMessage: encryptedMessage, folder: MessagesFoldersName.sent.rawValue, encryptionObject: encryptionObject) {(result) in
            
            switch(result) {
                
            case .success(let value):
                print("updateSendingMessage value:", value)
                
                self.mailWasSent()
                
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
    
    //MARK: - prepared to send
    
    func prepareMessadgeToSend() {
        
        //self.getPublicKeysForEmails()
        
        self.publicKeysFor(userEmailsArray: self.viewController!.emailsToArray) { (keys) in
            print("publicKeys:", keys)
            
             if keys.count < 2 { //just logged user key or non
                self.sendEmailForNonCtemplarUser()
             } else {
                self.sendEncryptedEmailForCtemplarUser(publicKeys: keys)
             }
        }
    }
    
    func sendEncryptedEmailForCtemplarUser(publicKeys: Array<Key>) {
        
        let encryptedMessage = self.encryptMessage(publicKeys: publicKeys, message: self.viewController!.messageTextView.text)
        
        self.sendMail(content: encryptedMessage, subject: self.viewController!.subject, recievers: self.viewController!.emailsToArray, folder: MessagesFoldersName.sent.rawValue, mailboxID: (self.viewController?.mailboxID)!, send: true, encrypted: true, encryptionObject: [:])
    }
    
    func sendEmailForNonCtemplarUser() {
        
        var message : String = ""
        var encryptionObjectDictionary =  [String : String]()
        let folder : String = MessagesFoldersName.sent.rawValue
        
        if self.viewController?.encryptedMail == true {
            
            if let encryptionObject = self.sendingMessage.encryption {
            
                if let nonCtemplarPGPKey = pgpService?.generatePGPKey(userName: "support@hypertunnels3d.com", password: "test456") {
                
                    encryptionObjectDictionary = self.setPGPKeysForEncryptionObject(object: encryptionObject, pgpKey: nonCtemplarPGPKey)
                    
                    var pgpKeys = Array<Key>()
                    
                    if let userKeys = self.pgpService?.getStoredPGPKeys() {
                        if userKeys.count > 0 {
                            pgpKeys = userKeys
                        }
                    }
                    
                    pgpKeys.append(nonCtemplarPGPKey)
                    
                    message = self.encryptMessage(publicKeys: pgpKeys, message: self.viewController!.messageTextView.text)
                    
                    self.updateSendingMessage(messsageID: (self.sendingMessage.messsageID?.description)!, encryptedMessage: message, encryptionObject: encryptionObjectDictionary)
                }
            }
            
        } else {
            
            message = self.viewController!.messageTextView.text
        
            self.sendMail(content: message, subject: self.viewController!.subject, recievers: self.viewController!.emailsToArray, folder: folder, mailboxID: (self.viewController?.mailboxID)!, send: true, encrypted: false, encryptionObject: encryptionObjectDictionary)
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
        
        var message : String = ""
        
        if let userKeys = self.pgpService?.getStoredPGPKeys() {
            if userKeys.count > 0 {
                message = self.encryptMessage(publicKeys: userKeys, message: self.viewController!.messageTextView.text)
            }
        }
        
        let encryptionObject = EncryptionObject.init(password: password, passwordHint: passwordHint).toShortDictionary()
        
        self.sendMail(content: message, subject: self.viewController!.subject, recievers: self.viewController!.emailsToArray, folder: MessagesFoldersName.draft.rawValue, mailboxID: (self.viewController?.mailboxID)!, send: false, encrypted: (self.viewController?.encryptedMail)!, encryptionObject: encryptionObject)
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
            let inputEmail = self.getLastInputEmail(input: inputDroppedPrefixText)
            print("inputEmail:", inputEmail as Any)
 
            self.viewController!.emailsToArray.append(inputEmail)
            self.viewController!.emailToSting = textView.text + " "
            self.presenter?.setupEmailToSection(emailToText: self.viewController!.emailToSting, ccToText: self.viewController!.ccToSting, bccToText: self.viewController!.bccToSting)
            
            self.setCursorPositionToEnd(textView: textView)
            
            self.presenter!.enabledSendButton()
            
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
            let inputCcEmail = self.getLastInputEmail(input: inputDroppedPrefixText)
            print("inputCcEmail:", inputCcEmail as Any)
            
            self.viewController!.ccToArray.append(inputCcEmail)
            self.viewController!.ccToSting = textView.text + " "
            self.presenter?.setupEmailToSection(emailToText: self.viewController!.emailToSting, ccToText: self.viewController!.ccToSting, bccToText: self.viewController!.bccToSting)
            
            self.setCursorPositionToEnd(textView: textView)
            
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
            let inputBccEmail = self.getLastInputEmail(input: inputDroppedPrefixText)
            print("inputBccEmail:", inputBccEmail as Any)
            
            self.viewController!.bccToArray.append(inputBccEmail)
            self.viewController!.bccToSting = textView.text + " "
            self.presenter?.setupEmailToSection(emailToText: self.viewController!.emailToSting, ccToText: self.viewController!.ccToSting, bccToText: self.viewController!.bccToSting)
            
            self.setCursorPositionToEnd(textView: textView)
            
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
            }
        } else {
            if self.viewController!.tapSelectedBccEmail.count > 0 {
                return false //disable edit if Email selected, only delete by Backspace
            }
        }
        
        return true
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
