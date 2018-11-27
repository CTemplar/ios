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
    
    @IBOutlet var emailFrom           : UILabel!
    @IBOutlet var subjectTextField    : UITextField!
    
    @IBOutlet var messageTextView     : UITextView!
    
    @IBOutlet var emailToTextView     : UITextView!
    
    @IBOutlet var attachmentButton    : UIButton!
    @IBOutlet var encryptedButton     : UIButton!
    @IBOutlet var selfDestructedButton  : UIButton!
    @IBOutlet var delayedDeliveryButton : UIButton!
    @IBOutlet var deadManButton       : UIButton!
    
    @IBOutlet var toViewHeightConstraint    : NSLayoutConstraint!
    
    var presenter   : ComposePresenter?
    var interactor  : ComposeInteractor?
    var router      : ComposeRouter?
    var dataSource  : ComposeDataSource?
    
    var navBarTitle: String = ""
    var senderEmail: String = ""
    var subject    : String = ""
    
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
        
        subjectTextField.delegate = self
        
        //temp =========
        emailsToArray.append("test@mega.com")
        emailsToArray.append("dima@tatarinov.com")
        
        for email in emailsToArray {
            self.emailToSting = self.emailToSting + email + " "
        }
        //========
        
        
        self.presenter?.setupEmailFromSection(emailFromText: self.senderEmail)
        self.presenter?.setupEmailToSection(emailToText: self.emailToSting)
        self.presenter?.setupSubject(subjectText: self.subject)
        
        self.addGesureRecognizers()        
    }
    
    func addGesureRecognizers() {
        
        let freeSpaceViewGesture = UITapGestureRecognizer(target: self, action:  #selector(self.tappedViewAction(sender:)))
        self.view.addGestureRecognizer(freeSpaceViewGesture)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapOnEmailToTextView(_:)))
        tapGesture.delegate = self
        self.emailToTextView.addGestureRecognizer(tapGesture)
    }
    
    //MARK: - IBActions
    
    @IBAction func backButtonPressed(_ sender: AnyObject) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func sendButtonPressed(_ sender: AnyObject) {
        
        //sendMail() //temp
        //publicKeyFor(userEmail: "dmitry5@dev.ctemplar.com")
    }
    
    @IBAction func attachmentButtonPressed(_ sender: AnyObject) {
        
    }
    
    @IBAction func encryptedButtonPressed(_ sender: AnyObject) {
        
    }
    
    @IBAction func selfDestructedButtonPressed(_ sender: AnyObject) {
        
    }
    
    @IBAction func delayedDeliveryButtonPressed(_ sender: AnyObject) {
        
    }
    
    @IBAction func deadManButtonPressed(_ sender: AnyObject) {
        
    }
        
    //MARK: - textView delegate
    
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
            self.presenter?.setupEmailToSection(emailToText: textView.text)
            //print("textView text:", textView.text)
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        //print("range location:", range.location, "length:", range.length)
        
        //forbid to delete Prefix "
        if (self.interactor?.forbidDeletion(range: range))! {
            return false
        }
        
        if textView == self.emailToTextView {
            
            if (self.interactor?.getCursorPosition(textView: textView))! < "emailToPrefix".localized().count {
                self.interactor?.setCursorPositionToEnd(textView: textView)
                return false
            }
        }
        
        if (self.interactor?.returnPressed(input: text))! {
            //print("range location:", range.location, "length:", range.length)
            
            if textView == self.emailToTextView {
                let inputDroppedPrefixText = self.interactor?.dropPrefix(text: textView.text, prefix: "emailToPrefix".localized())
                let emailsDroppedPrefixText = self.interactor?.dropPrefix(text: self.emailToSting, prefix: "emailToPrefix".localized())
                let inputEmail = self.interactor?.getLastInputEmail(input: inputDroppedPrefixText!, prevText: emailsDroppedPrefixText!)
                //print("textView.text:", textView.text)
                //print("self.emailToSting:", self.emailToSting)
                print("inputEmail:", inputEmail as Any)
                self.emailsToArray.append(inputEmail!)
                self.emailToSting = textView.text + " "
                self.presenter?.setupEmailToSection(emailToText: self.emailToSting)
            }
            
            self.interactor?.setCursorPositionToEnd(textView: textView)
            
            return false
        }
        
        if (self.interactor?.backspacePressed(input: text, range: range))! {
            
            if self.tapSelectedEmail.count > 0 {
                if textView == self.emailToTextView {
                    self.emailsToArray.removeAll{ $0 == self.tapSelectedEmail }
                    print("self.emailsToArray.count:", self.emailsToArray.count)
                    
                    self.emailToSting = self.emailToSting.replacingOccurrences(of: self.tapSelectedEmail, with: "")
                    self.tapSelectedEmail = ""
                    
                    self.presenter?.setupEmailToSection(emailToText: self.emailToSting)
                    view.endEditing(true)
                }
            } else {
            
                if let editingWord = self.interactor?.getLastWord(textView: textView) {

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
        
        self.interactor?.spacePressed(input: text)
        
        return true
    }
    
    //MARK: - textField delegate
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        self.subject = textField.text!
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        self.subject = textField.text!
        textField.resignFirstResponder()
        
        return true;
    }
    
    //MARK: - other
    
    override public func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return false //disable cut/copy
    }
    
    @objc private final func tapOnEmailToTextView(_ tapGesture: UITapGestureRecognizer){
        
        let point = tapGesture.location(in: emailToTextView)
        
        if let selectedEmail = self.interactor?.getWordAtPosition(point, textView: emailToTextView) {
            print("tap selectedEmail:", selectedEmail)
            self.tapSelectedEmail = selectedEmail
            self.presenter?.setupEmailToSection(emailToText: self.emailToSting)
        } else {
            self.tapSelectedEmail = ""
            self.presenter?.setupEmailToSection(emailToText: self.emailToSting)
        }
    }
    
    @objc func tappedViewAction(sender : UITapGestureRecognizer) {
        
        self.tapSelectedEmail = ""
        self.presenter?.setupEmailToSection(emailToText: self.emailToSting)
        view.endEditing(true)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        return true
    }
}
