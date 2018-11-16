//
//  ContactTableViewCell.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 15.11.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation

import UIKit


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
    
    func setupCellWithData(contact: Contact, isSelectionMode: Bool, isSelected: Bool) {        
        
        if let userName = contact.contactName {
            self.nameLabel.text = userName
            self.initialsLabel.text = self.formatInitials(name: userName)
        }
        
        if let email = contact.email {
            self.emailLabel.text = email
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
