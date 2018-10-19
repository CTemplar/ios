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
    
    @IBOutlet var isSelectedImageTrailingConstraint     : NSLayoutConstraint!
    @IBOutlet var isSelectedImageWidthConstraint        : NSLayoutConstraint!
    @IBOutlet var dotImageWidthConstraint               : NSLayoutConstraint!
    @IBOutlet var countLabelWidthConstraint             : NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setupCellWithData(message : EmailMessage, isSelectionMode: Bool, isSelected: Bool) {
        
        setupConstraints(message: message, isSelectionMode: isSelectionMode)
        
        setupLabelsAndImages(message: message)
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
        
        if let createdDate = message.createdAt {
            //timeLabel.text =
        }
        
        if let isRead = message.read {
            
            isReadImageView.isHidden = isRead
            
            if isRead {
                self.backgroundColor = k_unreadMessageColor
            } else {
                self.backgroundColor = UIColor.white
            }
        }
        
        if let destructionDate = message.destructDay {
            deleteLabel.isHidden = false
            //deleteLabel.text =
        } else {
            //deleteLabel.isHidden = true
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
            isSelectedImageTrailingConstraint.constant = 12.0
            isSelectedImageWidthConstraint.constant = 22.0
        } else {
            isSelectedImageTrailingConstraint.constant = 0.0
            isSelectedImageWidthConstraint.constant = 0.0
        }
        
        self.layoutIfNeeded()
    }
}
