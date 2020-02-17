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

class ComposeViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, UIGestureRecognizerDelegate, UIDocumentPickerDelegate {
    
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
    
    @IBOutlet weak var messageTextEditor    :    RichEditorView!
    @IBOutlet var scrollView          : UIScrollView!
    
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
    
    @IBOutlet var tableViewTopOffsetConstraint           : NSLayoutConstraint!
    @IBOutlet var tableViewBottomOffsetConstraint        : NSLayoutConstraint!
    
    @IBOutlet var messageTextEditorHeightConstraint: NSLayoutConstraint!
    @IBOutlet var messageTextEditorBottomOffsetConstraint: NSLayoutConstraint!
    @IBOutlet var scrollViewBottomOffsetConstraint       : NSLayoutConstraint!
    
    
    var expandedSectionHeight: CGFloat = 0.0
    var keyboardOffset = 0.0
    
    var presenter   : ComposePresenter?
    var interactor  : ComposeInteractor?
    var router      : ComposeRouter?
    var dataSource  : ComposeDataSource?
    
    var draftActionsView : MoreActionsView?
    
    var answerMode : AnswerMessageMode!
    //var navBarTitle: String = ""
    var subject    : String = ""
    var sender     : String = ""
    
    //var mailboxesList    : Array<Mailbox> = []
    var mailboxID : Int = 0
    var user = UserMyself()
    
    var contactsList    : Array<Contact> = []
    
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
    
    var mailAttachmentsList = Array<[String : String]>()
    var viewAttachmentsList = Array<AttachmentView>()
    
    var encryptedMail : Bool = false
    
    var messageAttributedText : NSAttributedString = NSAttributedString(string: "")
    
    var messagesArray                     : Array<EmailMessage> = []
    var dercyptedMessagesArray            : Array<String> = []
    
    var message : EmailMessage?
    
    var selfDestructionDate : Date!
    var deadManDate : Date!
    var delayedDeliveryDate : Date!
    
    var runOnce : Bool = true
        
    var upgradeToPrimeView : UpgradeToPrimeView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.addGesureRecognizers()
        
        let configurator = ComposeConfigurator()
        configurator.configure(viewController: self)
        
        self.navigationItem.rightBarButtonItem?.isEnabled = false        
        self.presenter?.setupNavigationBarTitle(mode: self.answerMode)
        
        self.presenter!.initDraftActionsView()
        
        emailToTextView.delegate = self
        emailToTextView.autocorrectionType = .no
        
        ccToTextView.delegate = self
        ccToTextView.autocorrectionType = .no
        
        bccToTextView.delegate = self
        bccToTextView.autocorrectionType = .no        
        
        subjectTextField.delegate = self
        
        messageTextEditor.delegate = self
        
        ccToSubSectionView.isHidden = true
        bccToSubSectionView.isHidden = true
        
        
        //temp =========
        //emailsToArray.append("test@mega.com")
        //emailsToArray.append("dima@tatarinov.com")
        
        //emailsToArray.append("dmitry5@dev.ctemplar.com")
        //emailsToArray.append("dmitry8@dev.ctemplar.com")
        //emailsToArray.append("huly-gun@white-zebra.net")
        
        if answerMode != AnswerMessageMode.forward {
            for email in emailsToArray {
                self.emailToSting = self.emailToSting + email + " "
            }
        }
        
        //subject = "Test encrypted email for contact users"
 
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
          
        self.presenter?.setMailboxes(mailboxes: self.user.mailboxesList!)
        self.presenter?.setupEmailToSection(emailToText: self.emailToSting, ccToText: self.ccToSting, bccToText: self.bccToSting)
        
        self.presenter?.setMailboxDataSource(mailboxes: self.user.mailboxesList!)
        
        self.dataSource?.initWith(parent: self, tableView: tableView)
        self.presenter?.setupTableView(topOffset: k_composeTableViewTopOffset)
            
