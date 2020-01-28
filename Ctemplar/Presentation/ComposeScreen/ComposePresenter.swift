//
//  ComposePresenter.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 27.11.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import UIKit
import PKHUD
import MobileCoreServices
import RichEditorView

class ComposePresenter {
    
    var viewController   : ComposeViewController?
    var interactor       : ComposeInteractor?
    var formatterService        : FormatterService?
    
    var currentSignature : String = ""
    
    lazy var toolbar: RichEditorToolbar = {
        let toolbar = RichEditorToolbar(frame: CGRect(x: 0, y: 0, width: self.viewController!.view.bounds.width, height: 44))
        toolbar.options = RichEditorDefaultOption.all
        return toolbar
    }()
    
    //MARK: - Setup Answer Mode
    
    func setupNavigationBarTitle(mode: AnswerMessageMode) {
        
        switch mode {
        case AnswerMessageMode.newMessage:
            self.viewController!.navigationItem.title = "newMessage".localized()
            break
        case AnswerMessageMode.reply:
            self.viewController!.navigationItem.title = "reply".localized()
            break
        case AnswerMessageMode.replyAll:
            self.viewController!.navigationItem.title = "relpyAll".localized()
            break
        case AnswerMessageMode.forward:
            self.viewController!.navigationItem.title = "forward".localized()
            break
        }
    }
    
    //MARK: - Setup Buttons
    
