//
//  ComposePresenter.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 27.11.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import UIKit

class ComposePresenter {
    
    var viewController   : ComposeViewController?
    var interactor       : ComposeInteractor?
    
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
        
        self.viewController?.dataSource?.reloadData(setMailboxData: true)
    }
    
    func setMailboxDataSource(mailboxes: Array<Mailbox>) {
        
        self.viewController?.dataSource?.mailboxesArray = mailboxes
        
        //self.viewController?.dataSource?.reloadData(setMailboxData: true)
    }
    
    //MARK: - Setup Email To Subsection
    
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
        
        //let attachment = NSTextAttachment()
        
        
        if self.viewController!.tapSelectedEmail.count > 0 {
            _ = attributedString.setBackgroundColor(textToFind: self.viewController!.tapSelectedEmail, color: k_foundTextBackgroundColor)
        }
        
        self.viewController!.emailToTextView.attributedText = attributedString
        //self.viewController!.emailToTextView.text = emailToText
    }
    
    func setRect(textView: UITextView) {
        
        let text = textView.text!
        /*
        text?.enumerateSubstrings(in: text?.startIndex ..< text?.endIndex, options: .byWords) {
            (substring, substringRange, _, _) in
            if substring == "saying" {
                //attributedString.addAttribute(.foregroundColor, value: NSColor.red, range: NSRange(substringRange, in: text))
            }
        }*/
        
        let textRange = text.startIndex..<text.endIndex
        
        text.enumerateSubstrings(in: textRange, options: NSString.EnumerationOptions.byWords, { (substring, substringRange, enclosingRange, stop) -> () in
            //let start = distance(text.startIndex, substringRange.startIndex)
            //let length = distance(substringRange.startIndex, substringRange.endIndex)
            //let range = NSMakeRange(start, length)
        })
        
        
        let substrings = textView.text.split(separator: " ")
        
        for sub in substrings {
            
            let wordRange = (textView.text as NSString).range(of: String(sub))
        
            let textContainer = textView.textContainer
            
            let glyphRange = textView.layoutManager.glyphRange(forCharacterRange: wordRange, actualCharacterRange: nil)
            
            var glyphRect = textView.layoutManager.boundingRect(forGlyphRange: glyphRange, in: textContainer)
            
            glyphRect.origin.y += textView.textContainerInset.top
            glyphRect.origin.x += textView.textContainerInset.left
            
            print("rect:", glyphRect.origin.x, glyphRect.origin.y)
            print("rect size:", glyphRect.size.width, glyphRect.size.height)
            
            let rect = CGRect(x: glyphRect.origin.x, y: glyphRect.origin.y + 0.0, width: glyphRect.size.width, height: glyphRect.size.height - 0.0)
            
            //let label = UILabel(frame: rect)
            let view = UIView(frame: rect)
            view.backgroundColor = UIColor.red
            view.alpha = 0.4
            
            textView.add(subview: view)
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
        
        //self.viewController!.backgroundColor = UIColor.yellow//debug
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
        self.setRect(textView: self.viewController!.emailToTextView)
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
}
