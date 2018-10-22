//
//  InboxMessageTableViewCell.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 18.10.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import UIKit

class InboxMessageTableViewCell: UITableViewCell {
    
    var formatterService : FormatterService?
    
    @IBOutlet weak var senderLabel             : UILabel!
    @IBOutlet weak var subjectLabel            : UILabel!
    @IBOutlet weak var headMessageLabel        : UILabel!
    @IBOutlet weak var countLabel              : UILabel!
    @IBOutlet weak var deleteLabel             : UILabel!
    @IBOutlet weak var timeLabel               : UILabel!
    
    @IBOutlet weak var isSelectedImageView     : UIImageView!
    @IBOutlet weak var isReadImageView         : UIImageView!
    @IBOutlet weak var isSecuredImageView      : UIImageView!
    @IBOutlet weak var isStaredImageView       : UIImageView!
    @IBOutlet weak var hasAttachmentImageView  : UIImageView!
    @IBOutlet weak var badgesView              : UIView!
    
    @IBOutlet var senderLabelWidthConstraint            : NSLayoutConstraint!
    @IBOutlet var isSelectedImageTrailingConstraint     : NSLayoutConstraint!
    @IBOutlet var isSelectedImageWidthConstraint        : NSLayoutConstraint!
    @IBOutlet var dotImageWidthConstraint               : NSLayoutConstraint!
    @IBOutlet var dotImageTrailingConstraint            : NSLayoutConstraint!
    @IBOutlet var countLabelWidthConstraint             : NSLayoutConstraint!
    @IBOutlet var countLabelTrailingConstraint          : NSLayoutConstraint!
    @IBOutlet var badgesViewWidthConstraint             : NSLayoutConstraint!
    
    var cellWidth : CGFloat = 0.0

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setupCellWithData(message : EmailMessage, isSelectionMode: Bool, isSelected: Bool, frameWidth: CGFloat) {
        
        cellWidth = frameWidth
        
        setupLabelsAndImages(message: message)
        
        setupConstraints(message: message, isSelectionMode: isSelectionMode)
        
        if isSelected {
            isSelectedImageView.image = UIImage(named: k_checkBoxSelectedImageName)
        } else {
            isSelectedImageView.image = UIImage(named: k_checkBoxUncheckedImageName)
        }
    }
    
    func setupLabelsAndImages(message : EmailMessage) {
        
        if let sender = message.sender {
            
            senderLabel.text = sender
        }
        
        if let subject = message.subject {
            subjectLabel.text = subject
        }
        /*
         if let messageText = message {
         headMessageLabel.text = messageText
         }*/
        
        //let testDate = Calendar.current.date(byAdding: .day, value: -3, to: Date())!
        
        if let createdDate = message.createdAt {
            
            if  let date = formatterService!.formatStringToDate(date: createdDate) {
                timeLabel.text = formatterService!.formatCreationDate(date: date)
            }
        }
        
        if let isRead = message.read {
            
            isReadImageView.isHidden = isRead
            
            if isRead {
                self.backgroundColor = k_unreadMessageColor
            } else {
                self.backgroundColor = UIColor.white
            }
        }
        
        if let children = message.hasChildren {
            
            if children > 0 {
                countLabel.isHidden = false
            } else {
                countLabel.isHidden = true
            }
        }
        
        if let destructionDate = message.destructDay {
            deleteLabel.isHidden = false
            //deleteLabel.text =
        } else {
            deleteLabel.isHidden = true
        }
        
        if let isSecured = message.isProtected {
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
  
        setupSenderLabelsAndBadgesView()
        
        self.layoutIfNeeded()
    }
    
    func setupSenderLabelsAndBadgesView() {
        
        let sender = senderLabel.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let senderTextWidth : CGFloat  = (sender?.widthOfString(usingFont: senderLabel.font))!
        
        let badgesViewWidth = calculateBadgesViewWidth()
        
        badgesViewWidthConstraint.constant = badgesViewWidth
        
        let availableSpace : CGFloat = cellWidth - badgesViewWidth - k_rightSideWidth - isSelectedImageTrailingConstraint.constant - isSelectedImageWidthConstraint.constant
        
        print("cellWidth:", cellWidth)
        print("senderTextWidth:", senderTextWidth)
        print("availableSpace:", availableSpace)
        
        if senderTextWidth > availableSpace {
            senderLabelWidthConstraint.constant = availableSpace
        } else {
            senderLabelWidthConstraint.constant = senderTextWidth
        }
    }
    
    func calculateBadgesViewWidth() -> CGFloat {
        
        var deleteLabelWidth : CGFloat = 0.0
        
        if deleteLabel.isHidden {
            deleteLabelWidth = 0.0
        } else {
            deleteLabelWidth = k_deleteLabelWidth
        }
        
        var badgesViewWidth = dotImageWidthConstraint.constant  + dotImageTrailingConstraint.constant  + countLabelWidthConstraint.constant + countLabelTrailingConstraint.constant
        
        badgesViewWidth = badgesViewWidth + deleteLabelWidth
        
        print("badgesViewWidth:", badgesViewWidth)
        
        return badgesViewWidth
    }
}
