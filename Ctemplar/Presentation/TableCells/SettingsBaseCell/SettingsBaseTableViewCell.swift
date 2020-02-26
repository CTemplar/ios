//
//  SettingsBaseTableViewCell.swift
//  Ctemplar
//
//  Created by Tatarinov Dmitry on 21.12.2018.
//  Copyright © 2018 ComeOnSoftware. All rights reserved.
//

import Foundation
import UIKit

class SettingsBaseTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel        : UILabel!
    @IBOutlet weak var valueLabel        : UILabel!
    
    @IBOutlet var valueLableWidthConstraint       : NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setupCellWithData(title: String, value: String) {
        
        self.titleLabel.text = title
        self.valueLabel.text = value
        
        if value.count > 0 {
            let valueTextWidth = value.widthOfString(usingFont: self.valueLabel.font)
            self.valueLableWidthConstraint.constant = valueTextWidth * 1.05
        } else {
            self.valueLableWidthConstraint.constant = 0.0
        }
    }
    
    func setupCellWithData(attributedTitle: NSAttributedString, value: String) {
        self.titleLabel.attributedText = attributedTitle
        self.valueLabel.text = value
        
        if value.count > 0 {
            let valueTextWidth = value.widthOfString(usingFont: self.valueLabel.font)
            self.valueLableWidthConstraint.constant = valueTextWidth * 1.05
        } else {
            self.valueLableWidthConstraint.constant = 0.0
        }
    }
}
