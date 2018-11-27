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

class ComposeInteractor {
    
    var viewController      : ComposeViewController?
    var presenter           : ComposePresenter?
    var apiService          : APIService?
    var pgpService          : PGPService?
    var formatterService    : FormatterService?

    //MARK: - API
    
    func sendMail() {
        
        let recievers : Array<String> = ["dmitry3@dev.ctemplar.com"] //temp
        
        apiService?.createMessage(content: "Non encrypted content for sended message", subject: "Send Test with Sent folder", recieversList: recievers, folder: MessagesFoldersName.sent.rawValue, mailboxID: 44, send: true) {(result) in
            
            switch(result) {
                
            case .success(let value):
                print("createMessage value:", value)
                
                
                
            case .failure(let error):
                print("error:", error)
                AlertHelperKit().showAlert(self.viewController!, title: "Send Mail Error", message: error.localizedDescription, button: "closeButton".localized())
            }
        }
    }
    
    func publicKeyFor(userEmail: String) {
        
        apiService?.publicKeyFor(userEmail: userEmail) {(result) in
            
            switch(result) {
                
            case .success(let value):
                //print("publicKey value:", value)
                
                let publicKey = value as! String
                print("publicKey:", publicKey)
                
                //pgpService.readPGPKeysFromString(key: publicKey)
                //pgpService.extractAndSavePGPKeyFromString(key: publicKey)
                //pgpService.getStoredPGPKeys()
                
            case .failure(let error):
                print("error:", error)
                AlertHelperKit().showAlert(self.viewController!, title: "Public Key Error", message: error.localizedDescription, button: "closeButton".localized())
            }
        }
    }
    
    //MARK: - textView
    
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
    
    func forbidDeletion(range: NSRange) -> Bool {
        
        if range.location == "emailToPrefix".localized().count - 1 && range.length == 1 {
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