        if self.message != nil {
            
            if message?.folder == MessagesFoldersName.draft.rawValue { //if message is already in Draft folder we do not need to create new Draft instance
                self.interactor?.sendingMessage = message!
                
                self.answerMode = AnswerMessageMode.newMessage
                
                self.presenter?.setupAttachments(message: self.message!)               
                self.presenter?.fillAllEmailsFields(message: self.message!)
                self.presenter?.setupMessageSection(message: self.message!)
                self.presenter?.setupEncryptedButton()
                self.presenter?.setSchedulerTimersForMessage(message: self.message!)
                
            } else {
                self.presenter?.fillAllEmailsFields(message: self.message!)
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(50), execute: {
                    self.interactor?.createDraftWithParent(message: self.message!)
                })
            }
            
            self.interactor?.setupSubject(subject: self.subject, message: self.message!, answerMode: self.answerMode)
            //self.presenter?.setupSubject(subjectText: subject, answerMode: answerMode)

        } else {
            self.interactor?.createDraft(showHud: false)
            self.presenter?.setupSubject(subjectText: subject, answerMode: answerMode)
        }
        
        let isContactsEncrypted = self.user.settings.isContactsEncrypted ?? false
        if !isContactsEncrypted {
            self.interactor?.userContactsList(silent: true)
        }
            
        self.presenter?.setupSchedulersButtons()
        
        self.presenter?.initAddFolderLimitView()
        
        self.addNotificationObserver()
        
        //print("isAttachmentsEncrypted:", user.settings.isAttachmentsEncrypted)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.presenter?.setupMessageEditorView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //self.presenter?.setupMessageSection(emailsArray: self.messagesArray)
        if self.runOnce == true { 
        //    self.presenter?.setupMessageSectionSize()
            self.runOnce = false
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
     
        NotificationCenter.default.removeObserver(self)
        
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
        
        //self.navigationController?.popViewController(animated: true)
        self.presenter?.backButtonPressed()
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
 
        self.presenter!.showAttachActionsView()
    }
    
    @IBAction func encryptedButtonPressed(_ sender: AnyObject) {
        
        self.presenter!.encryptedButtonPressed()
    }
    
    @IBAction func selfDestructedButtonPressed(_ sender: AnyObject) {
        
        self.presenter!.checkIsPrimeAccount(mode: SchedulerMode.selfDestructTimer)
    }
    
    @IBAction func delayedDeliveryButtonPressed(_ sender: AnyObject) {
        
        self.presenter!.checkIsPrimeAccount(mode: SchedulerMode.delayedDelivery)
    }
    
    @IBAction func deadManButtonPressed(_ sender: AnyObject) {
        
        self.presenter!.checkIsPrimeAccount(mode: SchedulerMode.deadManTimer)
    }
        
    //MARK: - textView delegate
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        print("textViewDidBeginEditing")
        
//        if textView != self.messageTextView {
            
            //temp
            let isContactsEncrypted = self.user.settings.isContactsEncrypted ?? false
            if !isContactsEncrypted {
            
                self.tableView.isHidden = false
                self.presenter?.setupTableView(topOffset: k_composeTableViewTopOffset + self.emailToSectionView.frame.height/*self.toViewSectionHeightConstraint.constant*/ - 5.0)
                self.dataSource?.currentTextView = textView
                self.dataSource?.reloadData(setMailboxData: false)
                self.interactor?.setFilteredList(searchText: "")
            }
            //
            
