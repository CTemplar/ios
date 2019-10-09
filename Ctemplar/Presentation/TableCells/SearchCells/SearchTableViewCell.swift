//
//  SearchTableViewCell.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 09.11.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import UIKit


class SearchTableViewCell: UITableViewCell {
    
    var parentController : SearchDataSource?
    
    @IBOutlet weak var folderNameBackground    : UIView!
    @IBOutlet weak var folderNameLabel         : UILabel!
    @IBOutlet weak var subjectLabel            : UILabel!
    @IBOutlet weak var dateLabel               : UILabel!
    @IBOutlet weak var senderLabel             : UILabel!
    
    @IBOutlet weak var hasAttachmentImageView  : UIImageView!
    @IBOutlet weak var isSecuredImageView      : UIImageView!
    @IBOutlet weak var isStaredImageView       : UIImageView!
    
    @IBOutlet var folderNameLabelWidthConstraint            : NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setupCellWithData(message: EmailMessage, foundText: String) {
        
        if let subject = message.subject {            
            let subjectAttributedString = NSMutableAttributedString(string: subject)
            let range = subjectAttributedString.foundRangeFor(lowercasedString: subject.lowercased(), textToFind: foundText)
            _ = subjectAttributedString.setBackgroundColor(range: range, color: k_foundTextBackgroundColor)
            subjectLabel.attributedText = subjectAttributedString
        }
        
        if let sender = message.sender {
            let senderAttributedString = NSMutableAttributedString(string: sender)
            let range = senderAttributedString.foundRangeFor(lowercasedString: sender.lowercased(), textToFind: foundText)
            _ = senderAttributedString.setBackgroundColor(range: range, color: k_foundTextBackgroundColor)
            senderLabel.attributedText = senderAttributedString
        }
        
        if let createdDate = message.createdAt {            
            if  let date = parentController?.formatterService!.formatStringToDate(date: createdDate) {
                dateLabel.text = parentController?.formatterService!.formatCreationDate(date: date)
            }
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
        
        if let folderName = message.folder {
            folderNameLabel.text = folderName
            
            let folderNameWidthString = folderName.widthOfString(usingFont: self.folderNameLabel.font)
            
            if folderNameWidthString + k_folderNameLabelOffset > k_folderNameLabelMaxWidth {
                folderNameLabelWidthConstraint.constant = k_folderNameLabelMaxWidth
            } else {
                folderNameLabelWidthConstraint.constant = folderNameWidthString + k_folderNameLabelOffset
            }
            
            let folderColor = self.folderColor(folderName: folderName)
            folderNameBackground.backgroundColor = folderColor
            
            if folderColor == k_mainInboxColor {
                folderNameLabel.textColor = k_mainFolderTextColor
            } else {
                folderNameLabel.textColor = UIColor.white
            }
        }
        
        self.layoutIfNeeded()
    }
    
    func folderColor(folderName: String) -> UIColor {
        
        var color: UIColor = k_mainInboxColor
        
        switch folderName {
        case MessagesFoldersName.inbox.rawValue:
            color = k_mainInboxColor
            break
        case MessagesFoldersName.draft.rawValue:
            color = k_mainInboxColor
            break
        case MessagesFoldersName.sent.rawValue:
            color = k_mainInboxColor
            break
        case MessagesFoldersName.outbox.rawValue:
            color = k_mainInboxColor
            break
        case MessagesFoldersName.starred.rawValue:
            color = k_mainInboxColor
            break
        case MessagesFoldersName.archive.rawValue:
            color = k_mainInboxColor
            break
        case MessagesFoldersName.spam.rawValue:
            color = k_mainInboxColor
            break
        case MessagesFoldersName.trash.rawValue:
            color = k_mainInboxColor
            break
        default:
            color = self.customFolderColor(folderName: folderName) //for custom folders
            break
        }
        
        return color
    }
    
    func customFolderColor(folderName: String) -> UIColor {
        
        var color: UIColor = k_mainInboxColor
        
        for folder in (self.parentController?.customFoldersArray)! {
            
            if folder.folderName == folderName {
                color = self.hexStringToUIColor(hex: folder.color!)
            }
        }
        
        return color
    }
    
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
