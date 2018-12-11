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

class ComposePresenter {
    
    var viewController   : ComposeViewController?
    var interactor       : ComposeInteractor?
    var formatterService        : FormatterService?
    
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
        
        if self.viewController!.messageTextView.text.count > 0 {
            if self.viewController!.messageTextView.text != "composeEmail".localized() {
                messageContentIsEmpty = false
            }
        }
        
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
    
    //MARK: - Setup Message Section
    
    func setupAttachments() {
        
        if let draftMessage = self.viewController!.message {
        
            if let attachments = draftMessage.attachments {
                
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
    }
    
    func setupMessageSectionSize() {
        
        self.setupAttachmentButton()
        
        //self.viewController?.messageTextView.backgroundColor = UIColor.yellow
        
        let fixedWidth = self.viewController!.view.frame.width - k_emailToTextViewLeftOffset - k_emailToTextViewLeftOffset
        let messageContentHeight = self.sizeThatFits(textView: self.viewController!.messageTextView, fixedWidth: fixedWidth)
        
        //let scrollViewHeight = self.viewController?.scrollView.frame.size.height
        
        self.removeAttachmentsView()
        
        var attachmentsHeight : CGFloat = k_attachmentViewTopOffset
        
       // let contentViewHeight = self.viewController?.scrollView.contentSize.height
             
        for attachmentView in (self.viewController?.viewAttachmentsList)! {
            
            let frame = CGRect(x: k_emailToTextViewLeftOffset, y: messageContentHeight + attachmentsHeight, width: (self.viewController?.view.frame.size.width)! - k_emailToTextViewLeftOffset - k_emailToTextViewLeftOffset, height: k_attachmentViewHeight)
    
            
            attachmentView.frame = frame
            self.viewController!.scrollView.add(subview: attachmentView)
            
            attachmentsHeight = attachmentsHeight + k_attachmentViewHeight + k_messageTextViewTopOffset
        }
        
        //if Int(messageContentHeight) < Int((scrollViewHeight! - k_messageTextViewTopOffset - k_messageTextViewTopOffset )) {
        //    self.viewController?.messageTextViewHeightConstraint.constant = scrollViewHeight! - k_messageTextViewTopOffset - k_messageTextViewTopOffset
        //    self.viewController?.scrollView.contentSize = CGSize(width: (self.viewController?.view.frame.size.width)!, height: (self.viewController?.messageTextViewHeightConstraint.constant)! + attachmentsHeight)
       // } else {
            self.viewController!.messageTextViewHeightConstraint.constant = self.viewController!.messageTextView.frame.size.height
            self.viewController?.scrollView.contentSize = CGSize(width: (self.viewController?.view.frame.size.width)!, height: (self.viewController?.messageTextViewHeightConstraint.constant)! + k_messageTextViewTopOffset + k_messageTextViewTopOffset + attachmentsHeight)
       // }
        
        self.viewController?.view.layoutIfNeeded()
    }
    
    func setupMessageSection(emailsArray: Array<EmailMessage>) {
        
        //self.viewController?.dercyptedMessagesArray.removeAll()
    
        if emailsArray.count > 0 {
            
            var dercyptedMessagesArray = Array<String>()
            
            let firstMessage = emailsArray.first
            let lastMessage = emailsArray.last
            
            self.fillAllEmailsFields(message: firstMessage!)
            
            //HUD.show(.progress)
            if let messageContent = self.interactor?.extractMessageContent(message: lastMessage!) {
                dercyptedMessagesArray.append(messageContent)
            }
            //HUD.hide()
            
            if dercyptedMessagesArray.count > 0 {
        
                let lastMessageContent = dercyptedMessagesArray.last
            
                let replyHeader = self.generateHeader(message: lastMessage!, answerMode: self.viewController!.answerMode)
                
                let lastMessageContentAttributedString = lastMessageContent!.html2AttributedString
                let mutableAttributedString = NSMutableAttributedString(attributedString: replyHeader)
                mutableAttributedString.append(lastMessageContentAttributedString!)
                
                self.viewController?.messageTextView.attributedText = mutableAttributedString//lastMessageContent!.html2AttributedString
                self.viewController?.messageTextView.setContentOffset(.zero, animated: true)
            }
            
            self.enabledSendButton()
            
        } else {
            self.viewController?.messageTextView.font = UIFont(name: k_latoRegularFontName, size: 16.0)
            self.viewController?.messageTextView.text = "composeEmail".localized()
            self.viewController?.messageTextView.textColor = UIColor.lightGray
            
            //self.viewController?.messageTextView.text = "xxssss xxssss xxssssxxssss xxssss xxssss xxssssvvvvvvvvvvv      fedfsdf dfgsdgsd gs gsd gsd gs s sgds gsdgssdgsg gsgdg's;g sg sd';  gs'd;gsigsjgosd gs0d-s gspg s g dsgs--gs- g \n\n dfgjfdlgjdf;g \n\n gsjgsgs gsd gds  sdgs dgjsgisdogjisodg sdogjsd g dsgjsgjosgpg g sdpgojsdog  gpsodgj opg sdjpsogjsdpo gpsdojg gs dgpogj sg \n\n\n\n\n dgjsdpogj sgjgposgj sogogjo sdgsg gsgdg's;g sg sd';  gs'd;gsigsjgosd gs0d-s gspg s g dsgs--gs- g \n\n dfgjfdlgjdf;g \n\n gsjgsgs gsd gds  sdgs dgjsgisdogjisodg  sdgsg gsgdg's;g sg sd';  gs'd;gsigsjgosd gs0d-s gspg s g dsgs--gs- g \n\n dfgjfdlgjdf;g \n\n gsjgsgs gsd gds  sdgs dgjsgisdogjisodg sdogjsd g dsgjsgjosgpg g sdpgojsdog  gpsodgj opg sdjp sdogjsd g dsgjsgjosgpg g sdpgojsdog sdgsg gsgdg's;g sg sd';  gs'd;gsigsjgosd gs0d-s gspg s g dsgs--gs- g \n\n dfgjfdlgjdf;g \n\n gsjgsgs gsd gds  sdgs dgjsgisdogjisodg sdogjsd g dsgjsgjosgpg g sdpgojsdog  gpsodgj opg sdjp gpsodgj opg sdjp gogjodp gs   000000000 000000000 00000000"
            
        }
        
        self.setupMessageSectionSize()
    }
    
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
            attributedString = self.generateForwardHeader(message: message)
            break
        }
        
        return attributedString
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
    
    func generateForwardHeader(message: EmailMessage) -> NSAttributedString {
        
        var forwardHeader : String = ""
        
        let font : UIFont = UIFont(name: k_latoRegularFontName, size: 14.0)!
        
        let attributedString = NSMutableAttributedString(string: forwardHeader, attributes: [
            .font: font,
            .foregroundColor: k_actionMessageColor,
            .kern: 0.0
            ])
        
        return attributedString
    }
    
    func setupTableView(topOffset: CGFloat) {
        
        self.viewController!.tableViewTopOffsetConstraint.constant = topOffset//k_composeTableViewTopOffset
        self.viewController!.view.layoutIfNeeded()
    }
    
    var emailToSubViewsArray = Array<Int>()
    var ccToSubViewsArray = Array<Int>()
    var bccToSubViewsArray = Array<Int>()
    
    //MARK: - Setup Email From Section
    
    func setMailboxes(mailboxes: Array<Mailbox>) {
        
        for mailbox in mailboxes {
            if let defaultMailbox = mailbox.isDefault {
                if defaultMailbox {
                    if let defaultEmail = mailbox.email {
                        self.setupEmailFromSection(emailFromText: defaultEmail)
                    }
                    
                    self.viewController!.mailboxID = mailbox.mailboxID!
                }
            }
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
    
    func fillAllEmailsFields(message: EmailMessage) {
        
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
        
        if let ccArray = message.cc {
            self.viewController!.ccToArray = ccArray as! [String]
            
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
    
    func setRect(textView: UITextView, email: String, tag: Int, selected: Bool) {
        
        let text = textView.text!
        
        let wordRange = (text as NSString).range(of: email)
        
        let textContainer = textView.textContainer
        
        let glyphRange = textView.layoutManager.glyphRange(forCharacterRange: wordRange, actualCharacterRange: nil)
        
        var glyphRect = textView.layoutManager.boundingRect(forGlyphRange: glyphRange, in: textContainer)
        
        glyphRect.origin.x += textView.textContainerInset.left
        
        print("textView.textContainerInset.top:", textView.textContainerInset.top) // 8 - 2
        
        let rect = CGRect(x: glyphRect.origin.x, y: glyphRect.origin.y + 6.0, width: glyphRect.size.width, height: 22.0)
        
        self.addEmailLabelWith(text: email, rect: rect, index: tag, textView: textView, selected: selected)
    }
    
    func addEmailLabelWith(text: String, rect: CGRect, index: Int, textView: UITextView, selected: Bool) {
        
        let view = UIView(frame: rect)
        if selected {
            view.backgroundColor = k_foundTextBackgroundColor
        } else {
            view.backgroundColor = k_mainInboxColor
        }
        
        view.layer.cornerRadius = 4.0
        view.layer.borderColor = UIColor.white.cgColor
        view.layer.borderWidth = 1.0
  
        let labelRect = CGRect(x: 0.0, y: 0.0, width: rect.size.width, height: rect.size.height)
        let label = UILabel(frame: labelRect)
        label.font = UIFont(name: k_latoRegularFontName, size: 14.0)
        label.textColor = k_emailToInputColor
        //var formattedText = text.dropLast().dropFirst()
        //formattedText = "_" + formattedText + "_"
        //label.text = String(formattedText)
        label.text = text
        label.backgroundColor = UIColor.clear
        
        view.tag = index
        
        view.add(subview: label)
        textView.add(subview: view)
        //textView.add(subview: label)
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
        
        //set rects
        
        self.emailToSubViewsArray = self.setRecanglesFor(textView: self.viewController!.emailToTextView, emailArray: self.viewController!.emailsToArray, selectedEmail: self.viewController!.tapSelectedEmail, subViewsArray: self.emailToSubViewsArray, subViewTag: ComposeSubViewTags.emailToTextViewTag.rawValue)
        
        self.ccToSubViewsArray = self.setRecanglesFor(textView: self.viewController!.ccToTextView, emailArray: self.viewController!.ccToArray, selectedEmail: self.viewController!.tapSelectedCcEmail, subViewsArray: self.ccToSubViewsArray, subViewTag: ComposeSubViewTags.ccToTextViewTag.rawValue)
        
        self.bccToSubViewsArray = self.setRecanglesFor(textView: self.viewController!.bccToTextView, emailArray: self.viewController!.bccToArray, selectedEmail: self.viewController!.tapSelectedBccEmail, subViewsArray: self.bccToSubViewsArray, subViewTag: ComposeSubViewTags.bccToTextViewTag.rawValue)
        
       // self.setupMessageSectionSize()
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
            
            //let formattedEmail = "<" + email + ">"
            
            self.setRect(textView: textView, email: email, tag: tag, selected: selected)
            localSubViewsArray.append(tag)
        }
        
        return localSubViewsArray
    }
    
    //MARK: - Setup Subject Section
    
    func setupSubject(subjectText: String) {
        
        var subject: String = ""
        
        if subjectText.count > 0 {
            subject = "Re: " + subjectText
        }
        
        self.viewController!.subjectTextField.text = subject
    }
    
    //MARK: - ToolBar Actions
    
    func encryptedButtonPressed() {
        
        self.viewController?.encryptedMail = !(self.viewController?.encryptedMail)!
        
        var buttonImage = UIImage()
        
        if (self.viewController?.encryptedMail)! {
            buttonImage = UIImage(named: k_encryptApliedImageName)!
            self.viewController?.router?.showSetPasswordViewController()
        } else {
            buttonImage = UIImage(named: k_encryptImageName)!
        }
        
        self.viewController?.encryptedButton .setImage(buttonImage, for: .normal)        
    }
    
    //MARK: - Attach Picker
    
    func showAttachPicker() {
        
        let documentPicker = UIDocumentPickerViewController(documentTypes: [String(kUTTypeText), String(kUTTypeContent), String(kUTTypeItem), String(kUTTypeData), String(kUTTypePDF), String(kUTTypeImage)], in: .import)
        
        documentPicker.delegate = self.viewController
        
        self.viewController!.present(documentPicker, animated: true)
    }
    
    //MARK: - Draft Actions
    
    func initDraftActionsView() {
        
        self.viewController?.draftActionsView = Bundle.main.loadNibNamed(k_MoreActionsViewXibName, owner: nil, options: nil)?.first as? MoreActionsView
        self.viewController?.draftActionsView?.frame = CGRect(x: 0.0, y: 0.0, width: self.viewController!.view.frame.width, height: self.viewController!.view.frame.height)
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
        
        let actionsButtonsName: Array<String> = ["cancel".localized(), "fromAnotherApp".localized(), "photoLibrary".localized()]
        
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
                
                break

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
    
    func removeAttachmentsView() {
        
        var tag = ComposeSubViewTags.attachmentsViewTag.rawValue
        
        for _ in (self.viewController?.viewAttachmentsList)! {
            
            tag = tag + 1
            
            if let subview = self.viewController?.scrollView.viewWithTag(tag) {
                subview.removeFromSuperview()
            }
        }
    }
    
    func removeAllAttachmentsView() {
        
        for attachmentView in (self.viewController?.viewAttachmentsList)! {
            
            let tag = attachmentView.tag
            
            if let subview = self.viewController?.scrollView.viewWithTag(tag) {
                subview.removeFromSuperview()
            }
        }
    }
    
    func removeAttachmentView(tag: Int) {
        
        if let subview = self.viewController?.scrollView.viewWithTag(tag) {
            subview.removeFromSuperview()
        }
    }
    
    func attachmentView(tag: Int) -> AttachmentView? {
        
        if let subview = self.viewController?.scrollView.viewWithTag(tag) {
            return subview as? AttachmentView
        }
        
        return nil
    }
}
