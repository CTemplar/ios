//
//  InboxMessageTableViewCell.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 18.10.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import UIKit
import MGSwipeTableCell

class InboxMessageTableViewCell: MGSwipeTableCell {
    
    //var formatterService : FormatterService?
    var parentController : InboxDataSource?
    
    @IBOutlet weak var senderLabel             : UILabel!
    @IBOutlet weak var subjectLabel            : UILabel!
    @IBOutlet weak var headMessageLabel        : UILabel!
    @IBOutlet weak var countLabel              : UILabel!
    @IBOutlet weak var deleteLabel             : UILabel!
    @IBOutlet weak var leftLabel               : UILabel!
    @IBOutlet weak var timeLabel               : UILabel!
    
    @IBOutlet weak var isSelectedImageView     : UIImageView!
    @IBOutlet weak var isReadImageView         : UIImageView!
    @IBOutlet weak var isSecuredImageView      : UIImageView!
    @IBOutlet weak var isStaredImageView       : UIImageView!
    @IBOutlet weak var hasAttachmentImageView  : UIImageView!
    @IBOutlet weak var badgesView              : UIView!
    @IBOutlet weak var timerlabelsView         : UIView!
    @IBOutlet weak var leftlabelView           : UIView!
    @IBOutlet weak var rightlabelView          : UIView!
    
    @IBOutlet var senderLabelWidthConstraint            : NSLayoutConstraint!
    @IBOutlet var isSelectedImageTrailingConstraint     : NSLayoutConstraint!
    @IBOutlet var isSelectedImageWidthConstraint        : NSLayoutConstraint!
    @IBOutlet var dotImageWidthConstraint               : NSLayoutConstraint!
    @IBOutlet var dotImageTrailingConstraint            : NSLayoutConstraint!
    @IBOutlet var countLabelWidthConstraint             : NSLayoutConstraint!
    @IBOutlet var countLabelTrailingConstraint          : NSLayoutConstraint!
    @IBOutlet var deleteLabelWidthConstraint            : NSLayoutConstraint!
    @IBOutlet var badgesViewWidthConstraint             : NSLayoutConstraint!
    @IBOutlet var timerlabelsViewWidthConstraint        : NSLayoutConstraint!
    @IBOutlet var leftlabelViewWidthConstraint          : NSLayoutConstraint!
    @IBOutlet var rightlabelViewWidthConstraint         : NSLayoutConstraint!
    
    var cellWidth : CGFloat = 0.0

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setupCellWithData(message: EmailMessage, header: String, isSelectionMode: Bool, isSelected: Bool, frameWidth: CGFloat) {
        
        cellWidth = frameWidth
        
        setupLabelsAndImages(message: message, header: header)
        
        setupConstraints(message: message, isSelectionMode: isSelectionMode)
        
        if isSelected {
            isSelectedImageView.image = UIImage(named: k_checkBoxSelectedImageName)
        } else {
            isSelectedImageView.image = UIImage(named: k_checkBoxUncheckedImageName)
        }
    }
    
    func setupLabelsAndImages(message: EmailMessage, header : String) {
        
        if let sender = message.sender {            
            senderLabel.text = sender
        }
        
        if let subject = message.subject {
            subjectLabel.text = subject
        }
        
        headMessageLabel.text = header
        
        //let testDate = Calendar.current.date(byAdding: .day, value: -3, to: Date())!
        
        if let createdDate = message.createdAt {
            
            if  let date = parentController?.formatterService!.formatStringToDate(date: createdDate) {
                timeLabel.text = parentController?.formatterService!.formatCreationDate(date: date)
            }
        }
        
        if let isRead = message.read {
            
            isReadImageView.isHidden = isRead
            
            if !isRead {
                self.backgroundColor = k_unreadMessageColor
            } else {
                self.backgroundColor = UIColor.white
            }
        }
        
        if let childrenCount = message.childrenCount {
            if childrenCount > 0 {
                countLabel.isHidden = false
                countLabel.text = childrenCount.description
            } else {
                countLabel.isHidden = true
            }
        }
        
        leftlabelView.isHidden = true
        
        let short = self.isShortNeed(message: message)
        
        if let delayedDelivery = message.delayedDelivery {
            leftlabelView.isHidden = false
            leftlabelView.backgroundColor = k_greenColor
            if  let date = parentController?.formatterService!.formatDestructionTimeStringToDate(date: delayedDelivery) {
                leftLabel.attributedText = date.timeCountForDelivery(short: short)
            }
        }
        
        if let deadManDuration = message.deadManDuration {
            leftlabelView.isHidden = false
            leftlabelView.backgroundColor = k_redColor
            if  let date = parentController?.formatterService!.formatDeadManDateString(duration: deadManDuration, short: short) {
                leftLabel.attributedText = date
            }
        }
        
        //let testDate = "2018-10-26T13:00:00Z"
        if let destructionDate = message.destructDay {
            rightlabelView.isHidden = false
            rightlabelView.backgroundColor = k_orangeColor
            if  let date = parentController?.formatterService!.formatDestructionTimeStringToDate(date: destructionDate) {
                deleteLabel.attributedText = date.timeCountForDestruct(short: short)
            }
        } else {
            rightlabelView.isHidden = true
        }
        
        if let isSecured = message.isEncrypted {
            if isSecured {
                isSecuredImageView.image = UIImage(named: k_secureOnImageName)
            } else {
                isSecuredImageView.image = UIImage(named: k_secureOffImageName)
            }
        }
        
        if let isStarred = message.starred {
            if isStarred {
                isStaredImageView.image = UIImage(named: k_starOnImageName)
            } else {
                isStaredImageView.image = UIImage(named: k_starOffImageName)
            }
        }
        
        if let attachments = message.attachments {
            if attachments.count > 0 {
                hasAttachmentImageView.isHidden = false
            } else {
                hasAttachmentImageView.isHidden = true
            }
        }
    }
    
