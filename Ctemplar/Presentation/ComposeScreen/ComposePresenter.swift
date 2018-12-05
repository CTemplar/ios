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

class ComposePresenter {
    
    var viewController   : ComposeViewController?
    var interactor       : ComposeInteractor?
    var formatterService        : FormatterService?
    
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
            
                let replyHeader = self.generateReplyHeader(message: lastMessage!)
                let lastMessageContentAttributedString = lastMessageContent!.html2AttributedString
                let mutableAttributedString = NSMutableAttributedString(attributedString: replyHeader)
                mutableAttributedString.append(lastMessageContentAttributedString!)
                
                self.viewController?.messageTextView.attributedText = mutableAttributedString//lastMessageContent!.html2AttributedString
                //self.viewController?.messageTextView.sizeToFit()
                self.viewController?.messageTextView.setContentOffset(.zero, animated: true)
            }
            
            self.enabledSendButton()
            
        } else {
            self.viewController?.messageTextView.font = UIFont(name: k_latoRegularFontName, size: 14.0)
            self.viewController?.messageTextView.text = "composeEmail".localized()
            self.viewController?.messageTextView.textColor = UIColor.lightGray
        }
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
    
    func setupTableView(topOffset: CGFloat) {
        
        self.viewController!.tableViewTopOffsetConstraint.constant = topOffset//k_composeTableViewTopOffset
        self.viewController!.view.layoutIfNeeded()
    }
    
    var emailToSubViewsArray = Array<Int>()
    
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
        
        if let recieversArray = message.receivers {
            self.viewController!.emailsToArray = recieversArray as! [String]
            
            for email in self.viewController!.emailsToArray {
                self.viewController!.emailToSting = self.viewController!.emailToSting + email + " "
            }
        }
        /*
        if let sender = message.sender {
            self.viewController!.emailToSting = self.viewController!.emailToSting + sender
            self.viewController!.emailsToArray.append(sender)
        }*/
        
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
    
    func setRect(textView: UITextView, tag: Int) {
        
        self.removeSubviews(textView: textView, array:  self.emailToSubViewsArray, tag: tag)
        
        self.emailToSubViewsArray.removeAll()
        
        let text = textView.text!
        
        var substrings = textView.text.split(separator: " ")
        substrings.removeFirst()
        
        var index = tag
        
        for sub in substrings {
        
            let wordRange = (text as NSString).range(of: String(sub))
        
            let textContainer = textView.textContainer
            
            let glyphRange = textView.layoutManager.glyphRange(forCharacterRange: wordRange, actualCharacterRange: nil)
            
            var glyphRect = textView.layoutManager.boundingRect(forGlyphRange: glyphRange, in: textContainer)
            
            //glyphRect.origin.y += textView.textContainerInset.top
            glyphRect.origin.x += textView.textContainerInset.left
            
            //print("rect:", glyphRect.origin.x, glyphRect.origin.y)
            //print("rect size:", glyphRect.size.width, glyphRect.size.height)
            print("textView.textContainerInset.top:", textView.textContainerInset.top) // 8 - 2
            
            let rect = CGRect(x: glyphRect.origin.x, y: glyphRect.origin.y + 6.0, width: glyphRect.size.width, height: 22.0)
            
            index = index + 1
            
            print("add with index", index)
            self.emailToSubViewsArray.append(index)
            
            self.addEmailLabelWith(text: String(sub), rect: rect, index: index, textView: textView)
        }
    }
    
    func addEmailLabelWith(text: String, rect: CGRect, index: Int, textView: UITextView) {
        
        let view = UIView(frame: rect)
        view.backgroundColor = k_mainInboxColor
        
        view.layer.cornerRadius = 4.0
        view.layer.borderColor = UIColor.white.cgColor
        view.layer.borderWidth = 1.0
  
        let labelRect = CGRect(x: 0.0, y: 0.0, width: rect.size.width, height: rect.size.height)
        let label = UILabel(frame: labelRect)
        label.font = UIFont(name: k_latoRegularFontName, size: 14.0)
        label.textColor = k_emailToInputColor
        label.text = text
        label.backgroundColor = UIColor.clear
        
        //label.alpha = 0.4
        //view.alpha = 0.4
        
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
        self.viewController!.emailToTextView.frame = newEmailToTextViewFrame;
        
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
            _ = attributedString.setBackgroundColor(textToFind: email, color: k_mainInboxColor)
            _ = attributedString.setForgroundColor(textToFind: email, color: k_emailToInputColor)
        }
        
        if self.viewController!.tapSelectedCcEmail.count > 0 {
            _ = attributedString.setBackgroundColor(textToFind: self.viewController!.tapSelectedCcEmail, color: k_foundTextBackgroundColor)
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
            _ = attributedString.setBackgroundColor(textToFind: email, color: k_mainInboxColor)
            _ = attributedString.setForgroundColor(textToFind: email, color: k_emailToInputColor)
        }
        
        if self.viewController!.tapSelectedBccEmail.count > 0 {
            _ = attributedString.setBackgroundColor(textToFind: self.viewController!.tapSelectedBccEmail, color: k_foundTextBackgroundColor)
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
        
        //=========
        self.setRect(textView: self.viewController!.emailToTextView, tag: 200)
        //========
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
}