    func enabledSendButton() {
        
        var messageContentIsEmpty : Bool = true
        
        if (self.viewController?.messageTextEditor.html ?? "").count > 0 {
            if self.viewController?.messageTextEditor.html != currentSignature {
                messageContentIsEmpty = false
            }
        }
//        if self.viewController!.messageTextView.text.count > 0 {
//            if self.viewController!.messageTextView.text != "composeEmail".localized() {
//                messageContentIsEmpty = false
//            }
//        }
        
        if self.viewController!.emailsToArray.count > 0 && self.viewController!.subject.count > 0 && !messageContentIsEmpty {
            self.viewController!.navigationItem.rightBarButtonItem?.isEnabled = true
        } else {
            self.viewController!.navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }
    
    func backButtonPressed() {
        
        self.showDraftActionsView()
    }
    
    func setupAttachmentButton() {
        
        var attachmentButtonImage = UIImage()
        
        if (self.viewController?.viewAttachmentsList.count)! > 0 {
            attachmentButtonImage = UIImage(named: k_attachApliedImageName)!
        } else {
            attachmentButtonImage = UIImage(named: k_attachImageName)!
        }
        
        self.viewController!.attachmentButton .setImage(attachmentButtonImage, for: .normal)
    }
    
    func setupEncryptedButton() {
        
        if let draftMessage = self.viewController!.interactor?.sendingMessage {
                     
            if let isMessageEncryptedForNonCtemplarUser = draftMessage.encryption?.password {
            
                if isMessageEncryptedForNonCtemplarUser.count > 0 {
                    self.setEncryptedButtonMode(applied: true)
                } else {
                    self.setEncryptedButtonMode(applied: false)
                }
            } else {
                self.setEncryptedButtonMode(applied: false)
            }
            
            //self.setEncryptedButtonMode(applied: (self.viewController?.encryptedMail)!)
        }
    }
    
    func setEncryptedButtonMode(applied: Bool) {
        
        var buttonImage = UIImage()
        
        if applied {
            buttonImage = UIImage(named: k_encryptApliedImageName)!
            
        } else {
            buttonImage = UIImage(named: k_encryptImageName)!
        }
        
        self.viewController?.encryptedButton.setImage(buttonImage, for: .normal)
    }
    
    func setSelfDestructionButtonMode(applied: Bool) {
        
        var buttonImage = UIImage()
        
        if applied {
            buttonImage = UIImage(named: k_selfDestructedApliedImageName)!
            
        } else {
            buttonImage = UIImage(named: k_selfDestructedImageName)!
        }
        
        self.viewController?.selfDestructedButton.setImage(buttonImage, for: .normal)
    }
    
    func setDelayedDeliveryButtonMode(applied: Bool) {
        
        var buttonImage = UIImage()
        
        if applied {
            buttonImage = UIImage(named: k_delayedDeliveryApliedImageName)!
            
        } else {
            buttonImage = UIImage(named: k_delayedDeliveryImageName)!
        }
        
        self.viewController?.delayedDeliveryButton.setImage(buttonImage, for: .normal)
    }
    
    func setDeadManButtonMode(applied: Bool) {
        
        var buttonImage = UIImage()
        
        if applied {
            buttonImage = UIImage(named: k_deadManApliedImageName)!
            
        } else {
            buttonImage = UIImage(named: k_deadManImageName)!
        }
        
        self.viewController?.deadManButton.setImage(buttonImage, for: .normal)
    }
    
    func showScheduler(mode: SchedulerMode) {
        
        switch mode {
        case SchedulerMode.selfDestructTimer:
            if self.viewController?.selfDestructionDate == nil {
                self.viewController?.router?.showSchedulerViewController(mode: mode)
            } else {
                self.viewController?.selfDestructionDate = nil
                self.setSelfDestructionButtonMode(applied: false)
            }
            break
        case SchedulerMode.deadManTimer:
            if self.viewController?.deadManDate == nil {
                self.viewController?.router?.showSchedulerViewController(mode: mode)
            } else {
                self.viewController?.deadManDate = nil
                self.setDeadManButtonMode(applied: false)
            }
            break
        case SchedulerMode.delayedDelivery:
            if self.viewController?.delayedDeliveryDate == nil {
                self.viewController?.router?.showSchedulerViewController(mode: mode)
            } else {
                self.viewController?.delayedDeliveryDate = nil
                self.setDelayedDeliveryButtonMode(applied: false)
            }
            break
        }
        
        self.setupSchedulersButtons()
    }
    
    func checkIsPrimeAccount(mode: SchedulerMode) {
        
        switch mode {
        case SchedulerMode.selfDestructTimer:
            break
        case SchedulerMode.deadManTimer:
            if !(self.viewController?.user.isPrime)! {
                self.showUpgradeToPrimeView()
                return
            }
            break
        case SchedulerMode.delayedDelivery:
            if !(self.viewController?.user.isPrime)! {
                self.showUpgradeToPrimeView()
                return
            }
            break
        }
        
        self.showScheduler(mode: mode)
    }
    
    func setupSchedulersButtons() {
        
        self.viewController?.selfDestructedButton.isEnabled = true
        /*
        if (self.viewController?.user.isPrime)! {
        
            if self.viewController?.deadManDate != nil {
                self.viewController?.delayedDeliveryButton.isEnabled = false
            } else {
                self.viewController?.delayedDeliveryButton.isEnabled = true
            }
            
            if self.viewController?.delayedDeliveryDate != nil {
                self.viewController?.deadManButton.isEnabled = false
            } else {
                self.viewController?.deadManButton.isEnabled = true
            }
        } else {
            self.viewController?.delayedDeliveryButton.isEnabled = false
            self.viewController?.deadManButton.isEnabled = false
        }*/
        
        self.viewController?.delayedDeliveryButton.isEnabled = true
        self.viewController?.deadManButton.isEnabled = true
    }
    
    func setSchedulerTimersForMessage(message: EmailMessage) {
        
        if let selfDestructionDateString = message.destructDay {
            if let selfDestructionDate = self.formatterService?.formatDestructionTimeStringToDateTest(date: selfDestructionDateString) {
                self.viewController?.selfDestructionDate = selfDestructionDate
            }
            self.setSelfDestructionButtonMode(applied: true)
        } else {
            self.viewController?.selfDestructionDate = nil
            self.setSelfDestructionButtonMode(applied: false)
        }

        if let delayedDeliveryDateString = message.delayedDelivery {
            if let delayedDeliveryDate = self.formatterService?.formatDestructionTimeStringToDate(date: delayedDeliveryDateString) {
                self.viewController?.delayedDeliveryDate = delayedDeliveryDate
            }
            self.setDelayedDeliveryButtonMode(applied: true)
        } else {
            self.viewController?.delayedDeliveryDate = nil
            self.setDelayedDeliveryButtonMode(applied: false)
        }
        
        if let deadManDuration = message.deadManDuration {
            self.viewController?.deadManDate = self.formatterService?.formatDeadManDurationToDate(duration: deadManDuration)
            self.setDeadManButtonMode(applied: true)
        } else {
            self.viewController?.deadManDate = nil
            self.setDeadManButtonMode(applied: false)
        }
    }
    
    //MARK: - Setup Message Section
    
    func setupMessageEditorView() {
        self.viewController?.messageTextEditor.inputAccessoryView = toolbar
        self.viewController?.messageTextEditor.placeholder = "Type message here..."
        
        toolbar.editor = self.viewController?.messageTextEditor
        toolbar.delegate = self
        
        let clearItem = RichEditorOptionItem(image: nil, title: "Clear") { (toolbar) in
            toolbar.editor?.html = ""
        }
        let doneItem = RichEditorOptionItem(image: nil, title: "Done") { (toolbar) in
            self.viewController?.messageTextEditor.endEditing(true)
        }
        
        var options = toolbar.options
        options.append(contentsOf: [clearItem, doneItem])
        toolbar.options = options
    }
    
    func setupAttachments(message: EmailMessage) {
         
        if let attachments = message.attachments {
            
            self.viewController?.mailAttachmentsList.removeAll()
            self.viewController?.viewAttachmentsList.removeAll()
            
            var tag = ComposeSubViewTags.attachmentsViewTag.rawValue
            
            for attachment in attachments {
                self.viewController?.mailAttachmentsList.append(attachment.toDictionary())
                
                let urlString = attachment.contentUrl
                let url = URL(string: urlString!)
                
                tag = tag + 1
                
                let attachmentView  = self.viewController!.presenter?.createAttachment(frame: CGRect.zero, tag: tag, fileUrl: url!)
                
                self.viewController!.viewAttachmentsList.append(attachmentView!)
            }
        }
    }
    
    func addAttachToList(url: URL) {
        
        var lastTag = ComposeSubViewTags.attachmentsViewTag.rawValue
        
        if self.viewController!.viewAttachmentsList.count > 0 {
            
            let lastAttachmentView = self.viewController!.viewAttachmentsList.max(by: {$0.tag < $1.tag} )
            lastTag = (lastAttachmentView?.tag)!
        }
        
        let newIndexTag = lastTag + 1
        
        let attachmentView  = self.createAttachment(frame: CGRect.zero, tag: newIndexTag, fileUrl: url)
        
        self.viewController!.viewAttachmentsList.append(attachmentView)
        
        self.setupMessageSectionSize()
    }
    
    func setAttachmentsToMessage() {
        viewController?.scrollView.subviews.forEach {
            ($0 as? UIStackView)?.removeFromSuperview()
        }
        if let list = viewController?.viewAttachmentsList,
            list.count > 0,
            let scrollView = viewController?.scrollView,
        let textEditor = viewController?.messageTextEditor {
            let stack = attachmentStackView(from: list)
            stack.translatesAutoresizingMaskIntoConstraints = false
            viewController?.scrollView.add(subview: stack)
            stack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: k_emailToTextViewLeftOffset).isActive = true
            stack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -k_emailToTextViewLeftOffset).isActive = true
            stack.topAnchor.constraint(equalTo: textEditor.bottomAnchor, constant: k_messageTextViewTopOffset).isActive = true
            stack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -k_emailToTextViewLeftOffset).isActive = true
            viewController?.messageTextEditorBottomOffsetConstraint.priority = .defaultLow
        }
    }
    
    func setupMessageSectionSize() {
        
        self.setupAttachmentButton()
        
        //self.viewController?.messageTextView.backgroundColor = UIColor.yellow
        let fixedWidth = self.viewController!.view.frame.width - k_emailToTextViewLeftOffset - k_emailToTextViewLeftOffset
        
        let messageContentHeight: CGFloat = CGFloat(self.viewController!.messageTextEditor.editorHeight) //self.sizeThatFits(textView: self.viewController!.messageTextView, fixedWidth: fixedWidth)
        let scrollViewHeight = self.viewController?.scrollView.frame.size.height
        
        self.setAttachmentsToMessage()
        
        if let list = viewController?.viewAttachmentsList, list.count > 0 {
            self.viewController!.messageTextEditorHeightConstraint.constant = messageContentHeight
        } else { //without attachments
            viewController?.messageTextEditorBottomOffsetConstraint.priority = UILayoutPriority(rawValue: 999)
            let content = self.interactor?.getEnteredMessageContent()
            if content?.count == 0 { //empty message
                self.viewController?.messageTextEditorHeightConstraint.constant = scrollViewHeight! - k_messageTextViewTopOffset - k_messageTextViewTopOffset
            } else {
                self.viewController!.messageTextEditorHeightConstraint.constant = messageContentHeight
            }
        }
        
        self.viewController?.view.layoutIfNeeded()
    }
    
    func setupMessageSection(message: EmailMessage) {
    
        if let messageContent = self.interactor?.getMessageContent(message: message) {
            
            if messageContent.count > 0 {
                
//                let mutableAttributedString = NSMutableAttributedString()
                var contentString = ""
                let replyHeader = self.generateHtmlHeader(message: message, answerMode: self.viewController!.answerMode) //self.generateHeader(message: message, answerMode: self.viewController!.answerMode)
                
//                let content = messageContent.replacingOccurrences(of: "\n", with: "<br>")
//                let messageContentAttributedString = content.html2AttributedString
//                let headerMutableAttributedString = NSMutableAttributedString(attributedString: replyHeader)
//                mutableAttributedString.append(headerMutableAttributedString)
//                mutableAttributedString.append(messageContentAttributedString!)
                contentString.append(replyHeader)
                contentString.append(messageContent)
                if currentSignature.count > 0 {
                    contentString.append(currentSignature)
//                    mutableAttributedString.append(NSMutableAttributedString(string: currentSignature))
//                    mutableAttributedString.append(currentSignature.html2AttributedString ?? NSAttributedString())
                }
                self.viewController!.messageTextEditor.html = contentString
//                self.viewController?.messageTextView.attributedText = mutableAttributedString
//                self.viewController?.messageTextView.setContentOffset(.zero, animated: true)
            } else {
                if currentSignature.count > 0 {
                    self.viewController!.messageTextEditor.html = "<br><br>" + currentSignature
//                    let attributedString = currentSignature.html2AttributedString ?? NSAttributedString() //NSAttributedString(string: "\n" + currentSignature)
//                    self.viewController?.messageTextView.attributedText = attributedString
//                    self.viewController?.messageTextView.setContentOffset(.zero, animated: true)
                }
//                else {
//                    self.setPlaceholderToMessageTextView(show: true)
//                }
            }
        }
        
        self.enabledSendButton()
        self.setupMessageSectionSize()
    }
    
    func setupSignature(_ newSignature: String) {
        
        print("set new Signature:", newSignature)
        
//        guard let currentMessageText = self.viewController?.messageTextView.attributedText else { return }
        var currentMessageText = self.viewController?.messageTextEditor.html
//        let mutableAttributedString = NSMutableAttributedString(attributedString: currentMessageText)
        
        if let range = currentMessageText?.range(of: currentSignature) {
//            let nsRange = NSRange(range, in: currentMessageText ?? "")
            
//            let newAttributedStringSignature =  newSignature.html2AttributedString ?? NSAttributedString() //NSAttributedString(string: newSignature)
            let messageContentWithNewSignature = (currentMessageText ?? "").replacingCharacters(in: range, with: newSignature)
//            mutableAttributedString.replaceCharacters(in: nsRange, with: newAttributedStringSignature)
            self.viewController?.messageTextEditor.html = messageContentWithNewSignature
//            self.viewController?.messageTextView.attributedText = mutableAttributedString
            currentSignature = newSignature
        } else {
            currentSignature = newSignature
            currentMessageText?.append(newSignature)
//            let newAttributedStringSignature =  newSignature.html2AttributedString ?? NSAttributedString() //NSAttributedString(string: "\n" + newSignature)
//            mutableAttributedString.insert(newAttributedStringSignature, at: 0)
            self.viewController?.messageTextEditor.html = currentMessageText ?? ""
//            self.viewController?.messageTextView.attributedText = mutableAttributedString
        }
        
//        self.viewController?.messageTextView.setContentOffset(.zero, animated: true)
        self.setupMessageSectionSize()
    }
    