    func setupConstraints(message : EmailMessage, isSelectionMode: Bool) {
        
        if isSelectionMode {
            isSelectedImageTrailingConstraint.constant = k_isSelectedImageTrailing
            isSelectedImageWidthConstraint.constant = k_isSelectedImageWidth
        } else {
            isSelectedImageTrailingConstraint.constant = 0.0
            isSelectedImageWidthConstraint.constant = 0.0
        }
        
        if let isRead = message.read {
            
            if isRead {
                dotImageWidthConstraint.constant = 0.0
                dotImageTrailingConstraint.constant = 0.0
            } else {
                dotImageWidthConstraint.constant = k_dotImageWidth
                dotImageTrailingConstraint.constant = k_dotImageTrailing
            }
        }
        
        if countLabel.isHidden {
            countLabelWidthConstraint.constant = 0.0
            countLabelTrailingConstraint.constant = 0.0
        } else {
            countLabelWidthConstraint.constant = k_countLabelWidth
            countLabelTrailingConstraint.constant = k_countLabelTrailing
        }

        let short = self.isShortNeed(message: message)
        
        if short {
            leftlabelViewWidthConstraint.constant = k_deleteLabelSEWidth
            rightlabelViewWidthConstraint.constant = k_deleteLabelSEWidth
        } else {
            leftlabelViewWidthConstraint.constant = k_deleteLabelWidth
            rightlabelViewWidthConstraint.constant = k_deleteLabelWidth
        }
        
        if leftlabelView.isHidden {
            leftlabelViewWidthConstraint.constant = 0.0
        }

        if deleteLabel.isHidden {
            rightlabelViewWidthConstraint.constant = 0.0
        }
        
        timerlabelsViewWidthConstraint.constant = leftlabelViewWidthConstraint.constant + rightlabelViewWidthConstraint.constant
  
        setupSenderLabelsAndBadgesView(short: short)
        
        self.layoutIfNeeded()
    }
    
    func setupSenderLabelsAndBadgesView(short: Bool) {
        
        let sender = senderLabel.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let senderTextWidth : CGFloat  = (sender?.widthOfString(usingFont: senderLabel.font))!
        
        let badgesViewWidth = calculateBadgesViewWidth(short: short)
        
        badgesViewWidthConstraint.constant = badgesViewWidth
        
        let availableSpace : CGFloat = cellWidth - badgesViewWidth - k_rightSideWidth - isSelectedImageTrailingConstraint.constant - isSelectedImageWidthConstraint.constant
        
        //print("cellWidth:", cellWidth)
        //print("senderTextWidth:", senderTextWidth)
        //print("availableSpace:", availableSpace)
        
        if senderTextWidth > availableSpace {
            senderLabelWidthConstraint.constant = availableSpace
        } else {
            senderLabelWidthConstraint.constant = senderTextWidth
        }
    }
    
    func calculateBadgesViewWidth(short: Bool) -> CGFloat {
        
        var leftLabelWidth : CGFloat = 0.0
        var deleteLabelWidth : CGFloat = 0.0
        
        if rightlabelView.isHidden {
            deleteLabelWidth = 0.0
        } else {
            if short {
                deleteLabelWidth = k_deleteLabelSEWidth
            } else {
                deleteLabelWidth = k_deleteLabelWidth
            }
        }
        
        if leftlabelView.isHidden {
            leftLabelWidth = 0.0
        } else {
            if short {
                leftLabelWidth = k_deleteLabelSEWidth
            } else {
                leftLabelWidth = k_deleteLabelWidth
            }
        }
        
        let labelsViewWidth = leftLabelWidth + deleteLabelWidth
        
        var badgesViewWidth = dotImageWidthConstraint.constant  + dotImageTrailingConstraint.constant  + countLabelWidthConstraint.constant + countLabelTrailingConstraint.constant
        
        badgesViewWidth = badgesViewWidth + labelsViewWidth
        
        //print("badgesViewWidth:", badgesViewWidth)
        
        return badgesViewWidth
    }
    
    func isShortNeed(message: EmailMessage) -> Bool {
        
        var short : Bool = false
        var leftLabelShowing : Bool = false
        
        if Device.IS_IPHONE_5 {
            short = true
        } else {
            if message.delayedDelivery != nil || message.deadManDuration != nil {
                leftLabelShowing = true
            }
            
            if message.destructDay != nil {
                if leftLabelShowing {
                    short = true
                }
            }
        }
        
        return short
    }
}