//            if self.messageTextView.text.isEmpty {
//                self.presenter?.setPlaceholderToMessageTextView(show: true)
//            }
//        } else {
//            self.presenter?.setPlaceholderToMessageTextView(show: false)
//        }
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
  
        print("textViewShouldBeginEditing")
        
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        print("textViewDidEndEditing")
        
        self.tapSelectedEmail = ""
        self.tapSelectedCcEmail = ""
        self.tapSelectedBccEmail = ""
        
        self.tableView.isHidden = true
        //self.interactor?.setFilteredList(searchText: "")
        
        //self.presenter?.setupEmailToSection(emailToText: self.emailToSting, ccToText: self.ccToSting, bccToText: self.bccToSting)
        
        var inputText : String = ""
        
        switch textView {
        case self.emailToTextView:
            let inputDroppedPrefixText = self.interactor?.dropPrefix(text: textView.text, prefix: "emailToPrefix".localized())
            //inputText =  (self.interactor?.getLastInputEmail(input: inputDroppedPrefixText!))!
            inputText = (self.interactor?.getLastInputText(input: inputDroppedPrefixText!, emailsArray: self.emailsToArray))!
            self.interactor?.setEmail(textView: self.emailToTextView, inputEmail: inputText, clearInputtedChars: false)
        case self.ccToTextView:
            let inputDroppedPrefixText = self.interactor?.dropPrefix(text: textView.text, prefix: "ccToPrefix".localized())
            //inputText =  (self.interactor?.getLastInputEmail(input: inputDroppedPrefixText!))!
            inputText = (self.interactor?.getLastInputText(input: inputDroppedPrefixText!, emailsArray: self.ccToArray))!
            self.interactor?.setEmail(textView: self.ccToTextView, inputEmail: inputText, clearInputtedChars: false)
        case self.bccToTextView:
            let inputDroppedPrefixText = self.interactor?.dropPrefix(text: textView.text, prefix: "bccToPrefix".localized())
            //inputText =  (self.interactor?.getLastInputEmail(input: inputDroppedPrefixText!))!
            inputText = (self.interactor?.getLastInputText(input: inputDroppedPrefixText!, emailsArray: self.bccToArray))!
            self.interactor?.setEmail(textView: self.bccToTextView, inputEmail: inputText, clearInputtedChars: false)
//        case self.messageTextView:
//            if self.messageTextView.text.isEmpty {
//                self.presenter?.setPlaceholderToMessageTextView(show: true)
//            }
//            break
        default:
            break
        }
        
        self.presenter!.enabledSendButton()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
        //self.setCursorPositionToEnd(textView: textView)
        
        var inputText : String = ""
        
        print("textViewDidChange text:", textView.text)
        
        switch textView {
        case self.emailToTextView:
            let inputDroppedPrefixText = self.interactor?.dropPrefix(text: textView.text, prefix: "emailToPrefix".localized())
            inputText =  (self.interactor?.getLastInputEmail(input: inputDroppedPrefixText!))!
            self.presenter?.setupEmailToSection(emailToText: textView.text, ccToText: self.ccToSting, bccToText: self.bccToSting)
        case self.ccToTextView:
            let inputDroppedPrefixText = self.interactor?.dropPrefix(text: textView.text, prefix: "ccToPrefix".localized())
            inputText =  (self.interactor?.getLastInputEmail(input: inputDroppedPrefixText!))!
            self.presenter?.setupEmailToSection(emailToText: self.emailToSting, ccToText: textView.text, bccToText: self.bccToSting)
        case self.bccToTextView:
            let inputDroppedPrefixText = self.interactor?.dropPrefix(text: textView.text, prefix: "bccToPrefix".localized())
            inputText =  (self.interactor?.getLastInputEmail(input: inputDroppedPrefixText!))!
            self.presenter?.setupEmailToSection(emailToText: self.emailToSting, ccToText: self.ccToSting, bccToText: textView.text)
//        case self.messageTextView:
//             //self.messageAttributedText = self.messageTextView.attributedText
//            self.presenter!.setupMessageSectionSize()
//            break
        default:
            break
        }
        
//        if textView != self.messageTextView {
            self.interactor?.setFilteredList(searchText: inputText)
