//
//  ContactTableViewCell.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 15.11.2018.
//  Copyright © 2018 CTemplar. All rights reserved.
//

import Foundation
import UIKit
import Utility
import Networking

class ContactTableViewCell: UITableViewCell {
    
    @IBOutlet weak var checkImageView    : UIImageView!
    @IBOutlet weak var avatarImageView   : UIImageView!
    @IBOutlet weak var initialsLabel     : UILabel!
    @IBOutlet weak var nameLabel         : UILabel!
    @IBOutlet weak var emailLabel        : UILabel!
    
    @IBOutlet var checkImageViewWidthConstraint     : NSLayoutConstraint!
    @IBOutlet var checkImageViewTrailingConstraint  : NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setupCellWithData(contact: Contact, isSelectionMode: Bool, isSelected: Bool, foundText: String) {        
        
        if let userName = contact.contactName {
            let subjectAttributedString = NSMutableAttributedString(string: userName)
            let range = subjectAttributedString.foundRangeFor(lowercasedString: userName.lowercased(), textToFind: foundText)
            _ = subjectAttributedString.setBackgroundColor(range: range, color: k_foundTextBackgroundColor)
            self.nameLabel.attributedText = subjectAttributedString
            self.initialsLabel.text = self.formatInitials(name: userName)
        } else {
            self.nameLabel.text = "Unknown name".localized()
            self.initialsLabel.text = "UN".localized()
        }
        
        if let email = contact.email {
            let subjectAttributedString = NSMutableAttributedString(string: email)
            let range = subjectAttributedString.foundRangeFor(lowercasedString: email.lowercased(), textToFind: foundText)
            _ = subjectAttributedString.setBackgroundColor(range: range, color: k_foundTextBackgroundColor)
            self.emailLabel.attributedText = subjectAttributedString           
        } else {
            self.emailLabel.text = "Unknown email".localized()
        }
        
        if isSelectionMode {
            checkImageViewWidthConstraint.constant = k_isSelectedImageWidth
            checkImageViewTrailingConstraint.constant = k_isSelectedImageTrailing
        } else {
            checkImageViewWidthConstraint.constant = 0.0
            checkImageViewTrailingConstraint.constant = 0.0
        }
        
        if isSelected {
            checkImageView.image = UIImage(named: k_checkBoxSelectedImageName)
        } else {
            checkImageView.image = UIImage(named: k_checkBoxUncheckedImageName)
        }
        
        self.layoutIfNeeded()
    }
    
    func formatInitials(name: String) -> String {
        
        let initials = name.prefix(2)
        
        return String(initials).uppercased()
    }
}
