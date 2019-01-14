//
//  ChildMessageExpandedTableViewCell.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 19.11.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import UIKit


class ChildMessageExpandedTableViewCell: UITableViewCell {
    
    var parentController : ViewInboxEmailDataSource?
    
    @IBOutlet weak var senderLabel     : UILabel!
    @IBOutlet weak var recieverLabel   : UILabel!
    @IBOutlet weak var dateLabel       : UILabel!
    @IBOutlet weak var detailsButton   : UIButton!
    
    @IBOutlet var fromToBarTextView    : UITextView!
    @IBOutlet var contentTextView      : UITextView!
    
    @IBOutlet var fromToViewHeightConstraint        : NSLayoutConstraint!
    @IBOutlet var fromToBarTextViewHeightConstraint : NSLayoutConstraint!
    
    @IBOutlet var messageContentTextViewHeightConstraint        : NSLayoutConstraint!
    
    var showDetails : Bool = false
    //var showContent : Bool = false
    var index : Int = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setupCellWithData(message: EmailMessage, contentMessage: String, showDetails: Bool, index: Int) {
        
        self.showDetails = showDetails     
        self.index = index
        
        if let sender = message.sender {
            senderLabel.text = sender
        }
                
        var toEmailsArray : Array<String> = []
        
        if let recieversArray = message.receivers {
            toEmailsArray = recieversArray as! Array<String>
        }
        
        let toText = self.parentController?.formatterService!.formatToString(toEmailsArray: toEmailsArray)
        self.recieverLabel.text = toText
        
        if let createdDate = message.createdAt {            
            if  let date = parentController?.formatterService!.formatStringToDate(date: createdDate) {
                dateLabel.text = parentController?.formatterService!.formatCreationDate(date: date)
            }
        }
        
        self.setupFromToHeaderHeight(message: message)
        
        self.setupDetailsButton()
        
        self.setupMessageContentTextView(messageContent: contentMessage)
    }
    
    func setupFromToHeaderHeight(message: EmailMessage) {
        
        var fromName: String = ""
        var fromEmail: String = ""
        var toNamesArray : Array<String> = []
        var toEmailsArray : Array<String> = []
        var ccArray : Array<String> = []
        
        if let sender = message.sender {
            fromEmail = sender
        }
        
        if let recieversArray = message.receivers {
            toEmailsArray = recieversArray as! Array<String>
        }
        
        if let carbonCopyArray = message.cc {
            ccArray = carbonCopyArray as! Array<String>
        }
         
        let fromToText = parentController?.formatterService!.formatFromToString(fromName: fromName, fromEmail: fromEmail, toNamesArray: toNamesArray, toEmailsArray: toEmailsArray, ccArray: ccArray)
        
        let fromToAttributtedString = parentController?.formatterService!.formatFromToAttributedString(fromName: fromName, fromToText: fromToText!, toNamesArray: toNamesArray, toEmailsArray: toEmailsArray, ccArray: ccArray)
        
        self.fromToBarTextView.contentInset = UIEdgeInsets(top: 3, left: 0, bottom: 0, right: 0)
        self.fromToBarTextView.attributedText = fromToAttributtedString
        
        let numberOfLines = fromToText?.numberOfLines()
        //print("numberOfLines:", numberOfLines as Any)
        
        var fromToViewHeight = k_lineHeightForFromToText * CGFloat(numberOfLines!)
        
        if fromToViewHeight < k_fromToViewMinHeight {
            fromToViewHeight = k_fromToViewMinHeight
        } else {
            fromToViewHeight = (k_lineHeightForFromToText * CGFloat(numberOfLines!))  + k_InsetsForFromTo
        }
        
        //self.fromToViewHeightConstraint.constant = fromToViewHeight       
        
        if self.showDetails {
            self.fromToViewHeightConstraint.constant = fromToViewHeight
        } else {
            self.fromToViewHeightConstraint.constant = 0.0
        }
        
        self.fromToBarTextViewHeightConstraint.constant = self.fromToViewHeightConstraint.constant
        
        self.layoutIfNeeded()
    }
    
    func setupDetailsButton() {

        var text : String = ""

        if self.showDetails {
            text = "hideDetails".localized()
        } else {
            text = "viewDetails".localized()
        }
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .right
        
        let attributedString = NSMutableAttributedString(string: text, attributes: [
            .font: UIFont(name: k_latoRegularFontName, size: 14.0)!,
            .foregroundColor: k_blueColor,            
            .kern: 0.0,
            .paragraphStyle: paragraph
            ])
        
        _ = attributedString.setUnderline(textToFind: text)
        
        self.detailsButton.setAttributedTitle(attributedString, for: .normal)
    }
    
    func setupMessageContentTextView(messageContent: String) {
        
        contentTextView.attributedText = messageContent.html2AttributedString
        contentTextView.sizeToFit()
        
        //contentTextView.text = messageContent
        
        //print("messageContent:", messageContent)
        //print("messageContent.html2AttributedString:", messageContent.html2AttributedString)
        
        let layoutManager : NSLayoutManager = contentTextView.layoutManager
        let numberOfGlyphs = layoutManager.numberOfGlyphs
        var numberOfLines = 0
        var index = 0
        var lineRange:NSRange = NSRange()
        
        while (index < numberOfGlyphs) {
            layoutManager.lineFragmentRect(forGlyphAt: index, effectiveRange: &lineRange)
            index = NSMaxRange(lineRange);
            numberOfLines = numberOfLines + 1
        }
        
        //print("numberOfLines:", numberOfLines)
        //print("height:", contentTextView.frame.height)
        
        messageContentTextViewHeightConstraint.constant = contentTextView.frame.height//CGFloat(numberOfLines) * k_lineHeightForMessageText
    }
    
    //MARK: - IBActions
    
    @IBAction func detailsButtonPressed(_ sender: AnyObject) {
        
        self.showDetails = !self.showDetails
        
        self.parentController?.showDetailMessagesArray[self.index] = self.showDetails
        self.parentController?.reloadData(scrollToLastMessage: false)
    }
}