//        }
        
        self.presenter?.setupTableView(topOffset: k_composeTableViewTopOffset + self.emailToSectionView.frame.height/*self.toViewSectionHeightConstraint.constant*/ - 5.0)
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
//        case self.messageTextView:
//            //self.presenter!.setupMessageSectionSize()
//            break
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
        
        emailToTextView.becomeFirstResponder()
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
        
        ccToTextView.becomeFirstResponder()
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
        
        bccToTextView.becomeFirstResponder()
    }
    
    @objc func tappedViewAction(sender : UITapGestureRecognizer) {
        
        self.tapSelectedEmail = ""
        self.tapSelectedCcEmail = ""
        self.tapSelectedBccEmail = ""
        
        if !self.tableView.isHidden {
            
            if self.dataSource?.contactsArray.count == 0 { //tap to TableView with empty cells
                view.endEditing(true)
            }
            
            let location = sender.location(in: self.tableView)
            let locationYCoordinate = location.y
            
            if locationYCoordinate < 0 { //tapped under TableView
                view.endEditing(true)
            }
            
        } else {
            view.endEditing(true)
        }
        
        //self.presenter?.setupEmailToSection(emailToText: self.emailToSting, ccToText: self.ccToSting, bccToText: self.bccToSting)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        return true
    }
    
    //MARK: - document Picker delegate
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        
        print("picked urls:", urls)
        
        let fileUrl = urls.first!
        
        self.attachmentButton.isEnabled = false
        
        self.interactor?.attachFileToDraftMessage(url: fileUrl)
        
        self.presenter?.addAttachToList(url: fileUrl)  
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        
        self.attachmentButton.isEnabled = true
    }
    
    //MARK: - notification
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func addNotificationObserver() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.attachDownloadUpdate), name: NSNotification.Name(rawValue: k_attachUploadUpdateNotificationID), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        
        if self.messageTextEditor.isFirstResponder {
            if self.view.frame.origin.y == 0 {
                //self.view.frame.origin.y -= CGFloat(keyboardOffset)
                
                scrollViewBottomOffsetConstraint.constant = CGFloat(k_KeyboardHeight) + (UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0)
                self.presenter?.setupMessageSectionSize()
            }
        }
        
        tableViewBottomOffsetConstraint.constant = CGFloat(k_KeyboardHeight)
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y += CGFloat(k_KeyboardHeight)
        }
        
        scrollViewBottomOffsetConstraint.constant = 0.0
        self.presenter?.setupMessageSectionSize()
        tableViewBottomOffsetConstraint.constant = 0.0
    }
    
    @objc func attachDownloadUpdate(notification: Notification) {
        
        let uploadValue = notification.object
        
        let procent = uploadValue as! Double * 100
        
        print("procent:", procent)
        
        if self.viewAttachmentsList.count > 0 {
        
            let attachment = self.viewAttachmentsList.last
            attachment?.backgroundProgressView.isHidden = false
            attachment?.progressViewWidthConstraint.constant = CGFloat(procent)
        
            if procent == 100 {
                attachment?.backgroundProgressView.isHidden = true
            }
        }
    }
    
    @objc func appMovedToBackground() {
        
        print("appMovedToBackground")
        
        self.interactor?.saveDraft()
    }
}

extension ComposeViewController: RichEditorDelegate {
    func richEditor(_ editor: RichEditorView, contentDidChange content: String) {
        self.presenter!.enabledSendButton()
        self.presenter?.setupMessageSectionSize()
    }
    
    func richEditor(_ editor: RichEditorView, heightDidChange height: Int) {
        self.presenter?.setupMessageSectionSize()
    }
    
}

extension ComposeViewController: SetPasswordDelegate {

    func applyAction(password: String, passwordHint: String, expiredTime: Int) {
        
        self.interactor?.sendPasswordForCreatingMessage(password: password, passwordHint: passwordHint, expiredTime: expiredTime)
    }
    
    func cancelAction() {
        
        self.presenter!.encryptedButtonPressed()
    }
}

extension ComposeViewController: SchedulerDelegate {
    
    func applyAction(date: Date, mode: SchedulerMode) {
        print("scheduledDate:", date)
        
        switch mode {
        case SchedulerMode.selfDestructTimer:
            self.selfDestructionDate = date
            self.presenter?.setSelfDestructionButtonMode(applied: true)
            break
        case SchedulerMode.deadManTimer:
            self.deadManDate = date
            self.presenter?.setDeadManButtonMode(applied: true)
            break
        case SchedulerMode.delayedDelivery:
            self.delayedDeliveryDate = date
            self.presenter?.setDelayedDeliveryButtonMode(applied: true)
            break
        }
        
        self.presenter?.setupSchedulersButtons()
    }
    
    func cancelSchedulerAction() {
        
    }
}

extension ComposeViewController: MoreActionsDelegate {
    
    func applyAction(_ sender: AnyObject, isButton: Bool) {
        
        self.presenter?.applyDraftAction(sender, isButton: isButton)
    }
}

extension ComposeViewController: AttachmentDelegate {
    
    func deleteAttach(tag: Int) {
        for (index, attachmentView) in self.viewAttachmentsList.enumerated() {
            if attachmentView.tag == tag {
                self.viewAttachmentsList.remove(at: index)
                self.interactor?.removeAttachFromMailAttachmentList(file: attachmentView.fileUrl)
            }
        }
        
        self.presenter?.setupMessageSectionSize()        
    }
}
