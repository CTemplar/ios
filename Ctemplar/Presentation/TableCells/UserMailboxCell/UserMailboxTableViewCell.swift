//
//  UserMailboxTableViewCell.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 30.11.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import UIKit


class UserMailboxTableViewCell: UITableViewCell {
    
    @IBOutlet weak var emailLabel        : UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setupCellWithData(email: String) {

    }
}