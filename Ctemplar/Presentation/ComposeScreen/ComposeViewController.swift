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
import ObjectivePGP

class ComposeViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet var tableView           : UITableView!
    
    @IBOutlet var fromView            : UIView!
    @IBOutlet var emailToSectionView  : UIView!
    @IBOutlet var ccToSubSectionView  : UIView!
    @IBOutlet var bccToSubSectionView : UIView!
    @IBOutlet var subjectView         : UIView!
    @IBOutlet var toolBarView         : UIView!
    @IBOutlet var bottomBarView       : UIView!
    
    @IBOutlet var emailFrom           : UILabel!
    @IBOutlet var subjectTextField    : UITextField!
    
    @IBOutlet var messageTextView     : UITextView!
    
    @IBOutlet var emailToTextView     : UITextView!
    @IBOutlet var ccToTextView        : UITextView!
    @IBOutlet var bccToTextView       : UITextView!
    
    @IBOutlet var mailboxesButton     : UIButton!
    
    @IBOutlet var expandButton        : UIButton!
    
    @IBOutlet var attachmentButton    : UIButton!
    @IBOutlet var encryptedButton     : UIButton!
    @IBOutlet var selfDestructedButton  : UIButton!
    @IBOutlet var delayedDeliveryButton : UIButton!
    @IBOutlet var deadManButton       : UIButton!
    
    @IBOutlet var toViewSectionHeightConstraint          : NSLayoutConstraint!
    @IBOutlet var toViewSubsectionHeightConstraint       : NSLayoutConstraint!
    @IBOutlet var ccViewSubsectionHeightConstraint       : NSLayoutConstraint!
    @IBOutlet var bccViewSubsectionHeightConstraint      : NSLayoutConstraint!
    
    var expandedSectionHeight: CGFloat = 0.0
    
    var presenter   : ComposePresenter?
    var interactor  : ComposeInteractor?
    var router      : ComposeRouter?
    var dataSource  : ComposeDataSource?
    
    var navBarTitle: String = ""
    var subject    : String = ""
    
    var mailboxesList    : Array<Mailbox> = []
    var mailboxID : Int = 0
    
    var emailsToArray = Array<String>()
    //var emailToAttributtedSting : NSAttributedString!
    var emailToSting : String = "emailToPrefix".localized()
    
    var ccToArray = Array<String>()
    var ccToSting : String = "ccToPrefix".localized()
    
    var bccToArray = Array<String>()
    var bccToSting : String = "bccToPrefix".localized()
    
    var tapSelectedEmail    : String = ""
    var tapSelectedCcEmail  : String = ""
    var tapSelectedBccEmail : String = ""
    
    var usersPublicKeys = Array<Key>()
    
    var encryptedMail : Bool = false
    
    var messageAttributedText : NSAttributedString = NSAttributedString(string: "")
    
    var messagesArray                     : Array<EmailMessage> = []
    //var dercyptedMessagesArray            : Array<String> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let configurator = ComposeConfigurator()
        configurator.configure(viewController: self)
        
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        self.navigationItem.title = navBarTitle
        
        emailToTextView.delegate = self
        emailToTextView.autocorrectionType = .no
        
        ccToTextView.delegate = self
        ccToTextView.autocorrectionType = .no
        
        bccToTextView.delegate = self
        bccToTextView.autocorrectionType = .no        
        
        subjectTextField.delegate = self
        
        messageTextView.delegate = self
        
        ccToSubSectionView.isHidden = true
        bccToSubSectionView.isHidden = true
        
        
        //temp =========
        //emailsToArray.append("test@mega.com")
        //emailsToArray.append("dima@tatarinov.com")
        /*
        emailsToArray.append("dmitry5@dev.ctemplar.com")
        emailsToArray.append("dmitry8@dev.ctemplar.com")
        
        for email in emailsToArray {
            self.emailToSting = self.emailToSting + email + " "
        }
        
        subject = "Test encrypted email for contact users"
        */
        /*
        ccToArray.append("supertest@mega.com")
        ccToArray.append("dimon@tatarinov.com")
        ccToArray.append("hulygun@mail.net")
        
        for email in ccToArray {
            self.ccToSting = self.ccToSting + email + " "
        }
        
        bccToArray.append("testX@mega.com")
        bccToArray.append("dmitry@tatarinov.com")
        bccToArray.append("hulygunHyper@mail.net")
        
        for email in bccToArray {
            self.bccToSting = self.bccToSting + email + " "
        }
        //========
        */
        
        //self.presenter?.setupMessageSection(emailsArray: self.messagesArray)
        
        self.presenter?.setMailboxes(mailboxes: mailboxesList)
        self.presenter?.setupEmailToSection(emailToText: self.emailToSting, ccToText: self.ccToSting, bccToText: self.bccToSting)
        self.presenter?.setupSubject(subjectText: self.subject)
        
        self.dataSource?.initWith(parent: self, tableView: tableView)
        self.presenter?.setMailboxDataSource(mailboxes: mailboxesList)        
        
        self.addGesureRecognizers()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.presenter?.setupMessageSection(emailsArray: self.messagesArray)
    }
    
    func addGesureRecognizers() {
        
        let freeSpaceViewGesture = UITapGestureRecognizer(target: self, action:  #selector(self.tappedViewAction(sender:)))
        freeSpaceViewGesture.cancelsTouchesInView = false //for tap to TableView and TextView simultaniously
        self.view.addGestureRecognizer(freeSpaceViewGesture)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapOnEmailToTextView(_:)))
        tapGesture.delegate = self
        self.emailToTextView.addGestureRecognizer(tapGesture)
        
        let tapCcToGesture = UITapGestureRecognizer(target: self, action: #selector(tapOnCcToTextView(_:)))
        tapCcToGesture.delegate = self
        self.ccToTextView.addGestureRecognizer(tapCcToGesture)
        
        let tapBccToGesture = UITapGestureRecognizer(target: self, action: #selector(tapOnBccToTextView(_:)))
        tapBccToGesture.delegate = self
        self.bccToTextView.addGestureRecognizer(tapBccToGesture)
    }
    
    //MARK: - IBActions
    
    @IBAction func backButtonPressed(_ sender: AnyObject) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func mailboxesButtonPressed(_ sender: AnyObject) {
        
        self.presenter?.mailboxesButtonPressed()
    }
    
    @IBAction func expandButtonPressed(_ sender: AnyObject) {
        
        self.presenter?.expandButtonPressed()
    }    
    
    @IBAction func sendButtonPressed(_ sender: AnyObject) {
                
        self.interactor!.prepareMessadgeToSend()
    }
    
    @IBAction func attachmentButtonPressed(_ sender: AnyObject) {
        
    }
    
    @IBAction func encryptedButtonPressed(_ sender: AnyObject) {
        
        self.presenter!.encryptedButtonPressed()
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
        
        if textView != self.messageTextView {
            if self.messageTextView.text.isEmpty {
                self.messageTextView.text = "composeEmail".localized()
                self.messageTextView.textColor = UIColor.lightGray
            }
        } else {
            if self.messageTextView.text == "composeEmail".localized() {
                self.messageTextView.text = ""
                self.messageTextView.textColor = UIColor.darkText //temp
            }
        }
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
  
        print("textViewShouldBeginEditing")
        
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        print("textViewDidEndEditing")
        
        if textView == self.messageTextView {
            if self.messageTextView.text.isEmpty {
                self.messageTextView.text = "composeEmail".localized()
                self.messageTextView.textColor = UIColor.lightGray
            }
        }
        
        self.tapSelectedEmail = ""
        self.tapSelectedCcEmail = ""
        self.tapSelectedBccEmail = ""
        
        self.presenter?.setupEmailToSection(emailToText: self.emailToSting, ccToText: self.ccToSting, bccToText: self.bccToSting)
        self.presenter!.enabledSendButton()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
        //self.setCursorPositionToEnd(textView: textView)
        
        print("textViewDidChange text:", textView.text)
        
        switch textView {
        case self.emailToTextView:
            self.presenter?.setupEmailToSection(emailToText: textView.text, ccToText: self.ccToSting, bccToText: self.bccToSting)
        case self.ccToTextView:
            self.presenter?.setupEmailToSection(emailToText: self.emailToSting, ccToText: textView.text, bccToText: self.bccToSting)
        case self.bccToTextView:
            self.presenter?.setupEmailToSection(emailToText: self.emailToSting, ccToText: self.ccToSting, bccToText: textView.text)
        case self.messageTextView:
             //self.messageAttributedText = self.messageTextView.attributedText
            break
        default:
            break
        }
        
        self.presenter!.enabledSendButton()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        switch textView {
        case self.emailToTextView:
            return (self.interactor?.holdEmailToTextViewInput(textView: self.emailToTextView, shouldChangeTextIn: range, replacementText: text))!
        case self.ccToTextView:
            return (self.interactor?.holdCcToTextViewInput(textView: self.ccToTextView, shouldChangeTextIn: range, replacementText: text))!
        case self.bccToTextView:
            return (self.interactor?.holdBccToTextViewInput(textView: self.bccToTextView, shouldChangeTextIn: range, replacementText: text))!            
        default:
            break
        }
        
        return true
    }
    
    //MARK: - textField delegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        self.subject = textField.text!
        self.presenter!.enabledSendButton()
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        self.subject = textField.text!
        self.presenter!.enabledSendButton()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        self.subject = textField.text!
        self.presenter!.enabledSendButton()
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
            print("tap To Email:", selectedEmail)
            self.tapSelectedEmail = selectedEmail
        } else {
            self.tapSelectedEmail = ""
        }
        
        self.presenter?.setupEmailToSection(emailToText: self.emailToSting, ccToText: self.ccToSting, bccToText: self.bccToSting)
    }
    
    @objc private final func tapOnCcToTextView(_ tapGesture: UITapGestureRecognizer){
        
        let point = tapGesture.location(in: ccToTextView)
        
        if let selectedEmail = self.interactor?.getWordAtPosition(point, textView: ccToTextView) {
            print("tap CC Email:", selectedEmail)
            self.tapSelectedCcEmail = selectedEmail
        } else {
            self.tapSelectedCcEmail = ""
        }
        
        self.presenter?.setupEmailToSection(emailToText: self.emailToSting, ccToText: self.ccToSting, bccToText: self.bccToSting)
    }
    
    @objc private final func tapOnBccToTextView(_ tapGesture: UITapGestureRecognizer){
        
        let point = tapGesture.location(in: bccToTextView)
        
        if let selectedEmail = self.interactor?.getWordAtPosition(point, textView: bccToTextView) {
            print("tap BCC Email:", selectedEmail)
            self.tapSelectedBccEmail = selectedEmail            
        } else {
            self.tapSelectedBccEmail = ""
        }
        
        self.presenter?.setupEmailToSection(emailToText: self.emailToSting, ccToText: self.ccToSting, bccToText: self.bccToSting)
    }
    
    @objc func tappedViewAction(sender : UITapGestureRecognizer) {
        
        self.tapSelectedEmail = ""
        self.tapSelectedCcEmail = ""
        self.tapSelectedBccEmail = ""
        self.presenter?.setupEmailToSection(emailToText: self.emailToSting, ccToText: self.ccToSting, bccToText: self.bccToSting)
        view.endEditing(true)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        return true
    }
}

extension ComposeViewController: SetPasswordDelegate {

    func applyAction(password: String, passwordHint: String) {
        
        self.interactor?.sendPasswordForCreatingMessage(password: password, passwordHint: passwordHint)
    }
    
    func cancelAction() {
        
        self.presenter!.encryptedButtonPressed()
    }
}