//    func setPlaceholderToMessageTextView(show: Bool) {
//        
//        if show {
//            self.viewController?.messageTextView.font = UIFont(name: k_latoRegularFontName, size: 16.0)
//            self.viewController?.messageTextView.text = "composeEmail".localized()
//            self.viewController?.messageTextView.textColor = UIColor.lightGray
//        } else {
//            if self.viewController?.messageTextView.text == "composeEmail".localized() {
//                self.viewController?.messageTextView.text = ""
//                self.viewController?.messageTextView.textColor = UIColor.darkText //temp
//            }
//        }
//    }
   
    func sizeThatFits(textView: UITextView, fixedWidth: CGFloat) -> CGFloat {
        
        textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        let newTextViewSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        var newTextViewFrame = textView.frame
        newTextViewFrame.size = CGSize(width: max(newTextViewSize.width, fixedWidth), height: newTextViewSize.height)
        textView.frame = newTextViewFrame
        
        return newTextViewFrame.height
    }
    
    func generateHeader(message: EmailMessage, answerMode: AnswerMessageMode) -> NSAttributedString {
        
        var attributedString = NSAttributedString()
         
        switch answerMode {
        case AnswerMessageMode.newMessage:
           
            break
        case AnswerMessageMode.reply:
            attributedString = self.generateReplyHeader(message: message)
            break
        case AnswerMessageMode.replyAll:
            attributedString = self.generateReplyHeader(message: message)
            break
        case AnswerMessageMode.forward:
            attributedString = self.generateForwardHeader(message: message, subject: self.viewController?.subject ?? "")
            break
        }
        
        return attributedString
    }
    
    func generateHtmlHeader(message: EmailMessage, answerMode: AnswerMessageMode) -> String {
        var string = ""
        switch answerMode {
        case .newMessage:
            break
        case .reply:
            string = self.generateHtmlReplyHeader(message: message)
            break
        case .replyAll:
            string = self.generateHtmlReplyHeader(message: message)
            break
        case .forward:
            string = self.generateHtmlForwardHeader(message: message, subject: self.viewController?.subject ?? "")
            break
        }
        return string
    }
    
    func generateReplyHeader(message: EmailMessage) -> NSAttributedString {
        
        var replyHeader : String = ""
 
        if let sentAtDate = message.updated { //message.sentAt
            
            if  let date = self.formatterService!.formatStringToDate(date: sentAtDate) {
                let formattedDate = self.formatterService!.formatReplyDate(date: date)
                let formattedTime = self.formatterService!.formatDateToStringTimeFull(date: date)
            
                replyHeader = "\n\n" + "replyOn".localized() + replyHeader + formattedDate + "atTime".localized() + formattedTime + "\n"
            }
        }
        
        if let sender = message.sender {
            replyHeader = replyHeader + "<" + sender + "> " + "wroteBy".localized() + "\n\n"
        }
        
        let font : UIFont = UIFont(name: k_latoRegularFontName, size: 14.0)!
        
        let attributedString = NSMutableAttributedString(string: replyHeader, attributes: [
            .font: font,
            .foregroundColor: k_actionMessageColor,
            .kern: 0.0
            ])
        
        return attributedString
    }
    
    func generateHtmlReplyHeader(message: EmailMessage) -> String{
        var replyHeader = ""
        if let sentAtDate = message.updated {
            if let date = self.formatterService!.formatStringToDate(date: sentAtDate) {
                let formattedDate = self.formatterService!.formatReplyDate(date: date)
                let formattedTime = self.formatterService!.formatDateToStringTimeFull(date: date)
                replyHeader = "<br><br>" + "<p>" + "replyOn".localized() + formattedDate + "atTime".localized() + formattedTime + "</p>"
            }
        }
        if let sender = message.sender {
            replyHeader = replyHeader + "<p>\"" + sender + "\" " + "wroteBy".localized() + "</p><br>"
        }
        return replyHeader
    }
    
    func generateForwardHeader(message: EmailMessage, subject: String) -> NSAttributedString {
        /*
        ---------- Forwarded message ----------
            
        From: <atif1@dev.ctemplar.com>
        
        Date: Dec 14, 2018, 11:10:23 AM
        
        Subject: Self-destructing Msg
        
        To: <dmitry3@dev.ctemplar.com>
        */
        var forwardHeader : String = ""
        forwardHeader = forwardHeader + "forwardLine".localized()
        
        if let sender = message.sender {
            forwardHeader = forwardHeader + "\n" + "emailFromPrefix".localized() + "<" + sender + "> " + "\n"
        }
        
        if let sentAtDate = message.updated { //message.sentAt
            
            if  let date = self.formatterService!.formatStringToDate(date: sentAtDate) {
                let formattedDate = self.formatterService!.formatReplyDate(date: date)
                let formattedTime = self.formatterService!.formatDateToStringTimeFull(date: date)
                
                forwardHeader = forwardHeader + "date".localized() + formattedDate + "atTime".localized() + formattedTime + "\n"
            }
        }
        
        //if let subject = message.subject {
            forwardHeader = forwardHeader + "subject".localized() + subject + "\n"
        //}
        
        if let recieversArray = message.receivers  {
            for email in recieversArray as! [String] {
                 forwardHeader = forwardHeader + "emailToPrefix".localized() + "<" + email + "> "
            }
        }
        
        forwardHeader = forwardHeader + "\n\n"
                
        let font : UIFont = UIFont(name: k_latoRegularFontName, size: 14.0)!
        
        let attributedString = NSMutableAttributedString(string: forwardHeader, attributes: [
            .font: font,
            .foregroundColor: k_actionMessageColor,
            .kern: 0.0
            ])
        
        return attributedString
    }
    
    func generateHtmlForwardHeader(message: EmailMessage, subject: String) -> String{
        var forwardHeader : String = ""
        forwardHeader = forwardHeader + "<p>" + "forwardLine".localized() + "</p>"
        
        if let sender = message.sender {
            forwardHeader = forwardHeader + "<p>" + "emailFromPrefix".localized() + "\" " + sender + "\"</p><br>"
        }
        
        if let sentAtDate = message.updated { //message.sentAt
            
            if  let date = self.formatterService!.formatStringToDate(date: sentAtDate) {
                let formattedDate = self.formatterService!.formatReplyDate(date: date)
                let formattedTime = self.formatterService!.formatDateToStringTimeFull(date: date)
                
                forwardHeader = forwardHeader + "<p>" + "date".localized() + formattedDate + "atTime".localized() + formattedTime + "</p>"
            }
        }
        forwardHeader = forwardHeader + "<p>" + "subject".localized() + subject + "</p>"
        
        if let recieversArray = message.receivers  {
            forwardHeader = forwardHeader + "<p>"
            for email in recieversArray as! [String] {
                 forwardHeader = forwardHeader + "emailToPrefix".localized() + "\"" + email + "\" "
            }
            forwardHeader = forwardHeader + "</p>"
        }
        forwardHeader = forwardHeader + "<br><br>"
        return forwardHeader
    }
    
    func setupTableView(topOffset: CGFloat) {
        
        self.viewController!.tableViewTopOffsetConstraint.constant = topOffset//k_composeTableViewTopOffset
        self.viewController!.view.layoutIfNeeded()
    }
    
    //MARK: - Setup Email From Section
    
    func setMailboxes(mailboxes: Array<Mailbox>) {
        currentSignature = UserDefaults.standard.string(forKey: k_mobileSignatureKey) ?? ""
        for mailbox in mailboxes {
            guard mailbox.isDefault == true else { continue }
            if let defaultEmail = mailbox.email {
                self.setupEmailFromSection(emailFromText: defaultEmail)
            }
            if currentSignature.isEmpty {
                currentSignature = mailbox.signature ?? ""
            }
            self.viewController!.mailboxID = mailbox.mailboxID!
        }        
        if mailboxes.count < 2 {
            //self.viewController!.mailboxesButton.isEnabled = false
        }
    }
    
    func setupEmailFromSection(emailFromText: String) {
        
        self.viewController!.sender = emailFromText
        
        let emailFromString = "emailFromPrefix".localized() + emailFromText
        
        let font : UIFont = UIFont(name: k_latoRegularFontName, size: 14.0)!
        
        let attributedString = NSMutableAttributedString(string: emailFromString, attributes: [
            .font: font,
            .foregroundColor: k_actionMessageColor,
            .kern: 0.0
            ])
        
        _ = attributedString.setForgroundColor(textToFind: "emailFromPrefix".localized(), color: k_emailToColor)
        
        self.viewController?.emailFrom.attributedText = attributedString
    }
    
    func mailboxesButtonPressed() {
        
        let hideTableView = self.viewController?.dataSource?.tableView.isHidden
        
        self.viewController?.dataSource?.tableView.isHidden = !hideTableView!
        
        var buttonImage = UIImage()
        
        if !hideTableView! {
            buttonImage = UIImage(named: k_downArrowImageName)!
        } else {
            buttonImage = UIImage(named: k_upArrowImageName)!
        }
        
        self.viewController!.mailboxesButton.setBackgroundImage(buttonImage, for: .normal)
        
        self.setupTableView(topOffset: k_composeTableViewTopOffset)
        
        self.viewController?.dataSource?.reloadData(setMailboxData: true)
    }
    
    func setMailboxDataSource(mailboxes: Array<Mailbox>) {
        
        self.viewController?.dataSource?.mailboxesArray = mailboxes        
    }
    
    func setContactsDataSource(contacts: Array<Contact>) {
        
        self.viewController?.dataSource?.contactsArray = contacts
    }
    
    //MARK: - Setup Email To Subsection
    
    var emailToSubViewsArray = Array<Int>()
    var ccToSubViewsArray = Array<Int>()
    var bccToSubViewsArray = Array<Int>()
    
    func fillAllEmailsFields(message: EmailMessage) {
        
        let answerMode = self.viewController!.answerMode
        if answerMode != AnswerMessageMode.forward {
            
           if let sender = message.sender {
                if sender == self.viewController!.sender {
                    if let recieversArray = message.receivers {
                        self.viewController!.emailsToArray = recieversArray as! [String]
                        
                        for email in self.viewController!.emailsToArray {
                            self.viewController!.emailToSting = self.viewController!.emailToSting + email + " "
                        }
                    }
                } else {
                    self.viewController!.emailToSting = self.viewController!.emailToSting + sender
                    self.viewController!.emailsToArray.append(sender)
                }
            }
        }
        
        
        if let ccArray = message.cc {
            self.viewController!.ccToArray = ccArray as! [String]
                
            if answerMode == AnswerMessageMode.replyAll {
                if let recieversArray = message.receivers  {
                    
                    for reciever in recieversArray {
                        if reciever as! String != self.viewController!.sender {
                            self.viewController!.ccToArray.append(reciever as! String)
                        }
                    }
                    //self.viewController!.ccToArray.append(contentsOf: recieversArray as! [String])
                }
            }
            
            for email in self.viewController!.ccToArray {
            
                self.viewController!.ccToSting = self.viewController!.ccToSting + email + " "
            }
        }
            
        if let bccArray = message.bcc {
            self.viewController!.bccToArray = bccArray as! [String]
                
            for email in self.viewController!.bccToArray {
                self.viewController!.bccToSting = self.viewController!.bccToSting + email + " "
            }
        }
        
        self.setupEmailToSection(emailToText: self.viewController!.emailToSting, ccToText: self.viewController!.ccToSting, bccToText: self.viewController!.bccToSting)
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
        
        for email in self.viewController!.emailsToArray {
            //_ = attributedString.setBackgroundColor(textToFind: email, color: k_mainInboxColor)
            _ = attributedString.setForgroundColor(textToFind: email, color: k_emailToInputColor)
        }
        
        if self.viewController!.tapSelectedEmail.count > 0 {
       //     _ = attributedString.setBackgroundColor(textToFind: self.viewController!.tapSelectedEmail, color: k_foundTextBackgroundColor)
        }
        
        self.viewController!.emailToTextView.attributedText = attributedString
        //self.viewController!.emailToTextView.text = emailToText
    }
    
    func setRect(textView: UITextView, email: String, tag: Int, color: UIColor) {
        
        let text = textView.text!
        
        let wordRange = (text as NSString).range(of: email)
        
        let textContainer = textView.textContainer
        
        let glyphRange = textView.layoutManager.glyphRange(forCharacterRange: wordRange, actualCharacterRange: nil)
        
        var glyphRect = textView.layoutManager.boundingRect(forGlyphRange: glyphRange, in: textContainer)
        
        glyphRect.origin.x += textView.textContainerInset.left
        
        //print("textView.textContainerInset.top:", textView.textContainerInset.top) // 8 - 2
        
        let rect = CGRect(x: glyphRect.origin.x, y: glyphRect.origin.y + 6.0, width: glyphRect.size.width, height: 22.0)
        
        self.addEmailLabelWith(text: email, rect: rect, index: tag, textView: textView, color: color)
    }
    
    func addEmailLabelWith(text: String, rect: CGRect, index: Int, textView: UITextView, color: UIColor) {
        
        let view = UIView(frame: rect)
        /*
        if selected {
            view.backgroundColor = k_foundTextBackgroundColor
        } else {
            view.backgroundColor = k_mainInboxColor
        }*/
        view.backgroundColor = color
        
        view.layer.cornerRadius = 4.0
        view.layer.borderColor = UIColor.white.cgColor
        view.layer.borderWidth = 1.0
  
        let labelRect = CGRect(x: 0.0, y: 0.0, width: rect.size.width, height: rect.size.height)
        let label = UILabel(frame: labelRect)
        label.font = UIFont(name: k_latoRegularFontName, size: 14.0)
        label.textColor = k_emailToInputColor
        let formattedText = text.dropLast().dropFirst()        
        label.text = String(formattedText)
        label.textAlignment = .center
        //label.text = text
        label.backgroundColor = UIColor.clear
        
        view.tag = index
        
        view.add(subview: label)
        textView.add(subview: view)
    }
    
    func removeSubviews(textView: UITextView, array: Array<Int>, tag: Int) {
        
        for index in array {
            print("remove at index:", index)
            self.removeEmailLabels(textView: textView, index: index)
        }
    }
    
    func removeEmailLabels(textView: UITextView, index: Int) {
        
        if let subview = textView.viewWithTag(index) {
            subview.removeFromSuperview()
        }
    }
    
    func setupEmailToViewSize() -> CGFloat {
        
        let fixedWidth = self.viewController!.view.frame.width - k_emailToTextViewLeftOffset - k_expandDetailsButtonWidth
        
        self.viewController!.emailToTextView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        let newEmailToTextViewSize = self.viewController!.emailToTextView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        var newEmailToTextViewFrame = self.viewController!.emailToTextView.frame
        newEmailToTextViewFrame.size = CGSize(width: max(newEmailToTextViewSize.width, fixedWidth), height: newEmailToTextViewSize.height)
        self.viewController!.emailToTextView.frame = newEmailToTextViewFrame
        
        return self.viewController!.emailToTextView.frame.height
    }
    
    func expandButtonPressed() {
        
        var expandButtonImage = UIImage()
        
        if self.viewController!.expandedSectionHeight == 0 {
            self.viewController!.expandedSectionHeight = self.viewController!.ccViewSubsectionHeightConstraint.constant + self.viewController!.bccViewSubsectionHeightConstraint.constant

            self.viewController!.ccToSubSectionView.isHidden = false
            self.viewController!.bccToSubSectionView.isHidden = false
            
            expandButtonImage = UIImage(named: k_redMinusBigIconImageName)!
        } else {
            self.viewController!.ccToSubSectionView.isHidden = true
            self.viewController!.bccToSubSectionView.isHidden = true
            self.viewController!.expandedSectionHeight = 0
            
            expandButtonImage = UIImage(named: k_darkPlusBigIconImageName)!
        }
        
        self.viewController!.expandButton .setImage(expandButtonImage, for: .normal)
        
        self.setupEmailToSection(emailToText: self.viewController!.emailToSting, ccToText: self.viewController!.ccToSting, bccToText: self.viewController!.bccToSting)
        
        self.setupTableView(topOffset: k_composeTableViewTopOffset + self.viewController!.toViewSectionHeightConstraint.constant - 5.0)
        self.setupMessageSectionSize()
    }
    
    //MARK: - Setup Cc To Subsection
    
    func setupCcToViewText(ccToText: String) {
        
        let style = NSMutableParagraphStyle()
        style.lineSpacing = CGFloat(k_lineSpaceSizeForFromToText)
        
        let font : UIFont = UIFont(name: k_latoRegularFontName, size: 14.0)!
        
        let attributedString = NSMutableAttributedString(string: ccToText, attributes: [
            .font: font,
            .foregroundColor: k_emailToColor,//k_actionMessageColor,
            .kern: 0.0,
            .paragraphStyle: style
            ])
        
        for email in self.viewController!.ccToArray {
          //  _ = attributedString.setBackgroundColor(textToFind: email, color: k_mainInboxColor)
            _ = attributedString.setForgroundColor(textToFind: email, color: k_emailToInputColor)
        }
        
        if self.viewController!.tapSelectedCcEmail.count > 0 {
          //  _ = attributedString.setBackgroundColor(textToFind: self.viewController!.tapSelectedCcEmail, color: k_foundTextBackgroundColor)
        }
        
        self.viewController!.ccToTextView.attributedText = attributedString
    }
    
    func setupCcToViewSize() -> CGFloat {
        
        let fixedWidth = self.viewController!.view.frame.width - k_emailToTextViewLeftOffset - k_emailToTextViewLeftOffset
        
        self.viewController!.ccToTextView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        let newEmailToTextViewSize = self.viewController!.ccToTextView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        var newEmailToTextViewFrame = self.viewController!.ccToTextView.frame
        newEmailToTextViewFrame.size = CGSize(width: max(newEmailToTextViewSize.width, fixedWidth), height: newEmailToTextViewSize.height)
        self.viewController!.ccToTextView.frame = newEmailToTextViewFrame;
        
        return self.viewController!.ccToTextView.frame.height
    }
    
    //MARK: - Setup Bcc To Subsection
    
    func setupBccToViewText(bccToText: String) {
        
        let style = NSMutableParagraphStyle()
        style.lineSpacing = CGFloat(k_lineSpaceSizeForFromToText)
        
        let font : UIFont = UIFont(name: k_latoRegularFontName, size: 14.0)!
        
        let attributedString = NSMutableAttributedString(string: bccToText, attributes: [
            .font: font,
            .foregroundColor: k_emailToColor,//k_actionMessageColor,
            .kern: 0.0,
            .paragraphStyle: style
            ])
        
        for email in self.viewController!.bccToArray {
          //  _ = attributedString.setBackgroundColor(textToFind: email, color: k_mainInboxColor)
            _ = attributedString.setForgroundColor(textToFind: email, color: k_emailToInputColor)
        }
        
        if self.viewController!.tapSelectedBccEmail.count > 0 {
         //   _ = attributedString.setBackgroundColor(textToFind: self.viewController!.tapSelectedBccEmail, color: k_foundTextBackgroundColor)
        }
        
        self.viewController!.bccToTextView.attributedText = attributedString
    }
    
    func setupBccToViewSize() -> CGFloat {
        
        let fixedWidth = self.viewController!.view.frame.width - k_emailToTextViewLeftOffset - k_emailToTextViewLeftOffset
        
        self.viewController!.bccToTextView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        let newEmailToTextViewSize = self.viewController!.bccToTextView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        var newEmailToTextViewFrame = self.viewController!.bccToTextView.frame
        newEmailToTextViewFrame.size = CGSize(width: max(newEmailToTextViewSize.width, fixedWidth), height: newEmailToTextViewSize.height)
        self.viewController!.bccToTextView.frame = newEmailToTextViewFrame;
        
        return self.viewController!.bccToTextView.frame.height
    }
    
    //MARK: - Setup Email To Section
    
    func setupEmailToSection(emailToText: String, ccToText: String, bccToText: String) {
        
        //self.viewController!.emailToTextView.backgroundColor = UIColor.yellow//debug
        //self.viewController!.ccToTextView.backgroundColor = UIColor.yellow
        //self.viewController!.bccToTextView.backgroundColor = UIColor.yellow
             
        self.setupEmailToViewText(emailToText: emailToText)
        
        self.setupEmailToViewText(emailToText: emailToText)
        let emailToViewHeight = self.setupEmailToViewSize()
        
        self.viewController!.toViewSubsectionHeightConstraint.constant = emailToViewHeight + k_emailToTextViewTopOffset + k_emailToTextViewTopOffset
        
        self.setupCcToViewText(ccToText: ccToText)
        let ccToViewHeight = self.setupCcToViewSize()
        
        self.viewController!.ccViewSubsectionHeightConstraint.constant = ccToViewHeight + k_emailToTextViewTopOffset + k_emailToTextViewTopOffset
        
        self.setupBccToViewText(bccToText: bccToText)
        let bccToViewHeight = self.setupBccToViewSize()
        
        self.viewController!.bccViewSubsectionHeightConstraint.constant = bccToViewHeight + k_emailToTextViewTopOffset + k_emailToTextViewTopOffset
        
        if self.viewController!.expandedSectionHeight != 0 {
        
            self.viewController!.expandedSectionHeight =  self.viewController!.ccViewSubsectionHeightConstraint.constant +  self.viewController!.bccViewSubsectionHeightConstraint.constant
        }
        
        self.viewController!.toViewSectionHeightConstraint.constant = self.viewController!.toViewSubsectionHeightConstraint.constant + self.viewController!.expandedSectionHeight
        
        self.updateContentOffset(textView: self.viewController!.emailToTextView)
        self.updateContentOffset(textView: self.viewController!.ccToTextView)
        self.updateContentOffset(textView: self.viewController!.bccToTextView)
        
        //set rects
        
        self.emailToSubViewsArray = self.setRecanglesFor(textView: self.viewController!.emailToTextView, emailArray: self.viewController!.emailsToArray, selectedEmail: self.viewController!.tapSelectedEmail, subViewsArray: self.emailToSubViewsArray, subViewTag: ComposeSubViewTags.emailToTextViewTag.rawValue)
        
        self.ccToSubViewsArray = self.setRecanglesFor(textView: self.viewController!.ccToTextView, emailArray: self.viewController!.ccToArray, selectedEmail: self.viewController!.tapSelectedCcEmail, subViewsArray: self.ccToSubViewsArray, subViewTag: ComposeSubViewTags.ccToTextViewTag.rawValue)
        
        self.bccToSubViewsArray = self.setRecanglesFor(textView: self.viewController!.bccToTextView, emailArray: self.viewController!.bccToArray, selectedEmail: self.viewController!.tapSelectedBccEmail, subViewsArray: self.bccToSubViewsArray, subViewTag: ComposeSubViewTags.bccToTextViewTag.rawValue)
        
        //self.setupMessageSectionSize()
        //debug:
        
        print("emailsToArray count:", self.viewController!.emailsToArray.count)
        
        for email in self.viewController!.emailsToArray {
            print("emailTo:", email)
        }
    }
    
    func updateContentOffset(textView: UITextView) {
        
        let offset = CGPoint(x: 0, y: textView.contentSize.height - textView.bounds.size.height)        
        textView.setContentOffset(offset, animated: true)
    }
    
    func setRecanglesFor(textView: UITextView, emailArray: Array<String>, selectedEmail: String, subViewsArray: Array<Int>, subViewTag: Int) -> Array<Int> {
        
        var tag = subViewTag
        var localSubViewsArray = subViewsArray
        
        self.removeSubviews(textView: textView, array:  localSubViewsArray, tag: tag)
        localSubViewsArray.removeAll()
        
        for email in emailArray {
            
            var selected = false
            
            tag = tag + 1
            
            if selectedEmail.count > 0 {
                if email == selectedEmail {
                    selected = true
                }
            }
            
            //temp, need to refactored
            var color : UIColor = k_mainInboxColor
            
            //if self.findDuplicatedEmails(emailArray: emailArray, currentEmail: email) {
            //    color = UIColor.orange
            //}
            
            if !self.validateEmail(currentEmail: email) {
                color = k_redColor
            }
            
            if selected {
                color = k_foundTextBackgroundColor
            }
            
            let formattedEmail = "<" + email + ">"
            
            self.setRect(textView: textView, email: formattedEmail, tag: tag, color: color)
            localSubViewsArray.append(tag)
        }
        
        return localSubViewsArray
    }
    
    func findDuplicatedEmails(emailArray: Array<String>, currentEmail: String) -> Bool {
        
        var find = 0
        
        for email in emailArray {
            if email == currentEmail {
                find = find + 1
            }
        }
        
        if find > 0 {
            return true
        }
        
        return false
    }
    
    func validateEmail(currentEmail: String) -> Bool {
     
        if (formatterService?.validateEmailFormat(enteredEmail: currentEmail))! {
            return true
        }
        
        return false
    }
    
    //MARK: - Setup Subject Section
    
    func setupSubject(subjectText: String, answerMode: AnswerMessageMode) {
        
        var subject: String = ""
        var prefix: String = ""
        
        switch answerMode {
        case AnswerMessageMode.newMessage:
            prefix = ""
            break
        case AnswerMessageMode.reply:
            prefix = "replySubject".localized()
            break
        case AnswerMessageMode.replyAll:
            prefix = "replySubject".localized()
            break
        case AnswerMessageMode.forward:
            prefix = "forwardSubject".localized()
            break
        }
        
        if subjectText.count > 0 {
            subject = prefix + subjectText
        }
        
        
        self.viewController!.subjectTextField.text = subject
    }
    
    //MARK: - ToolBar Actions
    
    func encryptedButtonPressed() {
        
        self.viewController?.encryptedMail = !(self.viewController?.encryptedMail)!
        
        if (self.viewController?.encryptedMail)! {
            self.viewController?.router?.showSetPasswordViewController()
        }
        self.setEncryptedButtonMode(applied: (self.viewController?.encryptedMail)!)
    }
    
    //MARK: - Attach Picker
    
    func showAttachPicker() {
        
        let documentPicker = UIDocumentPickerViewController(documentTypes: [String(kUTTypeText), String(kUTTypeContent), String(kUTTypeItem), String(kUTTypeData), String(kUTTypePDF), String(kUTTypeImage)], in: .import)
        
        documentPicker.delegate = self.viewController
        
        self.viewController!.present(documentPicker, animated: true)
    }
    
    //MARK: - Image Picker
    
    func getPickedImage(imageUrl: URL) {
        
        self.viewController!.attachmentButton.isEnabled = false
        
        self.interactor?.attachFileToDraftMessage(url: imageUrl)
        
        self.addAttachToList(url: imageUrl)
    }
    
    //MARK: - Draft Actions
    
    func initDraftActionsView() {
        
        self.viewController?.draftActionsView = Bundle.main.loadNibNamed(k_MoreActionsViewXibName, owner: nil, options: nil)?.first as? MoreActionsView
        
        var frame = CGRect(x: 0.0, y: 0.0, width: self.viewController!.view.frame.width, height: self.viewController!.view.frame.height)
        
        if Device.IS_IPAD {
            frame = CGRect(x: 0.0, y: 0.0, width: (self.viewController!.splitViewController?.secondaryViewController?.view.frame.width)!, height: (self.viewController!.splitViewController?.secondaryViewController?.view.frame.height)!)
        }
        
        self.viewController?.draftActionsView?.frame = frame
        self.viewController?.draftActionsView?.delegate = self.viewController
        
        self.viewController?.navigationController!.view.addSubview((self.viewController?.draftActionsView)!)
        
        self.viewController?.draftActionsView?.isHidden = true
    }
    
    func showDraftActionsView() {
        
        var actionsButtonsName: Array<String> = []

        actionsButtonsName = self.setupDraftActionsButtons()
        
        self.viewController?.draftActionsView?.setup(buttonsNameArray: actionsButtonsName)
        
        let hidden = self.viewController?.draftActionsView?.isHidden
        
        self.viewController?.draftActionsView?.isHidden = !hidden!
        
        self.viewController!.view.endEditing(true)
    }
    
    func setupDraftActionsButtons() -> Array<String> {
        
        let actionsButtonsName: Array<String> = ["cancel".localized(), "discardDraft".localized(), "saveDraft".localized()]
        
        return actionsButtonsName
    }
    
    func showAttachActionsView() {
        
        var actionsButtonsName: Array<String> = []
        
        actionsButtonsName = self.setupAttachActionsButtons()
        
        self.viewController?.draftActionsView?.setup(buttonsNameArray: actionsButtonsName)
        
        let hidden = self.viewController?.draftActionsView?.isHidden
        
        self.viewController?.draftActionsView?.isHidden = !hidden!
        
        self.viewController!.view.endEditing(true)
    }
    
    func setupAttachActionsButtons() -> Array<String> {
        
        let actionsButtonsName: Array<String> = ["cancel".localized(), "fromAnotherApp".localized(), "photoLibrary".localized(), "camera".localized()]
        
        return actionsButtonsName
    }
    
    func applyDraftAction(_ sender: AnyObject, isButton: Bool) {
        
        if isButton {
            
            let button = sender as! UIButton
            
            let title = button.title(for: .normal)
            
            //print("title:", title as Any)
            
            switch title {
            case MoreActionsTitles.cancel.rawValue.localized():
                print("cancel btn Draft action")
                
                break
            case "discardDraft".localized():
                print("discardDraft btn Draft action")
                self.interactor?.deleteDraft()
                self.interactor?.postUpdateInboxNotification()
                self.viewController!.navigationController?.popViewController(animated: true)
                break
            case "saveDraft".localized():
                print("saveDraft btn Draft action")
                //self.interactor?.postUpdateInboxNotification()
                self.interactor?.saveDraft()
                self.viewController!.navigationController?.popViewController(animated: true)
                break
            case "fromAnotherApp".localized():
                self.showAttachPicker()
                break
            case "photoLibrary".localized():
                self.viewController!.router?.showImagePickerWithLibrary()
                break
            case "camera".localized():
                self.viewController!.router?.showImagePickerWithCamera()

            default:
                print("more actions: default")
            }
        }
 
        self.viewController?.draftActionsView?.isHidden = true
    }
    
    //MARK: - Attachment View
    
    func createAttachment(frame: CGRect, tag: Int, fileUrl: URL) -> AttachmentView {
        
        let attachmentView = Bundle.main.loadNibNamed(k_AttachmentViewXibName, owner: nil, options: nil)?.first as? AttachmentView
//        attachmentView?.frame = frame
        attachmentView?.tag = tag
        attachmentView?.delegate = self.viewController
        attachmentView?.setup(fileUrl: fileUrl)
        attachmentView?.backgroundProgressView.isHidden = true
        
        return attachmentView!
    }
    
    //MARK: - Upgrade to Prime
    
    func showUpgradeToPrimeView() {
        
        self.viewController?.upgradeToPrimeView?.isHidden = !(self.viewController?.upgradeToPrimeView?.isHidden)!
    }
    
    func initAddFolderLimitView() {
        
        self.viewController?.upgradeToPrimeView = Bundle.main.loadNibNamed(k_UpgradeToPrimeViewXibName, owner: nil, options: nil)?.first as? UpgradeToPrimeView
        
        let frame = CGRect(x: 0.0, y: 0.0, width: self.viewController!.view.frame.width, height: self.viewController!.view.frame.height)
        
        if Device.IS_IPAD {
            // frame = CGRect(x: 0.0, y: 0.0, width: (self.viewController!.splitViewController?.secondaryViewController?.view.frame.width)!, height: (self.viewController!.splitViewController?.secondaryViewController?.view.frame.height)!)
        }
        
        self.viewController?.upgradeToPrimeView?.frame = frame
        
        self.viewController?.navigationController!.view.addSubview((self.viewController?.upgradeToPrimeView)!)
        
        self.viewController?.upgradeToPrimeView?.isHidden = true
    }
    
    func attachmentStackView(from list: [AttachmentView]) -> UIStackView {
        list.forEach {
            $0.removeFromSuperview()
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.heightAnchor.constraint(equalToConstant: k_attachmentViewHeight).isActive = true
        }
        let stack = UIStackView(arrangedSubviews: list)
        stack.axis = .vertical
        stack.distribution = .fill
        stack.spacing = k_attachmentsInterSpacing
        
        return stack
    }
}

