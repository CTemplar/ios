//
//  ChildMessageExpandedWithAttachmentTableViewCell.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 22.11.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import UIKit


class ChildMessageExpandedWithAttachmentTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var parentController : ViewInboxEmailDataSource?
    
    @IBOutlet weak var senderLabel     : UILabel!
    @IBOutlet weak var recieverLabel   : UILabel!
    @IBOutlet weak var dateLabel       : UILabel!
    @IBOutlet weak var detailsButton   : UIButton!
    
    @IBOutlet var fromToBarTextView    : UITextView!
    @IBOutlet var contentTextView      : UITextView!
    
    @IBOutlet var collectionView       : UICollectionView!
    
    @IBOutlet weak var deleteLabel             : UILabel!
    @IBOutlet weak var leftLabel               : UILabel!
     
    @IBOutlet weak var timerlabelsView         : UIView!
    @IBOutlet weak var leftlabelView           : UIView!
    @IBOutlet weak var rightlabelView          : UIView!
    
    @IBOutlet var timerlabelsViewWidthConstraint        : NSLayoutConstraint!
    @IBOutlet var leftlabelViewWidthConstraint          : NSLayoutConstraint!
    @IBOutlet var rightlabelViewWidthConstraint         : NSLayoutConstraint!
    
    @IBOutlet var fromToViewHeightConstraint        : NSLayoutConstraint!
    @IBOutlet var fromToBarTextViewHeightConstraint : NSLayoutConstraint!
    
    @IBOutlet var messageContentTextViewHeightConstraint        : NSLayoutConstraint!
    
    var showDetails : Bool = false
    var index : Int = 0
    
    var attachmentsArray : Array<Attachment> = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.registerCollectionViewCell()
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
                dateLabel.text = parentController?.formatterService!.formatCreationDate(date: date, short: false, useFullDate: true)
            }
        }
        
        self.setupFromToHeaderHeight(message: message)
        
        self.setupDetailsButton()
        
        self.setupMessageContentTextView(messageContent: contentMessage)
        
        if let attachments = message.attachments {
            self.attachmentsArray = attachments
            self.collectionView.reloadData()
        }
    
        self.setupPropertyLabel(message: message)
    }
        
    func setupPropertyLabel(message: EmailMessage) {
          
        leftlabelView.isHidden = true
          
        if let delayedDelivery = message.delayedDelivery {
            leftlabelView.isHidden = false
            leftlabelView.backgroundColor = k_greenColor
            if  let date = parentController?.formatterService!.formatDestructionTimeStringToDate(date: delayedDelivery) {
                leftLabel.attributedText = date.timeCountForDelivery(short: false)
            } else {
                if let date = parentController?.formatterService!.formatDestructionTimeStringToDateTest(date: delayedDelivery) {
                    leftLabel.attributedText = date.timeCountForDelivery(short: false)
                } else {
                    leftLabel.attributedText = NSAttributedString(string: "Error")
                }
            }
        }
          
        if let deadManDuration = message.deadManDuration {
            leftlabelView.isHidden = false
            leftlabelView.backgroundColor = k_redColor
            if  let date = parentController?.formatterService!.formatDeadManDateString(duration: deadManDuration, short: false) {
                leftLabel.attributedText = date
            } else {
                leftLabel.attributedText = NSAttributedString(string: "Error")
            }
        }
    
        if let destructionDate = message.destructDay {
            rightlabelView.isHidden = false
            rightlabelView.backgroundColor = k_orangeColor
            if  let date = parentController?.formatterService!.formatDestructionTimeStringToDate(date: destructionDate) {
                deleteLabel.attributedText = date.timeCountForDestruct(short: false)
            } else {
                //print("erorr formatting destructionDate:", destructionDate)
                if let date = parentController?.formatterService!.formatDestructionTimeStringToDateTest(date: destructionDate) {
                    print("new format date:", date)
                    deleteLabel.attributedText = date.timeCountForDestruct(short: false)
                } else {
                    deleteLabel.attributedText = NSAttributedString(string: "Error")
                }
            }
        } else {
            rightlabelView.isHidden = true
        }
                  
        leftlabelViewWidthConstraint.constant = k_deleteLabelWidth
        rightlabelViewWidthConstraint.constant = k_deleteLabelWidth
                
        if leftlabelView.isHidden {
            leftlabelViewWidthConstraint.constant = 0.0
        }

        if rightlabelView.isHidden {
            rightlabelViewWidthConstraint.constant = 0.0
        }
                
        timerlabelsViewWidthConstraint.constant = leftlabelViewWidthConstraint.constant + rightlabelViewWidthConstraint.constant
          
        self.layoutIfNeeded()
    }
    
    func setupFromToHeaderHeight(message: EmailMessage) {
        
        var fromName: String = ""
        var fromEmail: String = ""
        var toNamesArray : Array<String> = []
        var toEmailsArray : Array<String> = []
        var ccArray : Array<String> = []
        var bccArray : Array<String> = []
        
        if let sender = message.sender {
            fromEmail = sender
        }
        
        if let recieversArray = message.receivers {
            toEmailsArray = recieversArray as! Array<String>
        }
        
        if let carbonCopyArray = message.cc {
            ccArray = carbonCopyArray as! Array<String>
        }
        
        if let bcarbonCopyArray = message.bcc {
            bccArray = bcarbonCopyArray as! Array<String>
        }
         
        let fromToText = parentController?.formatterService!.formatFromToString(fromName: fromName, fromEmail: fromEmail, toNamesArray: toNamesArray, toEmailsArray: toEmailsArray, ccArray: ccArray, bccArray: bccArray)
        
        let fromToAttributtedString = parentController?.formatterService!.formatFromToAttributedString(fromName: fromName, fromToText: fromToText!, toNamesArray: toNamesArray, toEmailsArray: toEmailsArray, ccArray: ccArray, bccArray: bccArray)
        
        self.fromToBarTextView.contentInset = UIEdgeInsets(top: 3, left: 0, bottom: 0, right: 0)
        self.fromToBarTextView.attributedText = fromToAttributtedString
        
        let numberOfLines = fromToText?.numberOfLines()
        
        var fromToViewHeight = k_lineHeightForFromToText * CGFloat(numberOfLines!)
        
        if fromToViewHeight < k_fromToViewMinHeight {
            fromToViewHeight = k_fromToViewMinHeight
        } else {
            fromToViewHeight = (k_lineHeightForFromToText * CGFloat(numberOfLines!))  + k_InsetsForFromTo
        }
        
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
        //contentTextView.backgroundColor = UIColor.yellow
        
        messageContentTextViewHeightConstraint.constant = contentTextView.frame.height
    }
    
    //MARK: - IBActions
    
    @IBAction func detailsButtonPressed(_ sender: AnyObject) {
        
        self.showDetails = !self.showDetails
        
        self.parentController?.showDetailMessagesArray[self.index] = self.showDetails
        self.parentController?.reloadData(scrollToLastMessage: false)
    }
    
    //MARK: - Collection
    
    func registerCollectionViewCell() {
        
        self.collectionView.register(UINib(nibName: k_AttachmentCollcetionViewCellXibName, bundle: nil), forCellWithReuseIdentifier: k_AttachmentCollcetionViewCellIdentifier)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return attachmentsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: k_AttachmentCollcetionViewCellIdentifier, for: indexPath) as! AttachmentCollectionViewCell
        
        let attacment = attachmentsArray[indexPath.item]
        cell.setupCellWithData(attachment: attacment)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        print("tapped for Attachment item:", indexPath.item)
        
        let attach = self.attachmentsArray[indexPath.item]
        
        if let urlString = attach.contentUrl {
            //let url = URL(string: urlString)
            self.parentController?.attachSelected(itemUrlString: urlString, encrypted: attach.encrypted ?? false)
        }
    }
}
