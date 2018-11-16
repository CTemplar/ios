//
//  ChildMessageTableViewCell.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 16.11.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import UIKit


class ChildMessageTableViewCell: UITableViewCell {
    
    @IBOutlet weak var senderLabel     : UILabel!
    @IBOutlet weak var headerLabel     : UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setupCellWithData(sender: String, header: String) {
        
        self.senderLabel.text = sender
        self.headerLabel.text = header
    }
}