//MARK: - RichEditor Toolbar Delegate

extension ComposePresenter: RichEditorToolbarDelegate {
    
    fileprivate func randomColor() -> UIColor {
        let colors: [UIColor] = [
            .red,
            .orange,
            .yellow,
            .green,
            .blue,
            .purple,
            .black,
            .darkGray,
            .brown
        ]
        
        let color = colors[Int(arc4random_uniform(UInt32(colors.count)))]
        return color
    }
    
    func richEditorToolbarChangeTextColor(_ toolbar: RichEditorToolbar) {
        let color = randomColor()
        toolbar.editor?.setTextColor(color)
    }
    
    func richEditorToolbarChangeBackgroundColor(_ toolbar: RichEditorToolbar) {
        let color = randomColor()
        toolbar.editor?.setTextBackgroundColor(color)
    }
    
    func richEditorToolbarInsertLink(_ toolbar: RichEditorToolbar) {
        if toolbar.editor?.hasRangeSelection == true {
            let alert = UIAlertController(title: "Insert Link", message: nil, preferredStyle: .alert)
            alert.addTextField { (textField) in
                textField.placeholder = "URL (required)"
            }
            alert.addTextField { (textField) in
                textField.placeholder = "Title"
            }
            alert.addAction(UIAlertAction(title: "Insert", style: .default, handler: { (action) in
                let textField1 = alert.textFields![0]
                let textField2 = alert.textFields![1]
                let url = textField1.text ?? ""
                if url == "" {
                    
//                    VCUtil.showAlertView(viewController: self, title: "Error", message: "Please add link.")
                    return
                }
                let title = textField2.text ?? ""
                toolbar.editor?.insertLink(url, title: title)
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.viewController?.present(alert, animated: true, completion: nil)
        }else {
//            self.view.makeToast("Select text in editor to add link.", duration: 2, position: .center)
        }
    }
    
    func richEditorToolbarInsertImage(_ toolbar: RichEditorToolbar) {
//        imagePicker = UIImagePickerController()
//        imagePicker.sourceType = .photoLibrary
//        if !IS_IPHONE {
//            self.imagePicker.popoverPresentationController?.sourceRect = toolbar.bounds
//            self.imagePicker.popoverPresentationController?.sourceView = toolbar
//        }
//        imagePicker.mediaTypes = [kUTTypeImage as String]
//        imagePicker.delegate = self
//        imagePicker.modalPresentationStyle = .fullScreen
//        present(imagePicker, animated: true, completion: nil)
    }
}
