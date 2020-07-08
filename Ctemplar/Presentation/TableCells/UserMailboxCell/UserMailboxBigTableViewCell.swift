//
//  UserMailboxBigTableViewCell.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 26.12.2018.
//  Copyright © 2018 CTemplar. All rights reserved.
//

import Foundation
import UIKit
import Utility

class UserMailboxBigTableViewCell: UITableViewCell {
    
    @IBOutlet weak var emailLabel         : UILabel!
    @IBOutlet weak var selectionImageView : UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setupCellWithData(email: String, seleted: Bool) {
        
        self.emailLabel.text = email
        
        self.selectionImageView.isHidden = !seleted
        
        if seleted {
            self.emailLabel.textColor = k_redColor
        } else {
            self.emailLabel.textColor = k_mailboxTextColor
        }        
    }
}
