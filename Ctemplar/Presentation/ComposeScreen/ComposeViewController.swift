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

class ComposeViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet var fromView            : UIView!
    @IBOutlet var toView              : UIView!
    @IBOutlet var subjectView         : UIView!
    @IBOutlet var toolBarView         : UIView!
    @IBOutlet var bottomBarView       : UIView!
    
    @IBOutlet var messageTextView     : UITextView!
    
    @IBOutlet var emailToTextView     : UITextView!
    
    @IBOutlet var toViewHeightConstraint    : NSLayoutConstraint!
    
    var presenter   : ComposePresenter?
    var router      : ComposeRouter?
    var dataSource  : ComposeDataSource?
    
    var navBarTitle: String? = ""
    
    var emailsToArray = Array<String>()
    var emailToAttributtedSting : NSAttributedString!
    var emailToSting : String = "emailToPrefix".localized()
    
    var tapSelectedEmail : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let configurator = ComposeConfigurator()
        configurator.configure(viewController: self)
        
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        self.navigationItem.title = navBarTitle
        
        emailToTextView.delegate = self
        emailToTextView.autocorrectionType = .no
        
        //temp
        emailsToArray.append("test@mega.com")
        emailsToArray.append("dima@tatarinov.com")
        
        for email in emailsToArray {
            self.emailToSting = self.emailToSting + email + " "
        }
        
        setupEmailToSection(emailToText: self.emailToSting)
        
        let freeSpaceViewGesture = UITapGestureRecognizer(target: self, action:  #selector(self.tappedViewAction(sender:)))
        self.view.addGestureRecognizer(freeSpaceViewGesture)
    }
    
    @IBAction func backButtonPressed(_ sender: AnyObject) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func sendButtonPressed(_ sender: AnyObject) {
        
        //sendMail() //temp
        //publicKeyFor(userEmail: "dmitry5@dev.ctemplar.com")
    }
    
    func setupEmailToSection(emailToText: String) {
        
        //self.emailToTextView.backgroundColor = UIColor.yellow//debug
        
        self.setupEmailToViewText(emailToText: emailToText)
        
        let emailToViewHeight = self.setupEmailToViewSize()
        
        toViewHeightConstraint.constant = emailToViewHeight + k_emailToTextViewTopOffset + k_emailToTextViewTopOffset
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapOnEmailToTextView(_:)))
        tapGesture.delegate = self
        emailToTextView.addGestureRecognizer(tapGesture)
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
        
        //let attachment = NSTextAttachment()
    
        
        if tapSelectedEmail.count > 0 {
            _ = attributedString.setBackgroundColor(textToFind: tapSelectedEmail, color: k_foundTextBackgroundColor)
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
        
        print("textViewDidBeginEditing")
    
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        
        //self.setCursorPositionToEnd(textView: textView)
        print("textViewShouldBeginEditing")
        /*
        if textView == self.emailToTextView {
            if self.getCursorPosition(textView: textView) < "emailToPrefix".localized().count {
                self.setCursorPositionToEnd(textView: textView)
            }
            
            if let selectedEmail = self.getCurrentEditingWord(textView: textView) {
                print("selectedEmail", selectedEmail)
                self.tapSelectedEmail = selectedEmail
                self.setupEmailToViewText(emailToText: self.emailToSting)
            }
        }*/
        
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
                //self.setupEmailToViewText(emailToText: self.emailToSting)
                self.setupEmailToSection(emailToText: self.emailToSting)
            }
            
            self.setCursorPositionToEnd(textView: textView)
            
            return false
        }
        
        if self.backspacePressed(input: text, range: range) {
            
            if self.tapSelectedEmail.count > 0 {
                if textView == self.emailToTextView {
                    self.emailsToArray.removeAll{ $0 == self.tapSelectedEmail }
                    print("self.emailsToArray.count:", self.emailsToArray.count)
                    
                    self.emailToSting = self.emailToSting.replacingOccurrences(of: self.tapSelectedEmail, with: "")
                    self.tapSelectedEmail = ""
                    
                    self.setupEmailToSection(emailToText: self.emailToSting)
                    view.endEditing(true)
                }
            } else {
            
                if let editingWord = self.getLastWord(textView: textView) {

                    if textView == self.emailToTextView {
                        print("editingWord:", editingWord)
                        self.emailsToArray.removeAll{ $0 == editingWord }
                        print("self.emailsToArray.count:", self.emailsToArray.count)
                    }
                }
            }
        } else {
            if self.tapSelectedEmail.count > 0 {
                return false //disable edit if Email selected, only delete by Backspace
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
    
    @objc private final func tapOnEmailToTextView(_ tapGesture: UITapGestureRecognizer){
        
        let point = tapGesture.location(in: emailToTextView)
        
        if let selectedEmail = getWordAtPosition(point, textView: emailToTextView) {
            print("tap selectedEmail:", selectedEmail)
            self.tapSelectedEmail = selectedEmail
            //self.setupEmailToViewText(emailToText: self.emailToSting)
            self.setupEmailToSection(emailToText: self.emailToSting)
        } else {
            self.tapSelectedEmail = ""
            self.setupEmailToSection(emailToText: self.emailToSting)
        }
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
    
    @objc func tappedViewAction(sender : UITapGestureRecognizer) {
        
        self.tapSelectedEmail = ""
        //self.setupEmailToViewText(emailToText: self.emailToSting)
        self.setupEmailToSection(emailToText: self.emailToSting)
        view.endEditing(true)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        return true
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
