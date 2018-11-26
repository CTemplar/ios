//
//  ComposeViewController.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 12.10.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import UIKit
import Foundation
import PKHUD
import AlertHelperKit

class ComposeViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {
    
    @IBOutlet var fromView            : UIView!
    @IBOutlet var toView              : UIView!
    @IBOutlet var subjectView         : UIView!
    @IBOutlet var toolBarView         : UIView!
    @IBOutlet var bottomBarView       : UIView!
    
    @IBOutlet var messageTextView     : UITextView!
    
    @IBOutlet var emailToTextView     : UITextView!
    
    @IBOutlet var toViewHeightConstraint    : NSLayoutConstraint!
    
    var navBarTitle: String? = ""
    
    var emailsToArray = Array<String>()
    var emailToAttributtedSting : NSAttributedString!
    var emailToSting : String = "emailToPrefix".localized()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        self.navigationItem.title = navBarTitle
        
        emailToTextView.delegate = self
        emailToTextView.autocorrectionType = .no
        
        setupEmailToSection(emailToText: self.emailToSting)//"To: djhbrhibjhjsjpsjnbsnb toEmailTextField toEmailTextbd djhbrhibjhjsjpsjnbsnb djhbrhibjhjsjpsjnbsn") //djhbrhibjhjsjpsjnbsnb
    }
    
    @IBAction func backButtonPressed(_ sender: AnyObject) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func sendButtonPressed(_ sender: AnyObject) {
        
        //sendMail() //temp
        //publicKeyFor(userEmail: "dmitry5@dev.ctemplar.com")
    }
    
    func setupEmailToSection(emailToText: String) {
        
        self.emailToTextView.backgroundColor = UIColor.yellow//debug
        
        self.setupEmailToViewText(emailToText: emailToText)
        
        let emailToViewHeight = self.setupEmailToViewSize()
        
        toViewHeightConstraint.constant = emailToViewHeight + k_emailToTextViewTopOffset + k_emailToTextViewTopOffset
    }
    
    func setupEmailToViewText(emailToText: String) {
        
        let style = NSMutableParagraphStyle()
        style.lineSpacing = CGFloat(k_lineSpaceSizeForFromToText)
        
        let font : UIFont = UIFont(name: k_latoRegularFontName, size: 14.0)!
        
        let attributedString = NSMutableAttributedString(string: emailToText, attributes: [
            .font: font,
            .foregroundColor: k_emailToColor,//k_actionMessageColor,
            .kern: 0.0,
            .paragraphStyle: style
            ])
        
        for email in self.emailsToArray {
            _ = attributedString.setBackgroundColor(textToFind: email, color: k_mainInboxColor)
            _ = attributedString.setForgroundColor(textToFind: email, color: k_emailToInputColor)
        }
        
        self.emailToTextView.attributedText = attributedString
    }
    
    func setupEmailToViewSize() -> CGFloat {
        
        let fixedWidth = self.view.frame.width - k_emailToTextViewLeftOffset - k_expandDetailsButtonWidth
              
        self.emailToTextView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        let newEmailToTextViewSize = self.emailToTextView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        var newEmailToTextViewFrame = self.emailToTextView.frame
        newEmailToTextViewFrame.size = CGSize(width: max(newEmailToTextViewSize.width, fixedWidth), height: newEmailToTextViewSize.height)
        self.emailToTextView.frame = newEmailToTextViewFrame;
        
        return self.emailToTextView.frame.height
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if textView == self.emailToTextView {
            if self.getCursorPosition(textView: textView) < "emailToPrefix".localized().count {
                self.setCursorPositionToEnd(textView: textView)
            }
        }
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        
        //self.setCursorPositionToEnd(textView: textView)
        
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
        //self.setCursorPositionToEnd(textView: textView)
        
        if textView == self.emailToTextView {
            self.setupEmailToSection(emailToText: textView.text)
            //print("textView text:", textView.text)
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        //print("range location:", range.location, "length:", range.length)
        
        //forbid to delete Prefix "
        if self.forbidDeletion(range: range) {
            return false
        }
        
        if textView == self.emailToTextView {
            
            if self.getCursorPosition(textView: textView) < "emailToPrefix".localized().count {
                self.setCursorPositionToEnd(textView: textView)
                return false
            }
        }
        
        if self.returnPressed(input: text) {
            //print("range location:", range.location, "length:", range.length)
            
            if textView == self.emailToTextView {
                let inputDroppedPrefixText = self.dropPrefix(text: textView.text, prefix: "emailToPrefix".localized())
                let emailsDroppedPrefixText = self.dropPrefix(text: self.emailToSting, prefix: "emailToPrefix".localized())
                let inputEmail = self.getLastInputEmail(input: inputDroppedPrefixText, prevText: emailsDroppedPrefixText)
                //print("textView.text:", textView.text)
                //print("self.emailToSting:", self.emailToSting)
                print("inputEmail:", inputEmail)
                self.emailsToArray.append(inputEmail)
                self.emailToSting = textView.text + " "
                self.setupEmailToViewText(emailToText: self.emailToSting)
            }
            
            self.setCursorPositionToEnd(textView: textView)
            
            return false
        }
        
        if self.backspacePressed(input: text, range: range) {
            
            if let editingWord = self.getCurrentEditingWord(textView: textView) {

                if textView == self.emailToTextView {
                    print("editingWord:", editingWord)
                    self.emailsToArray.removeAll{ $0 == editingWord }
                    print("self.emailsToArray.count:", self.emailsToArray.count)
                }
            }
        }
        
        self.spacePressed(input: text)
        
        return true
    }
    
    override public func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return false //disable cut/copy
    }
    
    func getCursorPosition(textView: UITextView) -> Int {
        
        if let selectedRange = textView.selectedTextRange {
            
            let cursorPosition = textView.offset(from: textView.beginningOfDocument, to: selectedRange.start)
            print("cusor Pos:" + "\(cursorPosition)")
            return cursorPosition
        }
        
        return 0
    }
    
    func setCursorPositionToEnd(textView: UITextView) {
        
        //print("set cursor:", textView.text.count)
        
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
    
    func deleteWipedEmail() {
        
    }
    
    func checkEnteredEmailsValidation() {
        
    }
    
    func getWordAtPosition(_ point: CGPoint, textView: UITextView) -> String? {
        
        if let textPosition = textView.closestPosition(to: point) {
            if let range = textView.tokenizer.rangeEnclosingPosition(textPosition, with: .word, inDirection: UITextDirection(rawValue: 1)) {
                
                return textView.text(in: range)
            }
        }
        
        return nil
    }
    
    func getCurrentEditingWord(textView: UITextView) -> String? {
        
        let selectedRange: UITextRange? = textView.selectedTextRange
        
        var cursorOffset: Int? = nil
        
        if let aStart = selectedRange?.start {
            cursorOffset = textView.offset(from: textView.beginningOfDocument, to: aStart)
        }
        
        let text = textView.text
        let substring = (text as NSString?)?.substring(to: cursorOffset!)
        
        let editedWord = substring?.components(separatedBy: " ").last
        
        return editedWord
    }
    
    //temp
    
    func sendMail() {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let apiService = appDelegate.applicationManager.apiService
        
        let recievers : Array<String> = ["dmitry3@dev.ctemplar.com"]
        
        apiService.createMessage(content: "Non encrypted content for sended message", subject: "Send Test with Sent folder", recieversList: recievers, folder: MessagesFoldersName.sent.rawValue, mailboxID: 44, send: true) {(result) in
            
            switch(result) {
                
            case .success(let value):
                print("createMessage value:", value)
                
                
                
            case .failure(let error):
                print("error:", error)
                //AlertHelperKit().showAlert(self.viewController!, title: "Mailboxes Error", message: error.localizedDescription, button: "closeButton".localized())
            }
        }
    }
    
    func publicKeyFor(userEmail: String) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let apiService = appDelegate.applicationManager.apiService
        
        let pgpService = appDelegate.applicationManager.pgpService
        
        apiService.publicKeyFor(userEmail: userEmail) {(result) in
            
            switch(result) {
                
            case .success(let value):
                //print("publicKey value:", value)
                
                let publicKey = value as! String
                print("publicKey:", publicKey)
                
               //pgpService.readPGPKeysFromString(key: publicKey)
                pgpService.extractAndSavePGPKeyFromString(key: publicKey)
                pgpService.getStoredPGPKeys()
                
            case .failure(let error):
                print("error:", error)
                AlertHelperKit().showAlert(self, title: "Public Key Error", message: error.localizedDescription, button: "closeButton".localized())
            }
        }
    }
}
